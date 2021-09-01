# east west calc for the filename paste

east_west <- function(x) {
    east_west <- ifelse(as.numeric(x$lng) > 0, "E", "W")
}
