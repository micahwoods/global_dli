# function to make a plot part one

make_chart_2 <- function(normal_data, downloaded_power_data) {
  
  power_C <- normal_data
  
  ### next section comes from start of make_chart_1 also
  
  downloaded_power_data$Rs <- na.approx(downloaded_power_data$ALLSKY_SFC_SW_DWN, na.rm = FALSE)
  
  # convert by AJ 198x article
  downloaded_power_data$dli <- downloaded_power_data$Rs * 2.04
  
  # comvert by recent Hort Science
  #downloaded_power_data$dli <- downloaded_power_data$Rs * 0.45 * 4.48
  
  d3 <- subset(downloaded_power_data, YYYYMMDD < (today() - days(6)))
  
  # label as north or south or east or west for chart output
  north_south <- ifelse(d3$LAT > 0, "N", "S")
  east_west <- ifelse(d3$LON > 0, "E", "W")
  
  # now try to do something where I calculate the mean by week, have start and end days on the week
  # and can then plot as flat lines perhaps colour-coded
  
  d3$wday <- wday(d3$YYYYMMDD, label = TRUE)
  d3$monthName <- month(d3$YYYYMMDD, label = TRUE)
  
  d3$date <- d3$YYYYMMDD 
  
  ###

  normalDLI <- pivot_longer(power_C, JAN:DEC, names_to = "month", values_to = "Rs")
  normalDLI$monthNum <- 1:12
  normalDLI$dli_climatology <- normalDLI$Rs * 2.04
  
  d3$monthCenter <- ymd(paste(d3$YEAR, d3$MM, 1))
  
  dli_monthly <- d3 %>%
    group_by(monthCenter, MM) %>%
    summarise(avg_last_year = mean(dli, na.rm = TRUE),
              min = min(dli, na.rm = TRUE),
              max = max(dli, na.rm = TRUE))
  
  dli_monthly$custom_order <- 1:length(dli_monthly$MM)
  
  dli_monthly_plot <- merge(dli_monthly, normalDLI, by.x = "MM", by.y = "monthNum")
  
  # for labeling the lines, find the largest monthly difference
  dli_monthly_plot$diff <- dli_monthly_plot$avg_last_year - dli_monthly_plot$dli_climatology
  dli_monthly_plot$abs_diff <- abs(dli_monthly_plot$diff)
  xRow <- subset(dli_monthly_plot, abs_diff == max(abs_diff))
  
  custom_hjust <- ifelse(xRow$custom_order > 6, 1, 0)
  custom_yjustRecent <- ifelse(xRow$diff > 0, 10, -10)
  custom_yjustClimate <- ifelse(xRow$diff < 0, 10, -10)
  
  click <- data_frame(lon = as.numeric(power_C$LON),
                      lat = as.numeric(power_C$LAT))
  
  showNotification("Making chart of monthly actual vs. normal")
  
  p2 <- ggplot(data = dli_monthly_plot, aes(x = monthCenter, y = avg_last_year))
  monthPlot <- p2 + theme_cowplot(font_family = "Roboto Condensed") +
    background_grid() +
    geom_line(colour = "#1b9e77", alpha = 0.5) +
    geom_point(shape = 1, colour = "#1b9e77") +
    geom_line(aes(x = monthCenter, y = dli_climatology), colour = "#d95f02", alpha = 0.5) +
    geom_point(aes(x = monthCenter, y = dli_climatology), colour = "#d95f02", shape = 2) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          axis.title.x = element_blank(),
          plot.caption = element_text(size = 8),
          legend.position = "none",
          plot.background = element_rect(fill = "#f7ffed", color = NA)) +
    labs(y = expression(paste("Mean DLI, mol ", m^{-2}, " ", d^{-1})),
         title = "Average DLI by month",
         subtitle = paste("at ",
                          formatC(abs(click$lat), digits = 1, format = "f"),  "° ", north_south, " & ",
                          formatC(abs(click$lon), digits = 1, format = "f"), "° ", east_west, sep = "")) +
    scale_y_continuous(limits = c(0, NA),
                       breaks = seq(0, 70, 10),
                       expand = expansion(mult = c(0, .1))) +
    scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") +
    annotate("label", x = xRow$monthCenter, hjust = custom_hjust, y = xRow$avg_last_year + custom_yjustRecent,
             family = "Roboto Condensed", colour = "#1b9e77", alpha = 0.5,
             label = "Monthly average DLI\nover the past year") +
    annotate("label", x = xRow$monthCenter, hjust = custom_hjust, y = xRow$dli_climatology + custom_yjustClimate,
             family = "Roboto Condensed", colour = "#d95f02", alpha = 0.5,
             label = "Climatological\nnormal DLI")
  
  monthPlot
}
  