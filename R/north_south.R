# east west north sout calc for the filename paste

north_south <- function(x) {
    
    # label as north or south or east or west for chart output
    north_south <- ifelse(as.numeric(x$lat) > 0, "N", "S")
    #east_west <- ifelse(d3$LON > 0, "E", "W")
    
}