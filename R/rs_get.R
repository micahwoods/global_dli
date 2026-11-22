# get the past ~year and a half of daily solar radiation and PAR from NASA POWER
#
# The chart shows 364 days, but more is downloaded:
# - solar radiation (Rs) lags about a week, so 364 days with data need a few
#   more than that;
# - PAR lags about 3 months. prep_dli() estimates the missing recent days from
#   Rs and this location's PAR/Rs ratio at the same time of year, one year
#   earlier, so PAR is needed back to about 364 + 90 + 365 + 30 days ago.
#
# location: numeric c(lat, lon), as returned by map_click_loc()

rs_get <- function(location) {

  id <- showNotification("Downloading satellite PAR and solar radiation data (daily) from NASA POWER",
                         duration = NULL, closeButton = FALSE, type = "warning")
  on.exit(removeNotification(id), add = TRUE)

  get_power(community = "AG",
            lonlat = c(location[2], location[1]),
            pars = c("ALLSKY_SFC_SW_DWN", "ALLSKY_SFC_PAR_TOT"),
            temporal_api = "daily",
            dates = c(today() - days(900), today() - days(1)))
}
