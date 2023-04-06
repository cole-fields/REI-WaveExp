#######################################################################
####### Download and summarize surface wind components from CDS #######
#######################################################################

# Description: ----

# This script makes data requests to Copernicus' Climate Data Stores (CDS) for
# surface wind data from the ERA-5 reanalysis and summarizes maximum wind speed
# and frequency by direction over the specified time period

# Requirements: ----

# Free personal account to CDS with username and key:

# https://cds.climate.copernicus.eu/user/register

# Note: ----

# large data requests over a larger bounding box and multiple years will
# need to be split into multiple queries

# Load packages ----
library(dplyr)
library(purrr)
library(tidyr)
library(data.table)
library(stringr)
library(sf)
library(ncdf4)
library(ncdf4.helpers)

# Housekeeping ----
data_dir <- "D:/projects/rei/data/wind/HRDPS_WindData" # directory within project folder to store downloaded data
crs <- 3005 # projected coordinate reference system  (integer EPSG code)
options(dplyr.summarise.inform = FALSE)


# Function that converts nav_lon values from 0-360 to -180-180.
convert_lon <- function(x) {
  x[which(x > 180)] <- x[which(x > 180)] - 360
  return(x)
}

# Given 2 integer arrays (lat and lon values), and 2 2-element lists of lat or lon ranges,
# return the common indices of values that are within the ranges specified.
find_indices <- function(lon_array, lat_array, lon_range, lat_range) {
  lon_indices <- which(lon_array <= lon_range[1] & lon_array >= lon_range[2])
  lat_indices <- which(lat_array >= lat_range[1] & lat_array <= lat_range[2])
  common_values <- intersect(lon_indices, lat_indices)
  return(common_values)
}

# Function that loads subsets of data from variables in a NetCDF file based on target latitude and longitude indices.
load_subset <- function(netcdf_list, variable, target_indices) {
  my_var <- map(netcdf_list, ~as.vector(ncvar_get(.x, variable)))
  my_var_subset <- map(my_var, ~.[target_indices])
  return(my_var_subset)
}

# Summarize wind data ----
# Open netCDF files listed in data dir.
era5 <- list.files(path = data_dir, pattern = "^HRDPS_OPPwest", full.names = T) %>% 
  map(., nc_open, readunlim=FALSE)

time <- map(era5, ~ncvar_get(.x, "time_counter"))

# Read lat lon values from first netCDF file. 
# We need to convert longitude from 0 to 360 into +-180.
# They will then be used as a filter (by indices) once subset.
latitude <- as.vector(ncvar_get(era5[[1]], 'nav_lat'))
longitude <- as.vector(ncvar_get(era5[[1]], 'nav_lon'))

# Use map() to apply the convert_lon function to each nav_lon element in my_list
longitude180 <- convert_lon(longitude)

# Define the subset of the data that you want to extract based on latitudes and longitudes
subset_lat <- c(48.4, 49.4)
subset_lon <- c(-124.6, -125.8)

# Find the indices of the subset of data in the latitude and longitude arrays.
target_indices <- find_indices(longitude180, latitude, subset_lon, subset_lat)

# Load variables, then subset using indices.
u10 <- load_subset(era5, 'u_wind', target_indices)
v10 <- load_subset(era5, 'v_wind', target_indices)

latitude_vals <- load_subset(era5, 'nav_lat', target_indices)
longitude_vals <- load_subset(era5, 'nav_lon', target_indices)

latitude_long <- map2(latitude_vals, longitude_vals, ~lapply(.x, function(x) rep(x, length(.y))))
longitude_long <- map2(longitude_vals, latitude_vals, ~lapply(.x, function(x) rep(x, length(.y))))


date_time <- pmap(list(time, latitude_vals, longitude_vals), ~lapply(..1, function(x) rep(x, length(..2)))) %>%  
  map(., unlist) %>% 
  map(., ~as.POSIXct(.x, origin = "1950-01-01 00:00:00", tz = "UTC"))

