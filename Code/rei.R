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
fetch_dir <- 'E:/HRDPS2.5/results/hg'
data_dir <- file.path('E:/HRDPS2.5/results/hg/', 'v1.1')
tif_dir <- file.path(data_dir, 'spline_hrdps')
outdir <- file.path(fetch_dir, 'v1.5')

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
eff <- readRDS(file.path(fetch_dir, "fetch_effective.rds"))
eff <- eff %>%
  mutate(fetch_sum = map_dbl(data, ~ sum(.x$fetch_length_m)))


eights <- lapply(eff$fetch_sum, function(x) {
  tibble(fetch_m = rep(x/8, 8))
})

eff$fetch_eff <- purrr::map2(eff$fetch_eff, eights, ~dplyr::mutate(.x, fetch_m = .y$fetch_m))

# Extract frequency and speed values for fetch locations

freq_values <- terra::extract(x=wind_freq, 
                              y=eff)
spd_values <- terra::extract(x=wind_spd, 
                             y=eff)
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
  })) %>% 
  mutate(REI = map2_dbl(wind_dir_freq, eff$fetch_eff, # calculate relative exposure
                        ~sum((.x$max_wind*.x$freq_total*.y$fetch_m), na.rm = T))) %>%  
  dplyr::select(ID, REI) %>%
  rename(., site = ID) %>%
  mutate(geometry = eff$geometry)
# Save REI object
saveRDS(expo_by_site, file.path(outdir, 'REI.rds'))

# Write to csv
st_write(obj=expo_by_site,
         dsn=file.path(outdir, 'rei_origFetch.csv'),
         layer_options='GEOMETRY=AS_XY',
         append=FALSE)
