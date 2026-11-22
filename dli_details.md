
### Daily light integral (DLI)

The DLI is all the photosynthetically active radiation (PAR) at a location on the earth's surface, summed from sunrise until sunset. 

The units are moles of photons per square meter per day --- mol m<sup>-2</sup> d<sup>-1</sup>.

### Where these data come from

The [NASA POWER](https://power.larc.nasa.gov/docs/methodology/communities/ag/) agroclimatology dataset provides satellite data of many useful solar and meteorological parameters. One of these is **all sky surface total PAR** (from CERES SYN1deg), which, like the other solar parameters, is on a 1° x 1° grid with cell edges on whole degrees of latitude and longitude. Every point in the same 1° cell, such as anywhere from 13° to 14° N and 100° to 101° E, gets the same data. PAR is given in megajoules of PAR per square meter per day, MJ m<sup>-2</sup> d<sup>-1</sup>.

To convert PAR from energy to photons, I multiply it by 4.48 mol of photons per MJ of PAR, the conversion used by [Faust and Logan (2018)](https://dx.doi.org/10.21273/HORTSCI13144-18). So the DLI in this app is the NASA POWER PAR multiplied by 4.48. The climatological normal DLI is calculated the same way, from the NASA POWER PAR climatology (2001–2025).

There's one complication. NASA POWER's PAR data are usually about 3 months behind, while its **all sky insolation incident on a horizontal surface**, which is global solar radiation (R<sub>s</sub>), is only about a week behind. For the most recent days, which have R<sub>s</sub> but no PAR yet, I estimate PAR as R<sub>s</sub> multiplied by the PAR fraction for that location at the same time of year, one year earlier: the total PAR divided by the total R<sub>s</sub> over the 61 days centered on that date a year before. The chart caption says from which date the DLI is estimated this way.

Why not just use a fixed fraction? PAR is often given as about 45% of R<sub>s</sub>. I've often used a conversion factor of 2.04 (multiplying R<sub>s</sub> by 2.04 to get the DLI in mol m<sup>-2</sup> d<sup>-1</sup>) based on [Meek et al. (1984)](https://doi.org/10.2134/agronj1984.00021962007600060018x), and Faust and Logan used 0.45 × 4.48 = 2.01. That's close on average, but the fraction varies. In the NASA POWER data it ranges from about 0.44 in deserts to 0.48 in the humid tropics, and from about 0.42 to 0.54 from one day to the next, because cloudy days have more diffuse light, which has more PAR in it. When I tested the estimate by hiding 83 days of known PAR at 7 locations in 4 seasons, the estimated PAR over those days was within 1.1% on average (3.3% at worst), compared with 3.2% on average for a fixed 0.45.

### How I got the data

I used the [`nasapower`](https://docs.ropensci.org/nasapower/index.html) package (in [`R`](https://www.r-project.org/) software) to obtain the data. The `nasapower` package is maintained by [Adam Sparks](https://orcid.org/0000-0002-0061-8359).

This is a [Shiny](https://shiny.rstudio.com/) app and I used the [`leaflet`](https://cran.r-project.org/web/packages/leaflet/index.html) package for the map in the app.

Any missing data have been approximated using the `na.approx` function from the `zoo` package. Only short gaps (up to 3 days in a row) are filled this way. The NASA POWER global solar radiation data are usually available up to about a week before the current date, and the charts show the 364 days (exactly 52 weeks) ending on the most recent day with data.

There are [different ways to deal with weeks](https://en.wikipedia.org/wiki/ISO_week_date), and what I have done in this app is calculate them as 7 days periods that begin with the first day in the 364 days of data shown.

### For more information

- The code for this app is at <https://github.com/micahwoods/global_dli>.

- Please file any bug reports or feature requests at <https://github.com/micahwoods/global_dli/issues>.

- [Light](https://paceturf.org/search/?q=light) on the PACE Turf website.

- Posts tagged [light](https://www.asianturfgrass.com/tag/light/) on the ATC website

- [NASA Power](https://power.larc.nasa.gov/)

- [Instantaneous PAR app](https://asianturfgrass.shinyapps.io/ppfd_by_time/) based on time of day and location. You can get full sun PPFD and DLI for any location with this app.


