# make chart 3

make_chart_3 <- function(x) {
 
  id5 <- showNotification("Preparing chart for download", 
                          duration = NULL, closeButton = FALSE, type = "warning")
  on.exit(removeNotification(id5), add = TRUE)
  # map_plot <- ggdraw() + 
  #   draw_image((x), scale = 1) +
  #   theme(axis.title.x = element_blank(),
  #         plot.caption = element_blank(),
  #         axis.text.x = element_blank())
  # 
  # map_plot  
  
#  x <- filename
  img <-  image_read(x)
  
 #    image_resize("480x540") 
  
  map_plot <- ggdraw() + 
    draw_image(img, scale = 1.4,
               vjust = 0.25,
               hjust = 0.05)
  
  map_plot
  
}

