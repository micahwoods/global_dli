# function to get the monthly normal data

  rs_normal_get <- function(location) {
    
   # browser()
    
    click <- location
    
    id2 <- showNotification("Downloading satellite global solar radiation data (climatological normal) from NASA POWER", 
                           duration = NULL, closeButton = FALSE, type = "warning")
    on.exit(removeNotification(id2), add = TRUE)
    
    power_C <- get_power(community = "AG", 
                         lonlat = c(click[2], click[1]),
                         pars = "ALLSKY_SFC_SW_DWN",
                         temporal_api = "climatology")
    
  }
  
