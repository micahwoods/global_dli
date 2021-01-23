# east west north sout calc for the filename paste

east_west <- function(x) {
    
   
    
    # label as north or south or east or west for chart output
    # north_south <- ifelse(d3$LAT > 0, "N", "S")
    east_west <- ifelse(as.numeric(x$lng) > 0, "E", "W")
    
}