#! /bin/bash

# 6. Subset data by geographic location.
# Get the positions from D:\projects\sdm-framework\_Data\bounding_boxes.gdb polygon extents (LL, UR)
# 761851.8870429138187319,341358.6138938328367658 : 1177962.7083740374073386,695430.8700691995909438
# Convert these to 4326 WGS84 in rei_functions.convert_coordinates
# Get string with rei_functions.get_bounding_box_str
# x, y = convert_coordinates(761851.8870429138187319, 341358.6138938328367658, 3005, 4326)
# ll = (x, y)
# x2, y2 = convert_coordinates(1177962.7083740374073386, 695430.8700691995909438, 3005, 4326)
# ur = (x2, y2)
# get_bounding_box_str(ll, ur)
# '230.813941,236.552349,48.039146,51.243657'

# Use a bounding box to extract a subset of data
# sellonlatbox,lon1,lon2,lat1,lat2  infile outfile
# PARAMETER
#    lon1  FLOAT    Western longitude
#    lon2  FLOAT    Eastern longitude
#    lat1  FLOAT    Southern or northern latitude
#    lat2  FLOAT    Northern or southern latitude
cdo sellonlatbox,230.813941,236.552349,48.039146,51.243657 merged/HRDPS_OPPwest_ps2.5km_y2015.nc wcvi/HRDPS_OPPwest_ps2.5km_y2015.nc
cdo sellonlatbox,230.813941,236.552349,48.039146,51.243657 merged/HRDPS_OPPwest_ps2.5km_y2016.nc wcvi/HRDPS_OPPwest_ps2.5km_y2016.nc
cdo sellonlatbox,230.813941,236.552349,48.039146,51.243657 merged/HRDPS_OPPwest_ps2.5km_y2017.nc wcvi/HRDPS_OPPwest_ps2.5km_y2017.nc
cdo sellonlatbox,230.813941,236.552349,48.039146,51.243657 merged/HRDPS_OPPwest_ps2.5km_y2018.nc wcvi/HRDPS_OPPwest_ps2.5km_y2018.nc
cdo sellonlatbox,230.813941,236.552349,48.039146,51.243657 merged/HRDPS_OPPwest_ps2.5km_y2019.nc wcvi/HRDPS_OPPwest_ps2.5km_y2019.nc
cdo sellonlatbox,230.813941,236.552349,48.039146,51.243657 merged/HRDPS_OPPwest_ps2.5km_y2020.nc wcvi/HRDPS_OPPwest_ps2.5km_y2020.nc
cdo sellonlatbox,230.813941,236.552349,48.039146,51.243657 merged/HRDPS_OPPwest_ps2.5km_y2021.nc wcvi/HRDPS_OPPwest_ps2.5km_y2021.nc
cdo sellonlatbox,230.813941,236.552349,48.039146,51.243657 merged/HRDPS_OPPwest_ps2.5km_y2022.nc wcvi/HRDPS_OPPwest_ps2.5km_y2022.nc

