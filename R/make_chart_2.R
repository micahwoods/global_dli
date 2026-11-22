## chart 2: monthly average DLI for the past 12 full months vs the
## climatological normal
##
## The months are the 12 most recent calendar months that the data cover
## completely, so the month the data end in is left out unless the data run
## to its last day. Because POWER lags about a week, early in a month the
## previous month may not be complete yet either; it then joins the chart
## once the data reach its last day.

make_chart_2 <- function(normal_data, downloaded_power_data) {

  id3 <- showNotification("Building chart of climatological normal DLI",
                          duration = NULL, closeButton = FALSE, type = "warning")
  on.exit(removeNotification(id3), add = TRUE)

  ## 12 full months plus a partial month can span up to 397 days, more than
  ## the 364 days that chart 1 uses
  d3 <- prep_dli(downloaded_power_data, n_days = 400)
  months <- last_full_months(d3$date, n = 12)
  d3 <- d3[d3$date >= months[["start"]] & d3$date <= months[["end"]], ]

  lat <- as.numeric(normal_data$LAT[1])
  lon <- as.numeric(normal_data$LON[1])

  ## climatology is PAR in MJ m-2 d-1 by month; convert like the daily data
  if ("PARAMETER" %in% names(normal_data)) {
    normal_data <- normal_data[normal_data$PARAMETER == "ALLSKY_SFC_PAR_TOT", ]
  }
  normalDLI <- pivot_longer(normal_data, JAN:DEC, names_to = "month", values_to = "par")
  normalDLI$monthNum <- 1:12
  normalDLI$dli_climatology <- normalDLI$par * mol_per_MJ_par

  d3$monthCenter <- floor_date(d3$date, "month")

  dli_monthly <- d3 %>%
    group_by(monthCenter, MM) %>%
    summarise(avg_last_year = mean(dli, na.rm = TRUE),
              n = n(),
              .groups = "drop") %>%
    arrange(monthCenter) %>%
    mutate(custom_order = row_number())

  dli_monthly_plot <- dli_monthly %>%
    left_join(select(normalDLI, monthNum, dli_climatology), by = c("MM" = "monthNum"))

  ## past 12 full months vs normal, both as DLI averaged over all the days
  normal_annual <- as.numeric(normal_data$ANN[1]) * mol_per_MJ_par
  past_annual   <- mean(d3$dli)
  percentDiff   <- abs(past_annual - normal_annual) / normal_annual * 100
  more_or_less  <- if (past_annual >= normal_annual) "above" else "below"

  label_norm <- sprintf("Green circles: %s to %s, average DLI %s, %s%% %s normal.\nOrange triangles: climatological normal DLI.",
                        format(months[["start"]], "%b %Y"), format(months[["end"]], "%b %Y"),
                        formatC(past_annual, digits = 1, format = "f"),
                        formatC(percentDiff, digits = 1, format = "f"),
                        more_or_less)

  position_hjust <- function(order) ifelse(order < 4, 0, ifelse(order > 8, 1, 0.5))

  ## min and max months (all 12 are complete months)
  max_month <- slice_max(dli_monthly_plot, order_by = avg_last_year, with_ties = FALSE, n = 1)
  min_month <- slice_min(dli_monthly_plot, order_by = avg_last_year, with_ties = FALSE, n = 1)

  label_max <- sprintf("Max average DLI of\n%s in %s %s",
                       formatC(max_month$avg_last_year, digits = 1, format = "f"),
                       month(max_month$monthCenter, label = TRUE),
                       year(max_month$monthCenter))

  label_min <- sprintf("Min average DLI of\n%s in %s %s",
                       formatC(min_month$avg_last_year, digits = 1, format = "f"),
                       month(min_month$monthCenter, label = TRUE),
                       year(min_month$monthCenter))

  ## min label goes above the point if it is near the bottom, otherwise below
  min_month_y <- if (min_month$avg_last_year < 12) min_month$avg_last_year + 7
                 else min_month$avg_last_year - 5

  ggplot(data = dli_monthly_plot, aes(x = monthCenter, y = avg_last_year)) +
    theme_cowplot(font_family = "Roboto Condensed") +
    background_grid() +
    geom_line(colour = "#1b9e77", alpha = 0.5) +
    geom_point(shape = 1, colour = "#1b9e77") +
    geom_line(aes(y = dli_climatology), colour = "#d95f02", alpha = 0.5) +
    geom_point(aes(y = dli_climatology), colour = "#d95f02", shape = 2) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          axis.title.x = element_blank(),
          plot.caption = element_text(size = 8, hjust = 0, colour = "grey15"),
          plot.caption.position = "plot",
          legend.position = "none",
          plot.background = element_rect(fill = app_bg, color = NA)) +
    labs(y = expression(paste("Mean DLI, mol ", m^{-2}, " ", d^{-1})),
         title = "Average DLI by month",
         subtitle = paste("in the 1° grid cell", format_cell(lat, lon, compact = TRUE)),
         caption = label_norm) +
    scale_y_continuous(limits = c(0, NA),
                       breaks = seq(0, 70, 10),
                       expand = expansion(mult = c(0, .15))) +
    scale_x_date(date_breaks = "2 months", date_labels = "%b %Y") +
    annotate("label", x = max_month$monthCenter, hjust = position_hjust(max_month$custom_order),
             y = max_month$avg_last_year + 6,
             family = "Roboto Condensed", colour = "#1b9e77", alpha = 0.4, size = 2.5,
             label = label_max, label.size = 0) +
    annotate("label", x = min_month$monthCenter, hjust = position_hjust(min_month$custom_order),
             y = min_month_y,
             family = "Roboto Condensed", colour = "#1b9e77", alpha = 0.4, size = 2.5,
             label = label_min, label.size = 0) 
  
}

# first and last day of the n most recent calendar months that dates covers
# completely, as c(start = , end = ) Dates. The last month is the month of the
# last date if that is the month's last day, otherwise the month before.
last_full_months <- function(dates, n = 12) {
  last_day <- max(dates)
  end   <- floor_date(last_day + days(1), "month") - days(1)
  start <- floor_date(end, "month") %m-% months(n - 1)
  if (min(dates) > start) {
    stop(sprintf("need data from %s for %d full months, but the data start on %s",
                 format(start), n, format(min(dates))))
  }
  c(start = start, end = end)
}
