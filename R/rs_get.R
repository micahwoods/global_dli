# function to get the data 

  rs_get <- function(location) {
    
    isolate( click <- location )
    
    # adjust the longitude when user scrolls beyond +/- 180
    while (click$lng < -180)  {
      click$lng <- click$lng + 360
    }
    
    while (click$lng > 180)  {
      click$lng <- click$lng - 360
    }
    
    ### debug
    
    ## click <- data.frame(lng = 99.6,
    ##                     lat = 7.5)
    ##
    
    id <- showNotification("Downloading satellite global solar radiation data (daily) from NASA POWER", 
                     duration = NULL, closeButton = FALSE, type = "warning")
    on.exit(removeNotification(id), add = TRUE)
    
    loc_power <- get_power(community = "AG", 
                           lonlat = c(click$lng, click$lat),
                           pars = "ALLSKY_SFC_SW_DWN",
                           temporal_api = "daily",
                           dates = c(today() - days(370), today() - days(1)))
    
  }
  
