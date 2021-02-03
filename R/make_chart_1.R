# function to make a plot part one

make_chart_1 <- function(downloaded_power_data) {
  
  id1 <- showNotification("Building chart of DLI for the past year", 
                         duration = NULL, closeButton = FALSE, type = "warning")
  on.exit(removeNotification(id1), add = TRUE)
  
  
  ### debug
  
  # downloaded_power_data <- loc_power
  
  ###
  
  # rule = 2 here fills in the trailing na.rm
  downloaded_power_data$Rs <- na.approx(downloaded_power_data$ALLSKY_SFC_SW_DWN, na.rm = FALSE, rule = 2)
  # convert by AJ 198x article
 # downloaded_power_data$dli <- downloaded_power_data$Rs * 2.04
  
  # comvert by recent Hort Science
  downloaded_power_data$dli <- downloaded_power_data$Rs * 0.45 * 4.48
  
  d3 <- subset(downloaded_power_data, YYYYMMDD < (today() - days(6)))
  
  # label as north or south or east or west for chart output
  north_south <- ifelse(d3$LAT > 0, "N", "S")
  east_west <- ifelse(d3$LON > 0, "E", "W")
  
  # now try to do something where I calculate the mean by week, have start and end days on the week
  # and can then plot as flat lines perhaps colour-coded
  
  d3$wday <- wday(d3$YYYYMMDD, label = TRUE)
  d3$monthName <- month(d3$YYYYMMDD, label = TRUE)
  
  d3$date <- d3$YYYYMMDD 
  
  d3$weekCount <- rep(1:52, each = 7)
  
  dli_weekly <- d3 %>%
    group_by(weekCount) %>%
    summarise(avg = mean(dli, na.rm = TRUE),
              start = min(date),
              end = max(date))
  
  # count the weeks in each level
  dli_weekly$dli_level <- ifelse(dli_weekly$avg < 10, "0 to 10",
                                 ifelse(dli_weekly$avg >= 10 & dli_weekly$avg < 20, "10 to 20",
                                        ifelse(dli_weekly$avg >= 20 & dli_weekly$avg < 30, "20 to 30",
                                               ifelse(dli_weekly$avg >= 30 & dli_weekly$avg < 40, "30 to 40",
                                                      ifelse(dli_weekly$avg >= 40 & dli_weekly$avg < 50, "40 to 50",
                                                             ifelse(dli_weekly$avg >= 50 & dli_weekly$avg < 60, "50 to 60", 
                                                                    "60 to 70"))))))
  
  dli_table_data <- dli_weekly %>%
    group_by(dli_level) %>%
    tally()
  
  colnames(dli_table_data) <- c("DLI range", "Weeks")
  
  lat <- d3$LAT[1]
  # set the table location to be approx middle of the summer in temperate places
  
  if(lat >= 0) {
    table_x_loc <- d3 %>%
      filter(DOY == 170) %>%
      slice_min(order_by = YYYYMMDD)
    
   
  } else { 
    table_x_loc <- d3 %>%
      filter(DOY == 360) %>%
      slice_min(order_by = YYYYMMDD)
  }
                                                                  
  
  dli_weekly2 <- pivot_longer(dli_weekly, cols = start:end, values_to = "date")
  
  dli_weekly2$level3040 <- ifelse(dli_weekly2$avg >= 60, "g",
                                  ifelse(dli_weekly2$avg < 60 & dli_weekly2$avg >= 50, "f",
                                         ifelse(dli_weekly2$avg < 50 & dli_weekly2$avg >= 40, "e",
                                                ifelse(dli_weekly2$avg < 40 & dli_weekly2$avg >= 30, "d",
                                                       ifelse(dli_weekly2$avg < 30 & dli_weekly2$avg >= 20, "c",
                                                              ifelse(dli_weekly2$avg < 20 & dli_weekly2$avg >= 10, "b", "a"))))))
  
  d3$dliColour <- ifelse(d3$dli >= 60, "g",
                         ifelse(d3$dli < 60 & d3$dli >= 50, "f",
                                ifelse(d3$dli < 50 & d3$dli >= 40, "e",
                                       ifelse(d3$dli < 40 & d3$dli >= 30, "d",
                                              ifelse(d3$dli < 30 & d3$dli >= 20, "c",
                                                     ifelse(d3$dli < 20 & d3$dli >= 10, "b", "a"))))))
  
  # identify the min and max days of the year
  d3$dayCount <- 1:length(d3$YYYYMMDD)
  
minDaySet <- subset(d3, dli == min(d3$dli))
minDay <- minDaySet[1, ]
#   
# if (length(minDaySet$date) > 1) {
#   minDay <- minDaySet[, 1]
# }
#   else {
#     minDay <- minDaySet
#   }
#   
maxDaySet <- subset(d3, dli == max(d3$dli))
maxDay <- maxDaySet[1, ]
#   
# if(length(maxDaySet$date) > 1){
#                maxDay <-  maxDaySet[1, ]
# }
# else{
#                maxDay <-   maxDaySet
#   }
  
  weekLabelMin <- dli_weekly2 %>%
    slice_min(order_by = avg, with_ties = FALSE, n = 1)
  
  weekLabelMax <- dli_weekly2 %>%
    slice_max(order_by = avg, with_ties = FALSE, n = 1)
  
  weekLabelMinText <- sprintf("Minimum~weekly~average~DLI~was~%s", 
                              formatC(weekLabelMin$avg, digits = 1, format = "f"))
  
  weekLabelMaxText <- sprintf("Maximum~weekly~average~DLI~was~%s", 
                              formatC(weekLabelMax$avg, digits = 1, format = "f"))
  
  weekLabelMin$hjustSet <- ifelse(weekLabelMin$weekCount < 10, 0,
                                 ifelse(weekLabelMin$weekCount > 42, 1, 0.5))
  
  weekLabelMax$hjustSet <- ifelse(weekLabelMax$weekCount < 10, 0,
                                   ifelse(weekLabelMax$weekCount > 42, 1, 0.5))
  
  
  min_hjust <- ifelse(minDay$dayCount < 183, 0, 1)
  max_hjust <- ifelse(maxDay$dayCount < 183, 0, 1)
  
  min_arrow_start <- ifelse(min_hjust == 0, 40, -40)
  min_arrow_end <- ifelse(min_hjust == 0, 2, -2)
  
  max_arrow_start <- ifelse(max_hjust == 0, 40, -40)
  max_arrow_end <- ifelse(max_hjust == 0, 2, -2)
  
  label_min <- sprintf("Minimum~DLI~was~%s~on~%s~%s~%s~%s", 
                       formatC(minDay$dli, digits = 1, format = "f"),
                       minDay$wday,
                       minDay$DD,
                       minDay$monthName,
                       minDay$YEAR)
  
  label_max <- sprintf("Maximum~DLI~was~%s~on~%s~%s~%s~%s", 
                       formatC(maxDay$dli, digits = 1, format = "f"),
                       maxDay$wday,
                       maxDay$DD,
                       maxDay$monthName,
                       maxDay$YEAR)
  
  # I want to add my watermark here
  logo_file <- image_read("www/atc_t.png")

  # plot dli
  p <- ggplot(data = d3, aes(x = date, y = dli))
  dli <- p + theme_cowplot(font_family = "Roboto Condensed") +
    background_grid() +
    annotate(geom = "table", x = table_x_loc$YYYYMMDD, y = 0,
             family = "Roboto Condensed", size = 3,
             fill = "#f7ffed",
             alpha = 0.5,
             label = dli_table_data) +
    geom_line(data = dli_weekly2,
              aes(x = date, y = avg, 
                  group = weekCount, colour = level3040),
              size = 1) +
    scale_y_continuous(limits = c(0, NA),
                       breaks = seq(0, 70, 10),
                       expand = expansion(mult = c(0, .1))) +
    scale_color_brewer(palette = "Paired") +
    geom_point(aes(colour = dliColour), 
               shape = 1) +
    scale_x_date(date_breaks = "1 month") +
    theme(axis.text.x = element_text(angle = 35, hjust = 1),
          axis.title.x = element_blank(),
          plot.caption = element_text(size = 8),
          legend.position = "none",
          plot.background = element_rect(fill = "#f7ffed", color = NA)) +
    labs(y = expression(paste("DLI, mol ", m^{-2}, " ", d^{-1})),
         title = "Daily light integral (DLI)",
         subtitle = paste("for the past 52 weeks at ",
                          formatC(abs(d3$LAT), digits = 1, format = "f"),  "° ", north_south, " & ",
                          formatC(abs(d3$LON), digits = 1, format = "f"), "° ", east_west, sep = ""),
         caption = "These data were obtained from the NASA Langley Research Center POWER Project funded through the NASA Earth Science Directorate\nApplied Science Program: power.larc.nasa.gov using the 'nasapower' R package by Adam Sparks") +
    annotate("label", x = minDay$date, hjust = min_hjust, y = minDay$dli + 9, alpha = 0.4,
             family = "Roboto Condensed", size = 3.5, colour = "grey15",
             label = label_min, parse = TRUE, label.size = 0) +
    annotate("segment", x = minDay$date + days(min_arrow_start), xend = minDay$date + days(min_arrow_end), 
             y = minDay$dli + 7.8, yend = minDay$dli + 0.3, size = 0.5, colour = "grey15",
             arrow=arrow(type = 'closed', length = unit(0.25, 'cm'))) +
    annotate("label", x = maxDay$date, hjust = max_hjust, y = maxDay$dli + 5, alpha = 0.4,
             family = "Roboto Condensed", size = 3.5, colour = "grey15",
             label = label_max, parse = TRUE, label.size = 0) +
    annotate("segment", x = maxDay$date + days(max_arrow_start), xend = maxDay$date + days(max_arrow_end), 
             y = maxDay$dli + 3.7, yend = maxDay$dli + 0.3, size = 0.5, colour = "grey15",
             arrow=arrow(type = 'closed', length = unit(0.25, 'cm'))) +
    annotate("label", x = min(dli_weekly2$date), hjust = 0, y = 6,
             family = "Roboto Condensed", size = 3.5, colour = "grey15", alpha = 0.4,
             label = "Horizontal bars show\nweekly average DLI", label.size = 0) +
    draw_image(logo_file, x = median(d3$YYYYMMDD) + days(45), y = (max(d3$dli) + min(d3$dli)) / 2, 
      scale = 100)
    
 dli
}
