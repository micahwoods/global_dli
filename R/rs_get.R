# function to get the data and make a chart
# basically I think this needs to be done together
# because I don't figure out how to download the data once and re-use it between
# sessions, anyway I can try it, maybe reactive makes it work perfect


  rs_get <- function(location) {
    
    isolate( click <- location )
    
    # adjust the longitude when user scrolls beyond +/- 180
    while (click$lng < -180)  {
      click$lng <- click$lng + 360
    }
    
    while (click$lng > 180)  {
      click$lng <- click$lng - 360
    }
    
    id <- showNotification("Downloading satellite global solar radiation data (daily) from NASA POWER", 
                     duration = NULL, closeButton = FALSE, type = "warning")
    on.exit(removeNotification(id), add = TRUE)
    
    loc_power <- get_power(community = "AG", 
                           lonlat = c(click$lng, click$lat),
                           pars = "ALLSKY_SFC_SW_DWN",
                           temporal_average = "DAILY",
                           dates = c(today() - days(370), today() - days(1)))
    
  }
  