library(dplyr)
library(purrr)
library(tidyr)
library(data.table)
library(sf)
library(vroom)

# Controls ----

# relative contribution of fetch vectors surrounding each heading to calculation of effective fetch
weights <- cos(c(45,33.75,22.5,11.25,0,11.25,22.5,33.75,45) *(pi/180))

# Path to project directory (string)
data_dir <- file.path('D:/projects/REI-WaveExp/data', 'hg')
output_dir <- file.path(data_dir, 'v1.5')

# Source functions ----
setwd('D:/projects/REI-WaveExp/code')
source('roll_recycle_fun.R')

# Coordinate reference system of fetch calculations (integer EPSG code)
crs_fetch <- 3005 # (BCAlbers)
# crs_fetch <- 26921 # (UTM21)
# crs_fetch <- 4326 # (WGS84)

# Combine fetch data from all points into one data table ----

# list of fetch files

fetch_csv <- list.files(path = data_dir,
                        pattern = 'csv',
                        full.names = TRUE)

# Combine csv files from separate clusters of points and reshape to long format

fetch_summary <- map(fetch_csv, fread) %>%
  rbindlist(idcol = 'cluster') %>%
  mutate(., site_names = seq_along(cluster)) %>%
  pivot_longer(data = .,
               cols = starts_with("bearing"),
               values_to = "fetch_length_m",
               names_to = "direction",
               names_prefix = "bearing",
               names_transform = list(direction = as.numeric)) %>%
  setDT()

# Calculate minimum fetch (proxy for distance to coast) and sum fetch (proxy for wave exposure)

fetch_proxies <- fetch_summary[, .(min_fetch = min(fetch_length_m),
                                   sum_fetch = sum(fetch_length_m)),
                               by = .(site_names,X,Y)]

vroom_write(fetch_proxies, file.path(output_dir, "fetch_proxies.csv"), delim = ",")

# Calculate effective fetch ----
fetch_eff <- fetch_summary %>%
  dplyr::select(X, Y, direction, fetch_length_m) %>% 
  group_by(X, Y) %>% 
  nest() %>% 
  bind_cols(., site_names = as.character(seq_len(nrow(.)))) %>%   
  # Calculate effective fetch and place in tibble
  mutate(fetch_eff = map(data, ~roll.recycle(.$fetch_length_m, 9, 8, by = 9)),
         fetch_eff = map(fetch_eff, ~as.vector((weights %*% .)/sum(weights))),
         fetch_eff = map(fetch_eff, ~tibble(direction = c(360, seq(45, 315, 45)), fetch = .))) %>% 
  st_as_sf(coords = c("X","Y"), crs = crs_fetch)

saveRDS(fetch_eff, file.path(output_dir, "fetch_effective.rds"))

#######################################################################
##########Environmental Data Layers for SG sdm#########################
#######################################################################

#### Load Packages ####

library(dplyr)
library(purrr)
library(tidyr)
library(sf)
library(terra)

# Housekeeping ----

# Read in interpolated wind data ----
# pwd = getwd()
data_dir <- file.path('D:/projects/REI-WaveExp/data/hg/v1.5')
tif_dir <- file.path('E:/HRDPS2.5/results/hg/v1.1', 'spline_hrdps')

# Raster stack of wind frequency by direction
wind_freq <- list.files(path = tif_dir,
                        pattern = "^freq.+tif$",
                        full.names = T) %>% 
  rast(.) 

# Raster stack of average daily maximum wind speed by direction

wind_spd <- list.files(path=tif_dir,
                       pattern="^mx.+tif$",
                       full.names=T) %>% 
  rast(.)

# Combine fetch data and wind data ----

# Read in effective fetch data
# fetch <- terra::vect(file.path(data_dir, 'fetch_barkeley.shp'))
fetch_eff <- readRDS(file.path(data_dir, "fetch_effective.rds"))

# Extract frequency and speed values for fetch locations

freq_values <- terra::extract(x=wind_freq, 
                              y=fetch_eff)
spd_values <- terra::extract(x=wind_spd, 
                             y=fetch_eff)
wind_combine <- merge(freq_values, spd_values, by="ID")

# Calculate Relative Exposure Index ----
expo_by_site <- wind_combine %>%
  rowwise() %>% 
  mutate(freq_total = list(cbind(c_across(contains("freq")))),
         max_wind = list(cbind(c_across(contains("mx")))),
         wind_dir_freq = list(tibble(max_wind, 
                                     freq_total, 
                                     direction = c(135,180,225,270,315,360,45,90)))) %>%
  ungroup() %>% 
  mutate(., wind_dir_freq = map(wind_dir_freq, function(.data) {
    .data %>% 
      dplyr::arrange(., direction)
  }),
  fetch_eff = map(fetch_eff$fetch_eff, function(.data){
    .data %>% 
      dplyr::arrange(., direction)
  })) %>% 
  mutate(REI = map2_dbl(wind_dir_freq, fetch_eff, # calculate relative exposure
                        ~sum((.x$max_wind*.x$freq_total*.y$fetch), na.rm = T))) %>%  
  dplyr::select(ID, REI) %>% # keep site, REI, and geometry
  rename(., site = ID) %>%
  mutate(geometry = fetch_eff$geometry)

# Save REI object
saveRDS(expo_by_site, file.path(data_dir, 'REI.rds'))

# Write to csv
st_write(obj=expo_by_site,
         dsn=file.path(data_dir, 'REI.csv'),
         layer_options='GEOMETRY=AS_XY',
         append=FALSE)
