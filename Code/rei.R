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
data_dir <- file.path('F:/Projects/hrdps', 'ncc')
tif_dir <- file.path(data_dir, 'spline_hrdps')

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
