# get the monthly climatological normal PAR from NASA POWER
#
# location: numeric c(lat, lon), as returned by map_click_loc()

rs_normal_get <- function(location) {

  id2 <- showNotification("Downloading satellite PAR data (climatological normal) from NASA POWER",
                          duration = NULL, closeButton = FALSE, type = "warning")
  on.exit(removeNotification(id2), add = TRUE)

  get_power(community = "AG",
            lonlat = c(location[2], location[1]),
            pars = "ALLSKY_SFC_PAR_TOT",
            temporal_api = "climatology")
}
