# unapologetically taken from Hadley Wickham's ggplot2 book
library(raster)
library(tidyverse)
# library(ggplot2)
# library(grid)
library(gridExtra)
# library(dplyr)
# library(tidyr)
library(png)
library(jpeg)
library(knitr)
library(lubridate)
library(zoo)
options(width = 72,
        digits = 3,
        dplyr.print_min = 6,
        dplyr.print_max = 6)

version <- "0.1.0"

library(maps)

knitr::opts_chunk$set(
  tidy = FALSE,
  comment = "R>",
  collapse = TRUE,
  fig.path = 'figures/',
  fig.show = "hold",
  dpi = 300,
  cache = FALSE,
  cache.path = "_cache/"
)

is_latex <- function() {
  identical(knitr::opts_knit$get("rmarkdown.pandoc.to"), "latex")
}

columns <- function(n, aspect_ratio = 1, max_width = if (n == 1) 0.65 else 1) {
  if (is_latex()) {
    out_width <- paste0(round(max_width / n, 3), "\\linewidth")
    knitr::knit_hooks$set(plot = plot_hook_bookdown)
  } else {
    out_width <- paste0(round(max_width * 100 / n, 1), "%")
  }

  width <- 6 / n * max_width

  knitr::opts_chunk$set(
    fig.width = width,
    fig.height = width * aspect_ratio,
    fig.align = if (max_width < 1) "center" else "default",
    fig.show = if (n == 1) "asis" else "hold",
    fig.retina = NULL,
    out.width = out_width,
    out.extra = if (!is_latex())
      paste0("style='max-width: ", round(width, 2), "in'")
  )
}

# Draw parts of plots -----------------------------------------------------

draw_legends <- function(...) {
  plots <- list(...)
  gtables <- lapply(plots, function(x) ggplot_gtable(ggplot_build(x)))
  guides <- lapply(gtables, gtable::gtable_filter, "guide-box")

  one <- Reduce(function(x, y) cbind(x, y, size = "first"), guides)

  grid::grid.newpage()
  grid::grid.draw(one)
}

# Customised plot layout --------------------------------------------------

plot_hook_bookdown <- function(x, options) {
  paste0(
    begin_figure(x, options),
    include_graphics(x, options),
    end_figure(x, options)
  )
}

begin_figure <- function(x, options) {
  if (!knitr_first_plot(options))
    return("")

  paste0(
    "\\begin{figure}[H]\n",
    if (options$fig.align == "center") "  \\centering\n"
  )
}
end_figure <- function(x, options) {
  if (!knitr_last_plot(options))
    return("")

  paste0(
    if (!is.null(options$fig.cap)) {
      paste0(
        '  \\caption{', options$fig.cap, '}\n',
        '  \\label{fig:', options$label, '}\n'
      )
    },
    "\\end{figure}\n"
  )
}
include_graphics <- function(x, options) {
  opts <- c(
    sprintf('width=%s', options$out.width),
    sprintf('height=%s', options$out.height),
    options$out.extra
  )
  if (length(opts) > 0) {
    opts_str <- paste0("[", paste(opts, collapse = ", "), "]")
  } else {
    opts_str <- ""
  }

  paste0("  \\includegraphics",
    opts_str,
    "{", knitr:::sans_ext(x), "}",
    if (options$fig.cur != options$fig.num) "%",
    "\n"
  )
}

knitr_first_plot <- function(x) {
  x$fig.show != "hold" || x$fig.cur == 1L
}
knitr_last_plot <- function(x) {
  x$fig.show != "hold" || x$fig.cur == x$fig.num
}


# Functions for the mapping yourself session ------------------------------

# Clean up json dataframes for better analysis
location.clean <- function(location_history){
  # extracting the locations dataframe
  loc <-  location_history$locations
  # Convert time column from posix milliseconds into a readable time scale
  loc$time <- as.POSIXct(as.numeric(location_history$locations$timestampMs)/1000, origin = "1970-01-01")
  # Convert longitude and latitude from E7 to GPS coordinates
  loc$lat <- loc$latitudeE7 / 1e7
  loc$lon <- loc$longitudeE7 / 1e7
  loc <- loc %>%
    select(accuracy:lon, -activitys) %>%
    mutate(date = as.Date(time, '%Y/%m/%d'),
           month_year = as.yearmon(date),
           year = year(date))
  return(loc)
}

# Shifting vectors for latitude and longitude to include end position
shift.vec <- function(vec, shift){
  if (length(vec) <= abs(shift)){
    rep(NA ,length(vec))
  } else {
    if (shift >= 0) {
      c(rep(NA, shift), vec[1:(length(vec) - shift)]) }
    else {
      c(vec[(abs(shift) + 1):length(vec)], rep(NA, abs(shift)))
    }
  }
}

# Calculate distance between points
dist.points <- function(df){
  apply(df, 1, FUN = function(row) {
    pointDistance(c(as.numeric(as.character(row["lat.p1"])),
                    as.numeric(as.character(row["lon.p1"]))),
                  c(as.numeric(as.character(row["lat"])), as.numeric(as.character(row["lon"]))),
                  lonlat = T)
  })
}

# Create distance dataframe
distance.per.month <- function(df){
  df2 <- df %>%
    mutate(lat.p1 = shift.vec(lat, -1),
           lon.p1 = shift.vec(lon, -1))
  df2$dist.to.prev <- dist.points(df2)
  df2 <- df2[complete.cases(df2$dist.to.prev),]
  distance_p_month <- df2 %>%
    group_by(month_year) %>%
    summarise(distance = sum(dist.to.prev)*0.001) %>%
    mutate(month_year = as.factor(month_year))
  return(distance_p_month)
}

# Create an activities dataframe
activities.df <- function(df){
  activities <- df$locations$activitys
  list.condition <- sapply(activities, function(x) !is.null(x[[1]]))
  activities  <- activities[list.condition]
  times <- do.call("rbind", activities)
  main_activity <- sapply(times$activities, function(x) x[[1]][1][[1]][1])
  activities_2 <- data.frame(main_activity = main_activity,
                             time = as.POSIXct(as.numeric(times$timestampMs)/1000,
                                               origin = "1970-01-01"))
  return(activities_2)
}
