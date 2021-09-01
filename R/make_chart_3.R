# make chart 3 (the rectangle on map of selected point)

make_chart_3 <- function(x) {
 
  id5 <- showNotification("Preparing chart for download", 
                          duration = NULL, closeButton = FALSE, type = "warning")
  on.exit(removeNotification(id5), add = TRUE)
 
  img <-  image_read(x)
  
  map_plot <- ggdraw() + 
    draw_image(img, scale = 1.4,
               vjust = 0.25,
               hjust = 0.05)
  
  map_plot
  
}

