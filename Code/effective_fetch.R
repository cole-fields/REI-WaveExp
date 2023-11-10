library(dplyr)
library(purrr)
library(tidyr)
library(data.table)
library(sf)
library(vroom)

# Controls ----

# relative contribution of fetch vectors surrounding each heading to calculation of effective fetch
weights <- cos(c(seq(45, 0, by = -5), seq(5, 45, by = 5)) * (pi/180))

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
  mutate(fetch_eff = map(data, ~roll.recycle(.$fetch_length_m, 19, 8, by = 9)),
         fetch_eff = map(fetch_eff, ~as.vector((weights %*% .)/sum(weights))),
         fetch_eff = map(fetch_eff, ~tibble(direction = c(360, seq(45, 315, 45)), fetch = .))) %>% 
  st_as_sf(coords = c("X","Y"), crs = crs_fetch)

saveRDS(fetch_eff, file.path(output_dir, "fetch_effective.rds"))
