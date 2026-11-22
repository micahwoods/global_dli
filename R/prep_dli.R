# clean the daily NASA POWER download and convert it to DLI
#
# Returns the most recent 52 weeks (364 days) of data, ending on the last day
# NASA POWER has a value for, plus date helper columns. Shared by
# make_chart_1() and make_chart_2().
#
# DLI is NASA POWER's all-sky surface PAR (MJ m-2 d-1) times mol_per_MJ_par.
# POWER's PAR lags about 3 months behind its global solar radiation (Rs), so
# the recent days with Rs but no PAR are estimated by fill_par(). Column
# par_estimated marks those days.
#
# The end date comes from the data, not from a fixed offset from today: the
# lag varies, and days past the end of the available data come back as NA
# (or -999 in older versions of nasapower).
#
# Missing days inside the window are interpolated, but only short gaps (up to
# max_gap days in a row). Longer gaps stop with an error rather than draw a
# made-up straight line.

prep_dli <- function(downloaded_power_data, n_days = 364, max_gap = 3) {

  d <- downloaded_power_data
  d <- d[order(d$YYYYMMDD), ]
  d$ALLSKY_SFC_SW_DWN[d$ALLSKY_SFC_SW_DWN %in% -999]   <- NA
  d$ALLSKY_SFC_PAR_TOT[d$ALLSKY_SFC_PAR_TOT %in% -999] <- NA

  d <- fill_par(d)

  has_data <- !is.na(d$par)
  if (!any(has_data)) {
    stop("NASA POWER returned no solar radiation data for this location")
  }

  ## the window: n_days ending on the last day with data
  end_date   <- max(d$YYYYMMDD[has_data])
  start_date <- end_date - days(n_days - 1)

  if (min(d$YYYYMMDD) > start_date) {
    stop(sprintf("NASA POWER returned data from %s only; at least %d days are needed",
                 format(min(d$YYYYMMDD)), n_days))
  }

  ## one row per day, so a date missing from the download becomes an NA
  ## rather than silently shortening the window
  d <- d[d$YYYYMMDD <= end_date, ]
  d <- merge(data.frame(YYYYMMDD = seq(min(d$YYYYMMDD), end_date, by = "day")), d,
             by = "YYYYMMDD", all.x = TRUE)

  ## fill short gaps (rule = 1: never extrapolate past the last day with data).
  ## This runs before trimming to the window, so a gap at the start of the
  ## window can use the days just before it.
  d$par_estimated <- d$par_estimated %in% TRUE | is.na(d$par)
  d$par <- na.approx(d$par, na.rm = FALSE, rule = 1, maxgap = max_gap)

  d <- d[d$YYYYMMDD >= start_date, ]
  d$LAT  <- d$LAT[!is.na(d$LAT)][1]
  d$LON  <- d$LON[!is.na(d$LON)][1]
  d$YEAR <- year(d$YYYYMMDD)
  d$MM   <- month(d$YYYYMMDD)
  d$DD   <- mday(d$YYYYMMDD)
  d$DOY  <- yday(d$YYYYMMDD)

  if (anyNA(d$par)) {
    stop(sprintf("NASA POWER data for this location have a gap of more than %d days in a row between %s and %s",
                 max_gap, format(start_date), format(end_date)))
  }

  d$dli <- d$par * mol_per_MJ_par

  d$date      <- d$YYYYMMDD
  d$wday      <- wday(d$date, label = TRUE)
  d$monthName <- month(d$date, label = TRUE)
  d$weekCount <- (seq_len(nrow(d)) - 1) %/% 7 + 1

  d
}

# PAR for every day with data: NASA POWER's PAR where it exists, otherwise Rs
# times this location's PAR/Rs ratio.
#
# The ratio varies with location and season (it is higher when it is cloudy,
# because diffuse light has more PAR in it), from about 0.42 to 0.54 day to
# day. For each day without PAR, the ratio comes from the days with both PAR
# and Rs within +/- window days of the same date one year earlier. If there
# are fewer than min_days of those, it falls back to all days with both, and
# if there are none of those, to par_fraction_default.
#
# Backtested on 7 locations x 4 seasons in 2025, hiding the last 83 days of
# PAR: the estimated PAR total over those days had an RMS error of 1.1% (worst
# 3.3%), compared with 2.4% using one ratio from all days with both, and 3.2%
# using a fixed 0.45.
#
# Adds columns par (MJ m-2 d-1), par_ratio (the ratio used, NA on days with
# PAR) and par_estimated.

fill_par <- function(d, window = 30, min_days = 20) {

  sw  <- d$ALLSKY_SFC_SW_DWN
  par <- d$ALLSKY_SFC_PAR_TOT
  both <- !is.na(sw) & !is.na(par) & sw > 0

  ratio_all <- if (sum(both) >= min_days) sum(par[both]) / sum(sw[both]) else par_fraction_default

  need <- is.na(par) & !is.na(sw)
  d$par_ratio <- NA_real_
  d$par_ratio[need] <- vapply(d$YYYYMMDD[need], function(day) {
    ref <- both & abs(as.numeric(d$YYYYMMDD - (day - 365))) <= window
    if (sum(ref) >= min_days) sum(par[ref]) / sum(sw[ref]) else ratio_all
  }, numeric(1))

  d$par <- ifelse(need, sw * d$par_ratio, par)
  d$par_estimated <- need
  d
}

## DLI class used for colours and the weeks table: "a" = 0-10, "b" = 10-20 ...
dli_class <- function(x) letters[pmin(pmax(floor(x / 10), 0), 6) + 1]
dli_range_label <- function(x) {
  lo <- pmin(pmax(floor(x / 10), 0), 6) * 10
  paste(lo, "to", lo + 10)
}

## chart caption line saying where the DLI comes from, and from which date it
## is estimated (the recent run of days that POWER has no PAR for yet)
estimated_note <- function(d) {
  base <- sprintf("DLI is NASA POWER all-sky surface PAR x %s mol/MJ.", mol_per_MJ_par)
  runs <- rle(d$par_estimated)
  n_recent <- if (tail(runs$values, 1)) tail(runs$lengths, 1) else 0
  if (n_recent == 0) return(base)
  first <- d$date[nrow(d) - n_recent + 1]
  sprintf("%s POWER has no PAR yet from %s on (%d days); those days are estimated from solar radiation and this location's PAR/solar ratio.",
          base, format(first, "%d %b %Y"), n_recent)
}
