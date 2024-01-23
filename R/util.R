# load libraries
# for this app
# 
# if (is.null(suppressMessages(webshot:::find_phantom()))) {
#   webshot::install_phantomjs()
# }

# ## locally set browser path
# Sys.setenv(CHROMOTE_CHROME = "/usr/bin/brave-browser")
# 
# ## setup to be able to use mapshot2 based on
# ## https://community.rstudio.com/t/how-to-properly-configure-google-chrome-on-shinyapps-io-because-of-webshot2/109020/4
# message(curl::curl_version()) # check curl is installed
# if (identical(Sys.getenv("R_CONFIG_ACTIVE"), "shinyapps")) {
#   chromote::set_default_chromote_object(
#     chromote::Chromote$new(chromote::Chrome$new(
#       args = c("--disable-gpu",
#                "--no-sandbox",
#                "--disable-dev-shm-usage", # required bc the target easily crashes
#                c("--force-color-profile", "srgb"))
#     ))
#   )
# }


library(shiny)
# library(pagedown)
# library(chromote)
# library(curl)
library(leaflet)
library(leaflet.extras)
library(nasapower)
library(ggplot2)
library(cowplot)
## library(leaflet.esri)
library(plyr)
library(dplyr)
library(lubridate)
library(zoo)
library(tidyr)
library(patchwork)
library(mapview)
## library(webshot)
## library(webshot2)
library(shinyFeedback)
library(png)
library(magick)
library(shinycssloaders)
library(ggpmisc)
library(tibble)

atc_style <- "color: #fff; background-color: #3f7300; border-color: #fff"

atc2_style <- "color: #fff; background-color: #730B29; border-color: #fff"

