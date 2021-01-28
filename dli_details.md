
### Daily light integral (DLI)

The DLI is all the photosynthetically active radiation (PAR) at a location on the earth's surface, summed from sunrise until sunset. 

The units are moles of photons per square meter per day --- mol m<sup>-2</sup> d<sup>-1</sup>.

### Where these data come from

The [NASA POWER](https://power.larc.nasa.gov/docs/methodology/communities/ag/) agroclimatology dataset provides satellite data of many useful solar and meteorological parameters on a 0.5° x 0.5° grid, including **all sky insolation incident on a horizontal surface**, which is global solar radiation (R<sub>s</sub>). On a daily basis, the units for R<sub>s</sub> are megajoules per square meter per day, MJ m<sup>-2</sup> d<sup>-1</sup>. 

There is a consistent proportion of PAR in R<sub>s</sub>. I've often used a conversion factor of 2.04 (multiplying R<sub>s</sub> by 2.04 to get the DLI in mol m<sup>-2</sup> d<sup>-1</sup>) based on [Meek et al. (1984)](https://doi.org/10.2134/agronj1984.00021962007600060018x). In this app, I've used the same conversion as was used by [Faust and Logan (2018)](https://dx.doi.org/10.21273/HORTSCI13144-18), "which assumes that 45% of the solar radiation is in the photosynthetically active radiation (PAR, 400–700 nm) region and 4.48 μmol J<sup>−1</sup> is the conversion from radiometric to quantum units." That works out to be a 2.01 conversion factor, rather than 2.04. Basically, you can multiply R<sub>s</sub> by 2 and be really close to the DLI.

The data I show in this app as DLI are the NASA POWER **all sky insolation incident on a horizontal surface** (R<sub>s</sub>) data multiplied by 0.45 and then by 4.48.

### How I got the data

I used the [`nasapower`](https://docs.ropensci.org/nasapower/index.html) package (in [`R`](https://www.r-project.org/) software) to obtain the data. The `nasapower` package is maintained by [Adam Sparks](https://orcid.org/0000-0002-0061-8359).

This is a [Shiny](https://shiny.rstudio.com/) app and I used the [`leaflet`](https://cran.r-project.org/web/packages/leaflet/index.html) package for the map in the app.

Any missing data have been approximated using the `na.approx` function from the `zoo` package. I haven't seen a lot of missing values but that is run after the data are downloaded. The NASA POWER global solar radiation data are usually available up to about 5 days prior to the current date. This app is getting data from 370 days ago until 6 days ago, which is a total of 364 days, and is exactly 52 weeks. Those 364 days (52 weeks) of data are shown on the charts.

There are [different ways to deal with weeks](https://en.wikipedia.org/wiki/ISO_week_date), and what I have done in this app is calculate them as 7 days periods that begin with the first day in the 364 days of data shown.

### For more information

- Posts tagged [light](https://www.asianturfgrass.com/tag/light/) on the ATC website

- [NASA Power](https://power.larc.nasa.gov/)

- [Instantaneous PAR app](https://asianturfgrass.shinyapps.io/ppfd_by_time/) based on time of day and location. I'm going to update that one sometime to make it easier to input your location. Like with a map.

- [Asian Turfgrass Center](https://www.asianturfgrass.com/)