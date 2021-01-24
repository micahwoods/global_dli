# function to get the data and make a chart
# basically I think this needs to be done together
# because I don't figure out how to download the data once and re-use it between
# sessions, anyway I can try it, maybe reactive makes it work perfect


  rs_normal_get <- function(location) {
    
   # browser()
    
    click <- location
    
    showNotification("Downloading climatological normal solar radiation data PART1 !!")
    
    power_C <- get_power(community = "AG", 
                         lonlat = c(click[2], click[1]),
                         pars = "ALLSKY_SFC_SW_DWN",
                         temporal_average = "CLIMATOLOGY")
    
   # showNotification("Climatological normal monthly data obtained")
  }
  