# 7. Merge all years.
cdo mergetime [ wcvi/*.nc ] wcvi/HRDPS_OPPwest_ps2.5km.nc

# 8. Create binned direction.
cdo expr,'wind_dir_binned=360*(wind_dir>=-22.5)*(wind_dir<22.5)+45*(wind_dir>=22.5)*(wind_dir<67.5)+90*(wind_dir>=67.5)*(wind_dir<112.5)+135*(wind_dir>=112.5)*(wind_dir<157.5)+180*((wind_dir>=157.5)+(wind_dir<=-157.5))+225*(wind_dir>-157.5)*(wind_dir<=-112.5)+270*(wind_dir>-112.5)*(wind_dir<=-67.5)+315*(wind_dir>-67.5)*(wind_dir<=-22.5)' wcvi/HRDPS_OPPwest_ps2.5km_y2015.nc wcvi/HRDPS_OPPwest_ps2.5km_y2015_binned.nc
cdo expr,'wind_dir_binned=360*(wind_dir>=-22.5)*(wind_dir<22.5)+45*(wind_dir>=22.5)*(wind_dir<67.5)+90*(wind_dir>=67.5)*(wind_dir<112.5)+135*(wind_dir>=112.5)*(wind_dir<157.5)+180*((wind_dir>=157.5)+(wind_dir<=-157.5))+225*(wind_dir>-157.5)*(wind_dir<=-112.5)+270*(wind_dir>-112.5)*(wind_dir<=-67.5)+315*(wind_dir>-67.5)*(wind_dir<=-22.5)' wcvi/HRDPS_OPPwest_ps2.5km_y2016.nc wcvi/HRDPS_OPPwest_ps2.5km_y2016_binned.nc
cdo expr,'wind_dir_binned=360*(wind_dir>=-22.5)*(wind_dir<22.5)+45*(wind_dir>=22.5)*(wind_dir<67.5)+90*(wind_dir>=67.5)*(wind_dir<112.5)+135*(wind_dir>=112.5)*(wind_dir<157.5)+180*((wind_dir>=157.5)+(wind_dir<=-157.5))+225*(wind_dir>-157.5)*(wind_dir<=-112.5)+270*(wind_dir>-112.5)*(wind_dir<=-67.5)+315*(wind_dir>-67.5)*(wind_dir<=-22.5)' wcvi/HRDPS_OPPwest_ps2.5km_y2017.nc wcvi/HRDPS_OPPwest_ps2.5km_y2017_binned.nc
cdo expr,'wind_dir_binned=360*(wind_dir>=-22.5)*(wind_dir<22.5)+45*(wind_dir>=22.5)*(wind_dir<67.5)+90*(wind_dir>=67.5)*(wind_dir<112.5)+135*(wind_dir>=112.5)*(wind_dir<157.5)+180*((wind_dir>=157.5)+(wind_dir<=-157.5))+225*(wind_dir>-157.5)*(wind_dir<=-112.5)+270*(wind_dir>-112.5)*(wind_dir<=-67.5)+315*(wind_dir>-67.5)*(wind_dir<=-22.5)' wcvi/HRDPS_OPPwest_ps2.5km_y2018.nc wcvi/HRDPS_OPPwest_ps2.5km_y2018_binned.nc
cdo expr,'wind_dir_binned=360*(wind_dir>=-22.5)*(wind_dir<22.5)+45*(wind_dir>=22.5)*(wind_dir<67.5)+90*(wind_dir>=67.5)*(wind_dir<112.5)+135*(wind_dir>=112.5)*(wind_dir<157.5)+180*((wind_dir>=157.5)+(wind_dir<=-157.5))+225*(wind_dir>-157.5)*(wind_dir<=-112.5)+270*(wind_dir>-112.5)*(wind_dir<=-67.5)+315*(wind_dir>-67.5)*(wind_dir<=-22.5)' wcvi/HRDPS_OPPwest_ps2.5km_y2019.nc wcvi/HRDPS_OPPwest_ps2.5km_y2019_binned.nc
cdo expr,'wind_dir_binned=360*(wind_dir>=-22.5)*(wind_dir<22.5)+45*(wind_dir>=22.5)*(wind_dir<67.5)+90*(wind_dir>=67.5)*(wind_dir<112.5)+135*(wind_dir>=112.5)*(wind_dir<157.5)+180*((wind_dir>=157.5)+(wind_dir<=-157.5))+225*(wind_dir>-157.5)*(wind_dir<=-112.5)+270*(wind_dir>-112.5)*(wind_dir<=-67.5)+315*(wind_dir>-67.5)*(wind_dir<=-22.5)' wcvi/HRDPS_OPPwest_ps2.5km_y2020.nc wcvi/HRDPS_OPPwest_ps2.5km_y2020_binned.nc
cdo expr,'wind_dir_binned=360*(wind_dir>=-22.5)*(wind_dir<22.5)+45*(wind_dir>=22.5)*(wind_dir<67.5)+90*(wind_dir>=67.5)*(wind_dir<112.5)+135*(wind_dir>=112.5)*(wind_dir<157.5)+180*((wind_dir>=157.5)+(wind_dir<=-157.5))+225*(wind_dir>-157.5)*(wind_dir<=-112.5)+270*(wind_dir>-112.5)*(wind_dir<=-67.5)+315*(wind_dir>-67.5)*(wind_dir<=-22.5)' wcvi/HRDPS_OPPwest_ps2.5km_y2021.nc wcvi/HRDPS_OPPwest_ps2.5km_y2021_binned.nc
cdo expr,'wind_dir_binned=360*(wind_dir>=-22.5)*(wind_dir<22.5)+45*(wind_dir>=22.5)*(wind_dir<67.5)+90*(wind_dir>=67.5)*(wind_dir<112.5)+135*(wind_dir>=112.5)*(wind_dir<157.5)+180*((wind_dir>=157.5)+(wind_dir<=-157.5))+225*(wind_dir>-157.5)*(wind_dir<=-112.5)+270*(wind_dir>-112.5)*(wind_dir<=-67.5)+315*(wind_dir>-67.5)*(wind_dir<=-22.5)' wcvi/HRDPS_OPPwest_ps2.5km_y2022.nc wcvi/HRDPS_OPPwest_ps2.5km_y2022_binned.nc

# 9. Calculate min and max values required for percentile calculations.
cdo timmin wcvi/HRDPS_OPPwest_ps2.5km.nc wcvi/HRDPS_OPPwest_ps2.5km_timmin.nc
cdo timmax wcvi/HRDPS_OPPwest_ps2.5km.nc wcvi/HRDPS_OPPwest_ps2.5km_timmax.nc

# 10. Calculate 95th percentile value for wind speed per point, over all time steps.
cdo timpctl,95 -chname,wind_spd,q95 -selvar,wind_spd wcvi/HRDPS_OPPwest_ps2.5km.nc -selvar,wind_spd wcvi/HRDPS_OPPwest_ps2.5km_timmin.nc -selvar,wind_spd wcvi/HRDPS_OPPwest_ps2.5km_timmax.nc wcvi/HRDPS_OPPwest_ps2.5km_q95.nc

# 11. Create a mask using 95 percentile values.
cdo -O ge -chname,wind_spd,mask -selvar,wind_spd wcvi/HRDPS_OPPwest_ps2.5km.nc -chname,q95,wind_spd -selvar,q95 wcvi/HRDPS_OPPwest_ps2.5km_q95.nc wcvi/HRDPS_OPPwest_ps2.5km_mask.nc

# 12. Merge variables with output from step 7.
cdo merge wcvi/HRDPS_OPPwest_ps2.5km.nc wcvi/HRDPS_OPPwest_ps2.5km_binned360.nc  wcvi/HRDPS_OPPwest_ps2.5km_q95.nc wcvi/HRDPS_OPPwest_ps2.5km_mask.nc wcvi/HRDPS_OPPwest_ps2.5km_merged.nc

# 13. Calculate frequency in each binned direction.
cdo histfreq,45,90,135,180,225,270,315,360,inf -chname,wind_dir_binned,freq_total -selname,wind_dir_binned wcvi/HRDPS_OPPwest_ps2.5km_merged.nc wcvi/HRDPS_OPPwest_ps2.5km_frequency.nc

# 14. Merge frequency and merged files.
cdo merge wcvi/HRDPS_OPPwest_ps2.5km_merged.nc wcvi/HRDPS_OPPwest_ps2.5km_frequency.nc wcvi/HRDPS_OPPwest_ps2.5km_final.nc

# 15. Calculate grand mean.
# a) Subset data by wind_dir_binned value
cdo -eqc,45. -selvar,wind_dir_binned wcvi/HRDPS_OPPwest_ps2.5km_final.nc wcvi/binned/mask_45.nc
cdo -eqc,90. -selvar,wind_dir_binned wcvi/HRDPS_OPPwest_ps2.5km_final.nc wcvi/binned/mask_90.nc
cdo -eqc,135. -selvar,wind_dir_binned wcvi/HRDPS_OPPwest_ps2.5km_final.nc wcvi/binned/mask_135.nc
cdo -eqc,180. -selvar,wind_dir_binned wcvi/HRDPS_OPPwest_ps2.5km_final.nc wcvi/binned/mask_180.nc
cdo -eqc,225. -selvar,wind_dir_binned wcvi/HRDPS_OPPwest_ps2.5km_final.nc wcvi/binned/mask_225.nc
cdo -eqc,270. -selvar,wind_dir_binned wcvi/HRDPS_OPPwest_ps2.5km_final.nc wcvi/binned/mask_270.nc
cdo -eqc,315. -selvar,wind_dir_binned wcvi/HRDPS_OPPwest_ps2.5km_final.nc wcvi/binned/mask_315.nc
cdo -eqc,360. -selvar,wind_dir_binned wcvi/HRDPS_OPPwest_ps2.5km_final.nc wcvi/binned/mask_360.nc

# b) Assign NAs to data where the mask is 0
cdo ifthen wcvi/binned/mask_45.nc wcvi/binned/mask_45.nc wcvi/binned/mask_45_with_nas.nc
cdo ifthen wcvi/binned/mask_90.nc wcvi/binned/mask_90.nc wcvi/binned/mask_90_with_nas.nc
cdo ifthen wcvi/binned/mask_135.nc wcvi/binned/mask_135.nc wcvi/binned/mask_135_with_nas.nc
cdo ifthen wcvi/binned/mask_180.nc wcvi/binned/mask_180.nc wcvi/binned/mask_180_with_nas.nc
cdo ifthen wcvi/binned/mask_225.nc wcvi/binned/mask_225.nc wcvi/binned/mask_225_with_nas.nc
cdo ifthen wcvi/binned/mask_270.nc wcvi/binned/mask_270.nc wcvi/binned/mask_270_with_nas.nc
cdo ifthen wcvi/binned/mask_315.nc wcvi/binned/mask_315.nc wcvi/binned/mask_315_with_nas.nc
cdo ifthen wcvi/binned/mask_360.nc wcvi/binned/mask_360.nc wcvi/binned/mask_360_with_nas.nc

# c) Calculate daily max values for each binned direction
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd -mul -daymax wcvi/HRDPS_OPPwest_ps2.5km_final.nc wcvi/binned/mask_45_with_nas.nc wcvi/binned/max_wind_45.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd -mul -daymax wcvi/HRDPS_OPPwest_ps2.5km_final.nc wcvi/binned/mask_90_with_nas.nc wcvi/binned/max_wind_90.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd -mul -daymax wcvi/HRDPS_OPPwest_ps2.5km_final.nc wcvi/binned/mask_135_with_nas.nc wcvi/binned/max_wind_135.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd -mul -daymax wcvi/HRDPS_OPPwest_ps2.5km_final.nc wcvi/binned/mask_180_with_nas.nc wcvi/binned/max_wind_180.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd -mul -daymax wcvi/HRDPS_OPPwest_ps2.5km_final.nc wcvi/binned/mask_225_with_nas.nc wcvi/binned/max_wind_225.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd -mul -daymax wcvi/HRDPS_OPPwest_ps2.5km_final.nc wcvi/binned/mask_270_with_nas.nc wcvi/binned/max_wind_270.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd -mul -daymax wcvi/HRDPS_OPPwest_ps2.5km_final.nc wcvi/binned/mask_315_with_nas.nc wcvi/binned/max_wind_315.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd -mul -daymax wcvi/HRDPS_OPPwest_ps2.5km_final.nc wcvi/binned/mask_360_with_nas.nc wcvi/binned/max_wind_360.nc

# d) Calculate monthly mean of daily max values for each binned direction
cdo -monmean wcvi/binned/max_wind_45.nc wcvi/binned/monmean_45.nc 
cdo -monmean wcvi/binned/max_wind_90.nc wcvi/binned/monmean_90.nc 
cdo -monmean wcvi/binned/max_wind_135.nc wcvi/binned/monmean_135.nc 
cdo -monmean wcvi/binned/max_wind_180.nc wcvi/binned/monmean_180.nc 
cdo -monmean wcvi/binned/max_wind_225.nc wcvi/binned/monmean_225.nc 
cdo -monmean wcvi/binned/max_wind_270.nc wcvi/binned/monmean_270.nc 
cdo -monmean wcvi/binned/max_wind_315.nc wcvi/binned/monmean_315.nc 
cdo -monmean wcvi/binned/max_wind_360.nc wcvi/binned/monmean_360.nc

# e) Calculate grand mean (mean of monthly mean of daily max values) for each binned direction
cdo timmean wcvi/binned/monmean_45.nc wcvi/binned/grandmean_45.nc
cdo timmean wcvi/binned/monmean_90.nc wcvi/binned/grandmean_90.nc
cdo timmean wcvi/binned/monmean_135.nc wcvi/binned/grandmean_135.nc
cdo timmean wcvi/binned/monmean_180.nc wcvi/binned/grandmean_180.nc
cdo timmean wcvi/binned/monmean_225.nc wcvi/binned/grandmean_225.nc
cdo timmean wcvi/binned/monmean_270.nc wcvi/binned/grandmean_270.nc
cdo timmean wcvi/binned/monmean_315.nc wcvi/binned/grandmean_315.nc
cdo timmean wcvi/binned/monmean_360.nc wcvi/binned/grandmean_360.nc

# f) Add the wind_dir_binned constant value variable to each grand mean
cdo -expr,'wind_dir_binned=(max_wind_spd*0+45)' wcvi/binned/grandmean_45.nc wcvi/binned/45_tmp.nc
cdo merge wcvi/binned/45_tmp.nc wcvi/binned/grandmean_45.nc wcvi/binned/grandmean_45_bin.nc
rm wcvi/binned/45_tmp.nc wcvi/binned/grandmean_45.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+90)' wcvi/binned/grandmean_90.nc wcvi/binned/90_tmp.nc
cdo merge wcvi/binned/90_tmp.nc wcvi/binned/grandmean_90.nc wcvi/binned/grandmean_90_bin.nc
rm wcvi/binned/90_tmp.nc wcvi/binned/grandmean_90.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+135)' wcvi/binned/grandmean_135.nc wcvi/binned/135_tmp.nc
cdo merge wcvi/binned/135_tmp.nc wcvi/binned/grandmean_135.nc wcvi/binned/grandmean_135_bin.nc
rm wcvi/binned/135_tmp.nc wcvi/binned/grandmean_135.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+180)' wcvi/binned/grandmean_180.nc wcvi/binned/180_tmp.nc
cdo merge wcvi/binned/180_tmp.nc wcvi/binned/grandmean_180.nc wcvi/binned/grandmean_180_bin.nc
rm wcvi/binned/180_tmp.nc wcvi/binned/grandmean_180.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+225)' wcvi/binned/grandmean_225.nc wcvi/binned/225_tmp.nc
cdo merge wcvi/binned/225_tmp.nc wcvi/binned/grandmean_225.nc wcvi/binned/grandmean_225_bin.nc
rm wcvi/binned/225_tmp.nc wcvi/binned/grandmean_225.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+270)' wcvi/binned/grandmean_270.nc wcvi/binned/270_tmp.nc
cdo merge wcvi/binned/270_tmp.nc wcvi/binned/grandmean_270.nc wcvi/binned/grandmean_270_bin.nc
rm wcvi/binned/270_tmp.nc wcvi/binned/grandmean_270.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+315)' wcvi/binned/grandmean_315.nc wcvi/binned/315_tmp.nc
cdo merge wcvi/binned/315_tmp.nc wcvi/binned/grandmean_315.nc wcvi/binned/grandmean_315_bin.nc
rm wcvi/binned/315_tmp.nc wcvi/binned/grandmean_315.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+360)' wcvi/binned/grandmean_360.nc wcvi/binned/360_tmp.nc
cdo merge wcvi/binned/360_tmp.nc wcvi/binned/grandmean_360.nc wcvi/binned/grandmean_360_bin.nc
rm wcvi/binned/360_tmp.nc wcvi/binned/grandmean_360.nc

# 16. Merge all grand mean direction files
cdo merge [ wcvi/binned/grandmean_*.nc ] wcvi/HRDPS_OPPwest_ps2.5km_grandmean.nc

