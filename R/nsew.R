# east west north sout calc for the filename paste

north_south <- function(x) {
    
    d3 <- x[1, ]
    
    # label as north or south or east or west for chart output
    north_south <- ifelse(d3$LAT > 0, "N", "S")
    #east_west <- ifelse(d3$LON > 0, "E", "W")
    
}