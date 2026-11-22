# get the monthly climatological normal PAR from NASA POWER
#
# location: numeric c(lat, lon), as returned by map_click_loc(); the data are
#           requested at the centre of its 1° grid cell (see R/grid_cell.R)

rs_normal_get <- function(location) {

  id2 <- showNotification("Downloading satellite PAR data (climatological normal) from NASA POWER",
                          duration = NULL, closeButton = FALSE, type = "warning")
  on.exit(removeNotification(id2), add = TRUE)

  get_power(community = "AG",
            lonlat = rev(unname(cell_centre(location))),   # c(lon, lat) of the 1° cell centre
            pars = "ALLSKY_SFC_PAR_TOT",
            temporal_api = "climatology")
}
