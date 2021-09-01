## north south calc for the filename paste

north_south <- function(x) {
    north_south <- ifelse(as.numeric(x$lat) > 0, "N", "S")
}
