# the 0.5° x 0.5° grid cell containing a point
#
# Uses floor + 0.5 rather than round_any(ceiling), which gives a
# zero-width cell when a click lands exactly on a 0.5° line.
# Used by both the on-screen leaflet rectangle and make_chart_3().

grid_cell <- function(lat, lng, size = 0.5) {
  x0 <- floor(lng / size) * size
  y0 <- floor(lat / size) * size
  c(xmin = x0, xmax = x0 + size,
    ymin = y0, ymax = y0 + size)
}
