# the downloadable 16:9 summary chart
#
# Left: the past year of daily DLI (make_chart_1). Top right: monthly DLI vs
# normal (make_chart_2). Bottom right: the location map (make_chart_3), inset
# into an empty slot so that it fills the corner, rather than stacked in the
# patchwork layout, where it would be shrunk to the monthly chart's panel.
#
# dli_data:    daily data from rs_get()
# normal_data: climatology from rs_normal_get()
# location:    numeric c(lat, lon)
# provider:    map tiles, matching the basemap chosen on the step 1 map

chart_3pane_size <- c(width = 12.8, height = 7.2)   # inches, 16:9

## The bottom-right slot is an empty plot_spacer() under the monthly chart,
## and the map is inset over it. inset_element() places the map relative to
## the whole right-hand column (the last element of the layout), so the box
## below is in fractions of that column: full width, and from the bottom of the
## image up to just under the monthly chart's legend text.
chart_3pane_map_box <- c(left = 0.01, right = 0.99, bottom = 0.01, top = 0.46)

## width / height of that box at this image size; the map is drawn with this
## shape so that it fills the box
chart_3pane_map_aspect <- 1.06

make_chart_3pane <- function(dli_data, normal_data, location, provider) {

  map <- make_chart_3(location, provider = provider, aspect = chart_3pane_map_aspect) +
    theme(plot.margin = margin(0, 0, 0, 0))

  slot <- plot_spacer() + theme(plot.background = element_rect(fill = app_bg, color = NA))

  box <- chart_3pane_map_box
  ((make_chart_1(dli_data) | (make_chart_2(normal_data, dli_data) / slot)) +
      plot_layout(nrow = 1, widths = c(3, 1))) +
    inset_element(map, left = box[["left"]], right = box[["right"]],
                  bottom = box[["bottom"]], top = box[["top"]],
                  align_to = "full", clip = TRUE) +
    plot_annotation(theme = theme(plot.background = element_rect(fill = app_bg, color = NA)))
}

save_chart_3pane <- function(file, ...) {
  ggsave(file, make_chart_3pane(...),
         width = chart_3pane_size[["width"]], height = chart_3pane_size[["height"]],
         dpi = 300, bg = app_bg)
}
