
### Daily light integral (DLI)

The DLI is all the photosynthetically active radiation (PAR) at a certain point, summed from sunrise until sunset. 

The units are moles of photons per square meter per day, mol m<sup>-2</sup> d<sup>-1</sup>.

### Where the data come from

The [NASA POWER](https://power.larc.nasa.gov/docs/methodology/communities/ag/) provide satellite data of many useful solar and meteorological parameters on a 0.5° x 0.5° grid, including **all sky insolation incident on a horizontal surface**, which is global solar irradiance (R<sub>s</sub>). On a daily basis, the units for R<sub>s</sub> are megajoules per square meter per day, MJ m<sup>-2</sup> d<sup>-1</sup>.

There is a consistent proportion of PAR in R<sub>s</sub>, and multiplying R<sub>s</sub> by 2.04 gives the DLI in mol m<sup>-2</sup> d<sup>-1</sup>.

The data I show here as DLI are the NASA POWER **all sky insolation incident on a horizontal surface** (R<sub>s</sub>) multiplied by 2.04.

### How I got the data

I used the [`nasapower`](https://docs.ropensci.org/nasapower/index.html) package (in [`R`](https://www.r-project.org/) software) to obtain the data. The `nasapower` package is maintained by [Adam Sparks](https://orcid.org/0000-0002-0061-8359).

This is a [Shiny](https://shiny.rstudio.com/) app and I used the [`leaflet`](https://cran.r-project.org/web/packages/leaflet/index.html) package for the map in the app.

### For more information

- Posts tagged [light](https://www.asianturfgrass.com/tag/light/) on the ATC website

- [NASA Power](https://power.larc.nasa.gov/)

- [Instantaneous PAR app](https://asianturfgrass.shinyapps.io/ppfd_by_time/) based on time of day and latitude (PPFD) 

- [Asian Turfgrass Center](https://www.asianturfgrass.com/)