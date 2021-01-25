# write a function to get the
# lat lon points of where was clicked on the map
# so I can call that when I need it

map_click_loc <- function(x) {
  
  click <- as.numeric(x)
  
  # adjust the longitude when user scrolls beyond +/- 180
  while (click[2] < -180)  {
    click[2] <- click[2] + 360
  }
  
  while (click[2] > 180)  {
    click[2] <- click[2] - 360
  }
  
  return(as.numeric(click))
}