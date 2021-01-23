# mapshot function to download a square image centered on the
# coordinates selected by the user

map_image <- function(location) {

            mapshot(proxy,
                 remove_controls = c("zoomControl", "layersControl", "homeButton", "scaleBar",
                                 "drawToolbar", "easyButton", "searchControl"),
                  file = outfile)
}

