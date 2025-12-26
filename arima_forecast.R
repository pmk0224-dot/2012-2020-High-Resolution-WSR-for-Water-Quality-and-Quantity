library(forecast)
library(dplyr)
library(tibble)

input_folder  <- "data/global_data"
output_folder <- "results/global_data_bod_forecast"

files <- list.files(input_folder, full.names = TRUE, pattern = "\\.csv$")

process_file <- function(file_path) {

  data <- read.csv(file_path)
  unique_coords <- distinct(select(data, lon, lat))
  predictions <- tibble()

  for (i in seq_len(nrow(unique_coords))) {

    coords <- unique_coords[i, ]
    group_data <- filter(data, lon == coords$lon, lat == coords$lat)

    if (all(is.na(group_data$bod))) {
      next
    }

    ts_data <- ts(
      group_data$bod,
      start = c(min(group_data$year), min(group_data$month)),
      frequency = 12
    )

    model <- auto.arima(ts_data)
    fc <- forecast(model, h = 84)

    pred_data <- tibble(
      lon = coords$lon,
      lat = coords$lat,
      year = rep(2011:2017, each = 12),
      month = rep(1:12, times = 7),
      predicted_bod = as.numeric(fc$mean)
    )

    predictions <- bind_rows(predictions, pred_data)
  }

  output_file <- file.path(
    output_folder,
    paste0(tools::file_path_sans_ext(basename(file_path)), "_bod_forecast.csv")
  )

  write.csv(predictions, output_file, row.names = FALSE)
  predictions
}

if (!dir.exists(output_folder)) {
  dir.create(output_folder, recursive = TRUE)
}

for (file in files) {
  process_file(file)
}
