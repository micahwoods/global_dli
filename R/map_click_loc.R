# lat/lon of a leaflet map click as numeric c(lat, lon),
# with longitude wrapped to [-180, 180]

map_click_loc <- function(click) {
  c(as.numeric(click$lat), wrap_lng(as.numeric(click$lng)))
}
