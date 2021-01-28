# load libraries
# for this app

if (is.null(suppressMessages(webshot:::find_phantom()))) {
  webshot::install_phantomjs()
}

library(shiny)
library(leaflet)
library(nasapower)
library(ggplot2)
library(cowplot)
library(leaflet.esri)
library(plyr)
library(dplyr)
library(lubridate)
library(zoo)
library(tidyr)
library(patchwork)
library(mapview)
library(shinyFeedback)
library(png)
library(magick)
library(shinycssloaders)
# library(shinyjs)
library(ggpmisc)



atc_style <- "color: #fff; background-color: #3f7300; border-color: #fff"

atc2_style <- "color: #fff; background-color: #730B29; border-color: #fff"

