# Relative Exposure Index (Depth Attenuated)

__Main author:__  John O'brien and Cole Fields
__Affiliation:__  Fisheries and Oceans Canada (DFO)   
__Group:__        Marine Spatial Ecology and Analysis   
__Location:__     Institute of Ocean Sciences   
__Contact:__      e-mail: Cole.Fields@dfo-mpo.gc.ca  


- [Objective](#objective)
- [Summary](#summary)
- [Status](#status)
- [Contents](#contents)
  + [Subsections within contents](#subsections-within-contents)
- [Methods](#methods)
  + [Subsections within methods](#subsections-within-methods)
- [Requirements](#requirements)
- [Caveats](#caveats)
- [Uncertainty](#uncertainty)
- [Acknowledgements](#acknowledgements)
- [References](#references)


## Objective
The objective of this project is to develop regional spatial layers that provide a relative exposure index (REI) to wind-driven waves along the coastal zone of Pacific Canada. The REI layers will serve as a valuable tool for ecological modeling and marine spatial planning, supporting the conservation and sustainable use of coastal ocean resources.


## Summary
Exposure to wind-driven waves plays a crucial role in coastal areas, impacting both ecological communities and human activities. This project aims to quantify and map the wave exposure gradient within the study areas. The resulting spatial layers, with a resolution of 20 meters, provide the REI, which is a fetch-derived index based on established methods. The index combines fetch calculations from 72 compass headings with modelled wind data obtained from the High Resolution Deterministic Prediction System (HRDPS) - nested limited-area model (LAM) forecast grids from the Global Environmental Multiscale (GEM) model with a 2.5 km horizontal grid. Using bathymetric data, an exponential decay function is applied to each of the regional REI layers, such that deeper areas have a lower relative value than rearshore areas. Further, the REI regions are normalized from 0 (most protected) to 1 (most exposed), reflecting the relative exposure levels to wind-driven waves.

This repository includes the source code implemented in R and Python. The code facilitates the calculation of effective fetch (from source fetch data), processing and summarizing modelled wind data, interpolating the data, computing REI values for input point features, and converting the points to a raster format.


## Status
Ongoing-improvements


## Contents
* effective_fetch.R - Group fetch data by location (X and Y coordinates) and nest the fetch lengths for each wind direction. Calculate the effective fetch for each location and wind direction by applying a weighted average to the fetch lengths.
* process_wind_0.sh - CDO commands to merge daily files into annual files, calculate wind speed and direction from the zonal and meridional components of the wind (u and v), and merge into annual files with the direction and speed values.
* process_wind_1.sh - CDO commands to subset wind data by geographic location, merge annual subsets into a single file, create binned wind directions, mask data where wind speed is below 95th percentile value, and calculate the frequency and grand mean (mean of monthly means of daily maximum values).
* netcdf_to_spatial.py - Convert the frequency of wind direction and grand mean wind speed NetCDF files into a merged dataframe that is written to disk as a GeoPackage layer.
* interpolate.py - Interpolate the data from the layer created from netcdf_to_spatial.py. There will be 16 interpolated surfaces: one for each binned direction (0-360 in 45 degree bins) by two variables (max speed and frequency).
* rei.R - Stack the interpolated raster surfaces by their type (max speed and wind frequency). Load Effective fetch RDS file and extract raster values at point locations. Calculate the relative exposure index.
* attenuate.py
* helper_functions.py - Small functions for converting coordinates between reference systems and getting a bounding box string formatted for CDO input.
* hrdps.ipynb - Jupyter notebook summarizing some of the wind data.
* roll_recycle_fun.R - Custom rolling window function used for calculating effective fetch.
* waves.py - Script used for merging monthly text files of wave data and calculating the mean value for each node location from modelled data. Significant wave height variable was used for comparing fetch surface, REI surface, and depth-attenuated REI surfaces.


## Methods
* Export the attribute table to a csv file for each region's fetch point layer. This file needs to have the values for each of the bearing lines.
* Run `effective_fetch.R`. Calculate effective fetch using source fetch data. The output will be fetch_effective.rds and fetch_proxies.csv. Effective fetch is calculated for each location and wind direction using the map function from the purrr package. For each location and wind direction, the roll.recycle function is applied to the fetch data, which calculates a weighted moving average using a rolling window of 9 fetch values multiplied by the cosine of the angle of departure from the bearing. The weights are highest for the fetch lengths closest to the wind direction, and decrease as the angle between the fetch vector and wind direction increases.
* Run `process_wind_0.sh`. Use CDO software to pre-process HRDPS data. This includes merging daily files into annual NetCDF files with only the zonal and meridional components of the wind (u and v).
* Run `process_wind_1.sh`. Use CDO to calculate wind speed - e.g., `cdo -O -expr,'wind_spd=sqrt(u_wind*u_wind+v_wind*v_wind)' -selname,u_wind,v_wind merged/2015.nc merged/2015_ws.nc` and direction - e.g., `cdo -O -chname,u_wind,wind_dir -mulc,57.3 -atan2 -mulc,-1 -selname,u_wind merged/2015.nc -mulc,-1 -selname,v_wind merged/2015.nc merged/2015_wd.nc`. for each of the merged files. Calculate wind frequency and grand mean (mean of monthly means of daily maximum values). Geographic subsets are used before creating binned wind direction values and subsetting by the 95th percentile (of max wind speed). Wind frequency by binned wind direction and grand mean values are then calculated and stored as two nNetCDF files.
* Run `netcdf_to_spatial.py`.Python is used to merge the frequency and grand mean values into a dataframe and save the data as a GeoPackage layer.
* Run `interpolate.py`.Interpolate the point data (max wind speed and frequency) into raster surfaces. This is where the higher resolution wind data is most useful.
* Run `rei.R`. Extract raster values at fetch locations using the effective fetch RDS file. Then, the relative exposure index (REI) is calculated by summing the product of the wind frequency, maximum wind speed, and effective fetch for each direction. The resulting REI values and site geometries are saved to a `REI.rds` file and a `REI.csv` file.
* Manually bring the `REI.csv` file into ESRI software and convert to raster (point to raster) at 50 m resolution (same as evenly spaced gridded points).
* Smooth the raster surface using a focal mean (apply a 5 cell circular neighbourhood [mean values]). The reason for this is to reduce some of the patterns created from the fetch lines radiating out from each point.
* Resample the smoothed surface to 20 m resolution and clip/align with SDM predictor layers to prepare layers to be used in modelling.
* Run `normalize.py` from https://gitlab.com/dfo-msea/environmental-layers/normalize-fetch once all regions have been smoothed and clipped, to rescale layers to 0-1 where only the region with the greatest REI value will have any 1 values.


## Requirements
#### Data
1. Daily wind data (HRDPS west): Environment and Climate Change Canada https://weather.gc.ca/grib/grib2_HRDPS_HR_e.html.
2. Fetch csv files with values for each of the bearings: https://www.gis-hub.ca/dataset/gridded-nearshore-fetch.


#### Software
1. Linux computer with CDO software for processing HRDPS data: https://code.mpimet.mpg.de/projects/cdo/files.
2. R software.
3. Python3 virtual environment with xarray, rasterio, osgeo, geopandas packages.
4. interpolate.py uses the arcpy module and requires an active license for the ArcGIS suite.


## Caveats
* Modelled wind data has a 2.5 km horizontal resolution.
* The original repository (https://github.com/cole-fields/REI-WaveExp/tree/main/Code) contains additional R files for downloading and processing wind data. However, we use a higher resolution source of wind data that failed to run in R. For that reason, many of the operations originally designed to run in R are translated into CDO commands and executed in a Linux environment.
* With the exception of the depth attenuation, the results from the `hrdps` branch should align with the `main` branch, just using different processing software.


## Uncertainty
* There may be more appropriate functions for depth attenuation.


## Acknowledgements
* John O'brien
* Ashley Park
* Joanne Lessard
* Michael Peterman


## References
* Fonseca MS, Bell SS (1998) Influence of physical setting on seagrass landscapes. Mar Ecol Prog Ser 171:109–121.
* Government of Canada; Environment and Climate Change Canada; Meteorological Service of Canada - National Inquiry Response Team / Équipe nationale de réponse des demandes du public ( National Inquiry Response Team )
