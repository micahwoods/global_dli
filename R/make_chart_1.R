## chart 1: daily DLI for the past 52 weeks, with weekly averages

make_chart_1 <- function(downloaded_power_data) {

  id1 <- showNotification("Building chart of DLI for the past year",
                          duration = NULL, closeButton = FALSE, type = "warning")
  on.exit(removeNotification(id1), add = TRUE)

  d3 <- prep_dli(downloaded_power_data)
  d3$dliColour <- dli_class(d3$dli)
  d3$dayCount  <- seq_len(nrow(d3))

  lat <- d3$LAT[1]
  lon <- d3$LON[1]

  ## weekly averages, drawn as flat bars from the first to last day of each week
  dli_weekly <- d3 %>%
    group_by(weekCount) %>%
    summarise(avg = mean(dli, na.rm = TRUE),
              start = min(date),
              end = max(date),
              .groups = "drop")

  dli_table_data <- dli_weekly %>%
    count(`DLI range` = dli_range_label(avg), name = "Weeks")

  dli_weekly2 <- pivot_longer(dli_weekly, cols = start:end, values_to = "date")
  dli_weekly2$level3040 <- dli_class(dli_weekly2$avg)

  ## put the table near the middle of the summer (when DLI is high, so the
  ## table at the bottom of the chart doesn't cover points)
  target_doy <- if (lat >= 0) 140 else 330
  table_x <- d3$date[which.min(abs(d3$DOY - target_doy))]

  minDay <- d3[which.min(d3$dli), ]
  maxDay <- d3[which.max(d3$dli), ]

  min_hjust <- if (minDay$dayCount < 183) 0 else 1
  max_hjust <- if (maxDay$dayCount < 183) 0 else 1
  min_arrow <- if (min_hjust == 0) c(40, 2) else c(-40, -2)
  max_arrow <- if (max_hjust == 0) c(40, 2) else c(-40, -2)

  label_min <- sprintf("Minimum~DLI~was~%s~on~%s~%s~%s~%s",
                       formatC(minDay$dli, digits = 1, format = "f"),
                       minDay$wday, minDay$DD, minDay$monthName, minDay$YEAR)

  label_max <- sprintf("Maximum~DLI~was~%s~on~%s~%s~%s~%s",
                       formatC(maxDay$dli, digits = 1, format = "f"),
                       maxDay$wday, maxDay$DD, maxDay$monthName, maxDay$YEAR)

  ## watermark
  logo_file <- image_read("www/atc_t.png")

  ggplot(data = d3, aes(x = date, y = dli)) +
    theme_cowplot(font_family = "Roboto Condensed") +
    background_grid() +
    annotate(geom = "table", x = table_x, y = 0,
             family = "Roboto Condensed", size = 3,
             fill = app_bg, alpha = 0.5,
             label = dli_table_data) +
    geom_line(data = dli_weekly2,
              aes(x = date, y = avg, group = weekCount, colour = level3040),
              linewidth = 1) +
    geom_point(aes(colour = dliColour), shape = 1) +
    scale_y_continuous(limits = c(0, NA),
                       breaks = seq(0, 70, 10),
                       expand = expansion(mult = c(0, .1))) +
    scale_color_brewer(palette = "Paired", limits = letters[1:7]) +
    scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") +
    theme(axis.text.x = element_text(angle = 35, hjust = 1),
          axis.title.x = element_blank(),
          plot.caption = element_text(size = 8),
          legend.position = "none",
          plot.background = element_rect(fill = app_bg, color = NA)) +
    labs(y = expression(paste("DLI, mol ", m^{-2}, " ", d^{-1})),
         title = "Daily light integral (DLI)",
         subtitle = paste0("for the past 52 weeks at ", format_latlon(lat, lon),
                           ". Circles are daily DLI; horizontal bars are weekly averages."),
         caption = "These data were obtained from the NASA Langley Research Center POWER Project funded through the NASA Earth Science Directorate Applied\nScience Program: power.larc.nasa.gov using the 'nasapower' R package by Adam Sparks. This chart generated at asianturfgrass.shinyapps.io/global_dli/") +
    annotate("label", x = minDay$date, hjust = min_hjust, y = minDay$dli + 9, alpha = 0.4,
             family = "Roboto Condensed", size = 3.5, colour = "grey15",
             label = label_min, parse = TRUE, label.size = 0) +
    annotate("segment", x = minDay$date + days(min_arrow[1]), xend = minDay$date + days(min_arrow[2]),
             y = minDay$dli + 7.8, yend = minDay$dli + 0.3, linewidth = 0.5, colour = "grey15",
             arrow = arrow(type = "closed", length = unit(0.25, "cm"))) +
    annotate("label", x = maxDay$date, hjust = max_hjust, y = maxDay$dli + 5, alpha = 0.4,
             family = "Roboto Condensed", size = 3.5, colour = "grey15",
             label = label_max, parse = TRUE, label.size = 0) +
    annotate("segment", x = maxDay$date + days(max_arrow[1]), xend = maxDay$date + days(max_arrow[2]),
             y = maxDay$dli + 3.7, yend = maxDay$dli + 0.3, linewidth = 0.5, colour = "grey15",
             arrow = arrow(type = "closed", length = unit(0.25, "cm"))) +
    draw_image(logo_file, x = median(d3$date) + days(45), y = (max(d3$dli) + min(d3$dli)) / 2,
               scale = 100)
}
