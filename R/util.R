# libraries, constants and small helpers for the Global DLI app
#
# Shiny sources every file in R/ before ui.R and server.R.
# sf and terra are used via sf:: / terra:: (needed by maptiles) and are
# deliberately not attached, so they don't mask dplyr/tidyr functions.

library(shiny)
library(leaflet)
library(leaflet.extras)   # addSearchOSM()
library(nasapower)
library(ggplot2)
library(cowplot)
library(dplyr)
library(lubridate)
library(zoo)
library(tidyr)
library(patchwork)
library(shinyFeedback)
library(magick)
library(maptiles)         # basemap tiles for the location map (make_chart_3)
library(shinycssloaders)
library(ggpp)            # geom_table for annotate(geom = "table")
library(tibble)

atc_style  <- "color: #fff; background-color: #3f7300; border-color: #fff"
atc2_style <- "color: #fff; background-color: #730B29; border-color: #fff"

app_bg <- "#f7ffed"

## DLI (mol m-2 d-1) from NASA POWER PAR (MJ m-2 d-1): 4.48 mol photons per
## MJ of PAR, as in Faust and Logan (2018)
mol_per_MJ_par <- 4.48

## PAR fraction of global solar radiation, used only when a location has no
## PAR data at all to work out its own ratio from
par_fraction_default <- 0.45

## wrap longitudes to [-180, 180] (leaflet allows scrolling past the date line)
wrap_lng <- function(lng) ((lng + 180) %% 360) - 180

## "13.8° N & 100.5° E" style label
format_latlon <- function(lat, lon, sep = " & ") {
  paste0(formatC(abs(lat), digits = 1, format = "f"), "° ", ifelse(lat >= 0, "N", "S"),
         sep,
         formatC(abs(lon), digits = 1, format = "f"), "° ", ifelse(lon >= 0, "E", "W"))
}
