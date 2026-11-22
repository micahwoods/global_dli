# make chart 3 (the rectangle on map of selected point)
#
# Draws the 1° x 1° NASA POWER grid cell on a basemap as a ggplot,
# replacing the old mapview::mapshot() screenshot approach, which needed a
# headless browser (PhantomJS / Chrome) that is no longer available.
#
# location: numeric c(lat, lon), as returned by map_click_loc()
# provider: maptiles tile provider, matching the basemap chosen on the step 1
#           map: "OpenStreetMap", "Esri.WorldImagery" or "Esri.NatGeoWorldMap"
# zoom:     tile zoom level; NULL (the default) picks it from the frame size so
#           the map is drawn from about the same number of tiles (~400 px
#           across) anywhere: 7 near the equator, lower near the poles, where
#           a 1° cell is much taller in Web Mercator and a fixed zoom would
#           mean downloading hundreds of tiles
# aspect:   width / height of the map frame; fixed so the map is the same
#           shape in the download wherever the location is
# zoom_out: frame width as a multiple of the cell width
# cell_outline: colour of the grid-cell outline (drawn over a white casing)
# title:    optional title above the map

make_chart_3 <- function(location,
                         provider = "Esri.NatGeoWorldMap",
                         zoom = NULL,
                         aspect = 1,
                         zoom_out = 4.5,
                         cell_outline = "#E4007C",
                         title = NULL) {

  id5 <- showNotification("Preparing location map",
                          duration = NULL, closeButton = FALSE, type = "warning")
  on.exit(removeNotification(id5), add = TRUE)

  lat <- location[1]
  lon <- location[2]

  ## the grid cell the data come from (see R/grid_cell.R)
  cell <- grid_cell(lat, lon)

  credit <- paste(strwrap(maptiles::get_credit(provider), width = 70), collapse = "\n")

  tryCatch({

    ## work in Web Mercator (EPSG:3857), the tiles' native CRS: get_tiles()
    ## returns tiles in the CRS of the object passed in, and requesting them
    ## in lat/lon would resample (blur) them and distort the aspect ratio

    ## project the cell corners (a lat/lon box stays a rectangle) and the point
    corners <- sf::sf_project("EPSG:4326", "EPSG:3857",
                              rbind(c(cell[["xmin"]], cell[["ymin"]]),
                                    c(cell[["xmax"]], cell[["ymax"]]),
                                    c(lon, lat)))

    ## a fixed-shape frame (width / height = aspect) centred on the cell, so the
    ## map is the same size in the download wherever the location is. The cell
    ## takes up about 1 / zoom_out of the frame; cells get taller in Web
    ## Mercator away from the equator, so the frame grows to fit them.
    cell_w <- corners[2, 1] - corners[1, 1]
    cell_h <- corners[2, 2] - corners[1, 2]
    frame_w <- max(cell_w, cell_h * aspect) * zoom_out
    frame_h <- frame_w / aspect
    mid <- c((corners[1, 1] + corners[2, 1]) / 2, (corners[1, 2] + corners[2, 2]) / 2)

    ## keep the frame inside the Web Mercator world north-south (~85° N/S).
    ## East-west it stays centred on the cell, even across the date line,
    ## which is handled when the tiles are fetched below.
    world <- 20037508
    mid[2] <- min(max(mid[2], -world + frame_h / 2), world - frame_h / 2)
    frame <- c(xmin = mid[1] - frame_w / 2, xmax = mid[1] + frame_w / 2,
               ymin = mid[2] - frame_h / 2, ymax = mid[2] + frame_h / 2)

    ## zoom at which the frame is about target_px tile pixels wide: a 256 px
    ## tile spans 2 * world / 2^zoom metres
    if (is.null(zoom)) {
      target_px <- 400
      zoom <- round(log2(target_px * 2 * world / (256 * frame_w)))
      zoom <- min(max(zoom, 1), 10)
    }

    ## the tiles as plain raster images, each with its x offset. A frame that
    ## crosses the date line is fetched in two parts: the part inside the
    ## world, and the part beyond the line, fetched from the other side of the
    ## world and shifted back next to it.
    parts <- list(list(xmin = max(frame[["xmin"]], -world),
                       xmax = min(frame[["xmax"]], world), shift = 0))
    if (frame[["xmin"]] < -world)
      parts <- c(parts, list(list(xmin = frame[["xmin"]] + 2 * world, xmax = world,
                                  shift = -2 * world)))
    if (frame[["xmax"]] > world)
      parts <- c(parts, list(list(xmin = -world, xmax = frame[["xmax"]] - 2 * world,
                                  shift = 2 * world)))

    tile_layers <- lapply(parts, function(p) {
      bb <- sf::st_bbox(c(xmin = p$xmin, xmax = p$xmax,
                          ymin = frame[["ymin"]], ymax = frame[["ymax"]]), crs = 3857)
      ## one cache folder per bbox: maptiles 0.13.0 builds its cache key from
      ## only the first bbox value (xmin), so two frames with the same left
      ## edge (e.g. both starting at the date line) would share a cached image
      cachedir <- file.path(tempdir(), "maptiles",
                            paste(c(round(bb), zoom), collapse = "_"))
      tiles <- maptiles::get_tiles(sf::st_as_sfc(bb), provider = provider, zoom = zoom,
                                   crop = TRUE, cachedir = cachedir)
      rgb_array <- terra::as.array(tiles)[, , 1:3, drop = FALSE] / 255
      rgb_array[is.na(rgb_array)] <- 1
      e <- as.vector(terra::ext(tiles))
      annotation_raster(as.raster(rgb_array),
                        xmin = e[["xmin"]] + p$shift, xmax = e[["xmax"]] + p$shift,
                        ymin = e[["ymin"]], ymax = e[["ymax"]])
    })

    ggplot() +
      tile_layers +
      ## cell: light fill, then the outline as a coloured line on a wider white
      ## one, so it stands out on pale maps and dark satellite imagery alike
      annotate("rect",
               xmin = corners[1, 1], xmax = corners[2, 1],
               ymin = corners[1, 2], ymax = corners[2, 2],
               fill = "orange", alpha = 0.2, colour = NA) +
      annotate("rect",
               xmin = corners[1, 1], xmax = corners[2, 1],
               ymin = corners[1, 2], ymax = corners[2, 2],
               fill = NA, colour = "white", linewidth = 1.5) +
      annotate("rect",
               xmin = corners[1, 1], xmax = corners[2, 1],
               ymin = corners[1, 2], ymax = corners[2, 2],
               fill = NA, colour = cell_outline, linewidth = 0.675) +
      annotate("point", x = corners[3, 1], y = corners[3, 2],
               shape = 21, size = 2, stroke = 0.8, fill = "white", colour = "#730B29") +
      ## tile credit inside the bottom-right corner, as on a web map
      annotate("label", x = frame[["xmax"]], y = frame[["ymin"]], label = credit,
               hjust = 1, vjust = 0, size = 1.3, lineheight = 0.9,
               family = "Roboto Condensed", colour = "grey20",
               fill = alpha("white", 0.7), label.size = 0, label.r = unit(0, "pt"),
               label.padding = unit(1.5, "pt")) +
      coord_equal(xlim = frame[c("xmin", "xmax")], ylim = frame[c("ymin", "ymax")],
                  expand = FALSE) +
      labs(title = title) +
      theme_void(base_family = "Roboto Condensed") +
      theme(plot.title = element_text(size = 11, hjust = 0.5, margin = margin(b = 4)),
            panel.border = element_rect(fill = NA, colour = "grey60", linewidth = 0.3),
            plot.margin = margin(10, 10, 5, 10),
            plot.background = element_rect(fill = app_bg, color = NA))

  }, error = function(e) {
    ## don't let a tile server problem break the whole chart download
    message("make_chart_3: map tiles unavailable: ", conditionMessage(e))
    ggdraw() +
      draw_label("Location map\ncurrently unavailable",
                 fontfamily = "Roboto Condensed", size = 12)
  })
}