wind_data <- pmap(list(longitude_long, latitude_long, date_time, u10, v10), 
                  ~data.frame(longitude = ..1, latitude = ..2, date_time = ..3, u10 =  ..4, v10 = ..5)) %>% 
  rbindlist() %>% 
  mutate(wind_spd = sqrt((u10^2) + (v10^2)),
         wind_dir = (180 + ((180/pi)*atan2(u10, v10))) %% 360) %>% 
  # counts the number of entries in 45 degree bins around 8 compass headings (N, NE, E, etc.)
  # In other words, this is the frequency that the wind blew from each direction of interest      
  mutate(direction = cut(wind_dir, 
                         breaks = c(0,22.5,67.5,112.5,157.5,202.5,247.5,292.5,337.5,361),
                         right = TRUE,
                         labels = c(360,45,90,135,180,225,270,315,360))) %>%  
  # Nest data frame by lon and lat
  group_by(longitude, latitude) %>% 
  nest() %>% 
  # calculates frequency from each direction
  mutate(., q95 = map(data, function(.data){
    .data %>% 
      filter(wind_spd > quantile(wind_spd, probs = 0.95))
  })) %>% 
  mutate(wind_dir_cbin = map(q95, function(.data) {
    .data %>%
      dplyr::select(direction) %>% 
      table() %>% 
      data.frame() %>%
      # rename(direction = ".") %>% 
      mutate(freq_total = Freq/sum(Freq), 
             direction = as.numeric(as.character(direction)))})) %>%
  # average speed by direction
  mutate(., avg_wind = map(q95, function(.data) {
    .data %>% 
      mutate(date = as.Date(date_time)) %>% 
      separate(date, into = c('year', 'month', 'day')) %>% 
      group_by(year, month, day, direction) %>% 
      summarise(daily_max = max(wind_spd)) %>% 
      group_by(year, month, direction) %>% 
      summarise(monthly_max = mean(daily_max)) %>% 
      group_by(direction, .drop = FALSE) %>% 
      summarise(max_wind = mean(monthly_max)) %>% 
      mutate_if(is.factor, as.character) %>%
      mutate_if(is.character, as.numeric) %>%
      mutate(max_wind = na_if(x = max_wind, y = NaN),
             max_wind = nafill(x = max_wind, fill = 0)) %>% 
      data.frame()})) %>% 
  # Join average wind speed and frequency into one table per station
  transmute(wind_dir_freq = map2(avg_wind, wind_dir_cbin, left_join)) %>%  
  st_as_sf(., coords = c('longitude','latitude'), crs = 4326) %>% # convert to sf spatial object
  st_transform(crs) # project to BCAlbers

# Add sequential ID to list of dataframes such that there will be 8 points w/same geometry (same ID).
# and save to RDS object
wind_data <- wind_data %>%
  mutate(wind_dir_freq = map2(wind_dir_freq, 1:length(wind_dir_freq), ~ mutate(.x, id = .y)))
saveRDS(wind_data, file.path(data_dir, 'Copernicus_era5_dir_freq_summary.rds'))

# cast to wide format and write to shapefile

wind_unnest <- unnest(wind_data, cols = wind_dir_freq)


wind_wide <- dplyr::select(wind_unnest, -Freq) %>% 
  st_drop_geometry() %>% 
  rename(., mx_spd = max_wind, freq = freq_total) %>% 
  pivot_wider(data = .,
              id_cols = id,
              names_from = direction,
              values_from = c(mx_spd, freq)) %>% 
  left_join(., dplyr::select(wind_unnest, id)) %>% 
  st_set_geometry(., value = .$geometry)

# Remove duplicates.
wind_wide <- wind_wide[!duplicated(wind_wide), ]

st_write(wind_wide,
         dsn = data_dir,
         layer = "Copernicus_era5_summary_wide",
         driver = 'ESRI Shapefile')

# Move onto wind data interpolation: (4WindInterpolation.py)

