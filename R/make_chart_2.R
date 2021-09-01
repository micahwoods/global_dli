## function to make a second plot

make_chart_2 <- function(normal_data, downloaded_power_data) {
  
  id3 <- showNotification("Building chart of climatological normal DLI", 
                          duration = NULL, closeButton = FALSE, type = "warning")
  on.exit(removeNotification(id3), add = TRUE)
  
  power_C <- normal_data
  
  ### next section comes from start of make_chart_1 also
  ## the missing data for ALL_SKY_SFC_SW_DWN are -999. Set these to NA
  downloaded_power_data$ALLSKY_SFC_SW_DWN <- ifelse(downloaded_power_data$ALLSKY_SFC_SW_DWN == -999.00,
                                                    NA,
                                                    downloaded_power_data$ALLSKY_SFC_SW_DWN)
  # do the rule = 2 here to fill NA at the end
  downloaded_power_data$Rs <- na.approx(downloaded_power_data$ALLSKY_SFC_SW_DWN, na.rm = FALSE, rule = 2)
  
  # convert by AJ 198x article
#  downloaded_power_data$dli <- downloaded_power_data$Rs * 2.04
  
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
  
  ###

  normalDLI <- pivot_longer(power_C, JAN:DEC, names_to = "month", values_to = "Rs")
  normalDLI$monthNum <- 1:12
  normalDLI$dli_climatology <- normalDLI$Rs * 2.04
  
  d3$monthCenter <- ymd(paste(d3$YEAR, d3$MM, 1))
  
  dli_monthly <- d3 %>%
    group_by(monthCenter, MM) %>%
    summarise(avg_last_year = mean(dli, na.rm = TRUE),
              n = length(dli))
  
  dli_monthly$custom_order <- 1:length(dli_monthly$MM)
  
  dli_monthly_plot <- merge(dli_monthly, normalDLI, by.x = "MM", by.y = "monthNum")
  
  # get the total difference of annual mean
  diffFromNormal <- mean(d3$dli) - (power_C$ANN * 0.45 * 4.48)
  
  percentDiff <- abs(diffFromNormal / power_C$ANN) * 100
  
  more_or_less <- ifelse(diffFromNormal > 0, "above", "less than")
  
  label_norm <- sprintf("Average DLI (green) for the\npast year was %s,\n%s%% %s normal (orange)", 
                       formatC(mean(dli_monthly$avg_last_year), digits = 1, format = "f"),
                       formatC(percentDiff, digits = 2, format = "g"),
                       more_or_less)
  
  click <- tibble(lon = as.numeric(power_C$LON),
                  lat = as.numeric(power_C$LAT))
  
  # this puts the x location of the text about avg DLI in past year
  # to be in the summer season, so presumably below the DLI lines
  # and for normal label, in winter, presumably above
  
  if(click$lat >= 0) {
    label_x_loc <- dli_monthly_plot %>%
      filter(MM == 6) %>%
      slice_min(order_by = monthCenter)
    
    normal_label_x <- dli_monthly_plot %>%
      filter(MM == 12) %>%
      slice_max(order_by = monthCenter)
  } else { 
    label_x_loc <- dli_monthly_plot %>%
      filter(MM == 12) %>%
      slice_min(order_by = monthCenter)
    
    normal_label_x <- dli_monthly_plot %>%
      filter(MM == 6) %>%
      slice_max(order_by = monthCenter)
  }
  
    
    x_loc_hjust <- ifelse(label_x_loc$custom_order < 4, 0,
                          ifelse(label_x_loc$custom_order > 8, 1, 0.5))
    
    normal_label_hjust <- ifelse(normal_label_x$custom_order < 4, 0,
                                 ifelse(normal_label_x$custom_order > 8, 1, 0.5))
    
    # get min and max months over the past year but exclude incomplete ones
    max_month <- dli_monthly_plot %>%
      filter(n >= 28) %>%
      slice_max(order_by = avg_last_year, with_ties = FALSE, n = 1) 
    
    min_month <- dli_monthly_plot %>%
      filter(n >= 28) %>%
      slice_min(order_by = avg_last_year, with_ties = FALSE, n = 1) 
    
    label_max <- sprintf("Max average DLI of\n%s in %s %s",
                          formatC(max_month$avg_last_year, digits = 1, format = "f"),
                          month(max_month$monthCenter, label = TRUE),
                          year(max_month$monthCenter))
    
    label_min <- sprintf("Min average DLI of\n%s in %s %s",
                         formatC(min_month$avg_last_year, digits = 1, format = "f"),
                         month(min_month$monthCenter, label = TRUE),
                         year(min_month$monthCenter))
    
    max_month_hjust <- ifelse(max_month$custom_order < 4, 0,
                          ifelse(max_month$custom_order > 8, 1, 0.5))
    
    min_month_hjust <- ifelse(min_month$custom_order < 4, 0,
                              ifelse(min_month$custom_order > 8, 1, 0.5))
    
    min_month_y <- ifelse(min_month$avg_last_year < 8, 
                          min_month$avg_last_year + 6,
                          min_month$avg_last_year - 4)
    
    min_month_days_shift <- ifelse(min_month$custom_order <= 6, -20, 20)
  
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
    scale_x_date(date_breaks = "2 months", date_labels = "%b %Y") +
    annotate("label", x = normal_label_x$monthCenter, hjust = normal_label_hjust,
             y = max_month$avg_last_year - 2,
             family = "Roboto Condensed", colour = "#d95f02", alpha = 0.4, size = 2.5,
             label = "Climatological\nnormal DLI", label.size = 0) +
    annotate("label", x = label_x_loc$monthCenter, hjust = x_loc_hjust, vjust = 0,
             y = 0, family = "Roboto Condensed",
             alpha = 0.4, size = 2.5, colour = "grey15",
             label = label_norm, parse = FALSE, label.size = 0) +
    annotate("label", x = max_month$monthCenter, hjust = max_month_hjust, y = max_month$avg_last_year + 6,
             family = "Roboto Condensed", colour = "#1b9e77", alpha = 0.4, size = 2.5,
             label = label_max, label.size = 0) +
    annotate("label", x = min_month$monthCenter + days(min_month_days_shift), hjust = min_month_hjust, y = min_month_y,
             family = "Roboto Condensed", colour = "#1b9e77", alpha = 0.4, size = 2.5,
             label = label_min, label.size = 0) 
  
  monthPlot
}
  


