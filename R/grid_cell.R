# the 1° x 1° NASA POWER grid cell containing a point
#
# NASA POWER's solar parameters (ALLSKY_SFC_SW_DWN, ALLSKY_SFC_PAR_TOT) come
# from CERES SYN1deg at its native 1° resolution. The cell edges fall on whole
# degrees of latitude and longitude, and a point exactly on an edge belongs to
# the cell north / east of it, in both hemispheres, which is what floor()
# gives (checked against the POWER API, daily and climatology, Nov 2026).
#
# The app requests data at the cell centre (cell_centre()), not at the clicked
# point, so the data always come from the cell drawn on the maps. Every point
# in a cell gets the same solar data anyway, and this avoids any doubt for
# clicks within a hair of an edge (POWER echoes coordinates rounded to 3
# decimals, so a click at 13.9999 is reported back as 14.0 although the data
# are from the 13-14 cell).
#
# Used by the on-screen leaflet rectangle, rs_get(), rs_normal_get(),
# make_chart_3() and the chart subtitles.

grid_cell <- function(lat, lng, size = 1) {
  ## the north pole and the 180° meridian belong to the last cell, not to a
  ## cell beyond the edge of the world
  x0 <- min(floor(lng / size) * size, 180 - size)
  y0 <- min(floor(lat / size) * size, 90 - size)
  c(xmin = x0, xmax = x0 + size,
    ymin = y0, ymax = y0 + size)
}

## centre of the grid cell containing location, as c(lat, lon)
cell_centre <- function(location) {
  cell <- grid_cell(location[1], location[2])
  c(lat = (cell[["ymin"]] + cell[["ymax"]]) / 2,
    lon = (cell[["xmin"]] + cell[["xmax"]]) / 2)
}

## label for the cell containing a point: "13° to 14° N, 100° to 101° E",
## or with compact = TRUE "13–14° N, 100–101° E" (for narrow chart panels)
format_cell <- function(lat, lon, compact = FALSE) {
  cell <- grid_cell(lat, lon)
  fmt <- if (compact) "%g–%g° %s" else "%g° to %g° %s"
  span <- function(lo, hi, pos, neg) {
    if (lo >= 0) sprintf(fmt, lo, hi, pos)
    else         sprintf(fmt, abs(hi), abs(lo), neg)
  }
  paste0(span(cell[["ymin"]], cell[["ymax"]], "N", "S"), ", ",
         span(cell[["xmin"]], cell[["xmax"]], "E", "W"))
}
