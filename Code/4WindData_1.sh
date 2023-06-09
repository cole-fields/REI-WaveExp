#! /bin/bash

# 6. Subset data by geographic location.
mkdir barkley


# Use a bounding box to extract a subset of data
# sellonlatbox,lon1,lon2,lat1,lat2  infile outfile
# PARAMETER
#    lon1  FLOAT    Western longitude
#    lon2  FLOAT    Eastern longitude
#    lat1  FLOAT    Southern or northern latitude
#    lat2  FLOAT    Northern or southern latitude
cdo sellonlatbox,234.296747,235.31807,48.598047,49.248361 merged/HRDPS_OPPwest_ps2.5km_y2015.nc barkley/HRDPS_OPPwest_ps2.5km_y2015.nc
cdo sellonlatbox,234.296747,235.31807,48.598047,49.248361 merged/HRDPS_OPPwest_ps2.5km_y2016.nc barkley/HRDPS_OPPwest_ps2.5km_y2016.nc
cdo sellonlatbox,234.296747,235.31807,48.598047,49.248361 merged/HRDPS_OPPwest_ps2.5km_y2017.nc barkley/HRDPS_OPPwest_ps2.5km_y2017.nc
cdo sellonlatbox,234.296747,235.31807,48.598047,49.248361 merged/HRDPS_OPPwest_ps2.5km_y2018.nc barkley/HRDPS_OPPwest_ps2.5km_y2018.nc
cdo sellonlatbox,234.296747,235.31807,48.598047,49.248361 merged/HRDPS_OPPwest_ps2.5km_y2019.nc barkley/HRDPS_OPPwest_ps2.5km_y2019.nc
cdo sellonlatbox,234.296747,235.31807,48.598047,49.248361 merged/HRDPS_OPPwest_ps2.5km_y2020.nc barkley/HRDPS_OPPwest_ps2.5km_y2020.nc
cdo sellonlatbox,234.296747,235.31807,48.598047,49.248361 merged/HRDPS_OPPwest_ps2.5km_y2021.nc barkley/HRDPS_OPPwest_ps2.5km_y2021.nc
cdo sellonlatbox,234.296747,235.31807,48.598047,49.248361 merged/HRDPS_OPPwest_ps2.5km_y2022.nc barkley/HRDPS_OPPwest_ps2.5km_y2022.nc

# 7. Merge all years.
cdo mergetime [ barkley/*.nc ] barkley/HRDPS_OPPwest_ps2.5km.nc

# 8. Create binned direction.
cdo expr,'wind_dir_binned=360*(wind_dir>=-22.5)*(wind_dir<22.5)+45*(wind_dir>=22.5)*(wind_dir<67.5)+90*(wind_dir>=67.5)*(wind_dir<112.5)+135*(wind_dir>=112.5)*(wind_dir<157.5)+180*((wind_dir>=157.5)+(wind_dir<=-157.5))+225*(wind_dir>-157.5)*(wind_dir<=-112.5)+270*(wind_dir>-112.5)*(wind_dir<=-67.5)+315*(wind_dir>-67.5)*(wind_dir<=-22.5)' barkley/HRDPS_OPPwest_ps2.5km_y2015.nc barkley/HRDPS_OPPwest_ps2.5km_y2015_binned.nc
cdo expr,'wind_dir_binned=360*(wind_dir>=-22.5)*(wind_dir<22.5)+45*(wind_dir>=22.5)*(wind_dir<67.5)+90*(wind_dir>=67.5)*(wind_dir<112.5)+135*(wind_dir>=112.5)*(wind_dir<157.5)+180*((wind_dir>=157.5)+(wind_dir<=-157.5))+225*(wind_dir>-157.5)*(wind_dir<=-112.5)+270*(wind_dir>-112.5)*(wind_dir<=-67.5)+315*(wind_dir>-67.5)*(wind_dir<=-22.5)' barkley/HRDPS_OPPwest_ps2.5km_y2016.nc barkley/HRDPS_OPPwest_ps2.5km_y2016_binned.nc
cdo expr,'wind_dir_binned=360*(wind_dir>=-22.5)*(wind_dir<22.5)+45*(wind_dir>=22.5)*(wind_dir<67.5)+90*(wind_dir>=67.5)*(wind_dir<112.5)+135*(wind_dir>=112.5)*(wind_dir<157.5)+180*((wind_dir>=157.5)+(wind_dir<=-157.5))+225*(wind_dir>-157.5)*(wind_dir<=-112.5)+270*(wind_dir>-112.5)*(wind_dir<=-67.5)+315*(wind_dir>-67.5)*(wind_dir<=-22.5)' barkley/HRDPS_OPPwest_ps2.5km_y2017.nc barkley/HRDPS_OPPwest_ps2.5km_y2017_binned.nc
cdo expr,'wind_dir_binned=360*(wind_dir>=-22.5)*(wind_dir<22.5)+45*(wind_dir>=22.5)*(wind_dir<67.5)+90*(wind_dir>=67.5)*(wind_dir<112.5)+135*(wind_dir>=112.5)*(wind_dir<157.5)+180*((wind_dir>=157.5)+(wind_dir<=-157.5))+225*(wind_dir>-157.5)*(wind_dir<=-112.5)+270*(wind_dir>-112.5)*(wind_dir<=-67.5)+315*(wind_dir>-67.5)*(wind_dir<=-22.5)' barkley/HRDPS_OPPwest_ps2.5km_y2018.nc barkley/HRDPS_OPPwest_ps2.5km_y2018_binned.nc
cdo expr,'wind_dir_binned=360*(wind_dir>=-22.5)*(wind_dir<22.5)+45*(wind_dir>=22.5)*(wind_dir<67.5)+90*(wind_dir>=67.5)*(wind_dir<112.5)+135*(wind_dir>=112.5)*(wind_dir<157.5)+180*((wind_dir>=157.5)+(wind_dir<=-157.5))+225*(wind_dir>-157.5)*(wind_dir<=-112.5)+270*(wind_dir>-112.5)*(wind_dir<=-67.5)+315*(wind_dir>-67.5)*(wind_dir<=-22.5)' barkley/HRDPS_OPPwest_ps2.5km_y2019.nc barkley/HRDPS_OPPwest_ps2.5km_y2019_binned.nc
cdo expr,'wind_dir_binned=360*(wind_dir>=-22.5)*(wind_dir<22.5)+45*(wind_dir>=22.5)*(wind_dir<67.5)+90*(wind_dir>=67.5)*(wind_dir<112.5)+135*(wind_dir>=112.5)*(wind_dir<157.5)+180*((wind_dir>=157.5)+(wind_dir<=-157.5))+225*(wind_dir>-157.5)*(wind_dir<=-112.5)+270*(wind_dir>-112.5)*(wind_dir<=-67.5)+315*(wind_dir>-67.5)*(wind_dir<=-22.5)' barkley/HRDPS_OPPwest_ps2.5km_y2020.nc barkley/HRDPS_OPPwest_ps2.5km_y2020_binned.nc
cdo expr,'wind_dir_binned=360*(wind_dir>=-22.5)*(wind_dir<22.5)+45*(wind_dir>=22.5)*(wind_dir<67.5)+90*(wind_dir>=67.5)*(wind_dir<112.5)+135*(wind_dir>=112.5)*(wind_dir<157.5)+180*((wind_dir>=157.5)+(wind_dir<=-157.5))+225*(wind_dir>-157.5)*(wind_dir<=-112.5)+270*(wind_dir>-112.5)*(wind_dir<=-67.5)+315*(wind_dir>-67.5)*(wind_dir<=-22.5)' barkley/HRDPS_OPPwest_ps2.5km_y2021.nc barkley/HRDPS_OPPwest_ps2.5km_y2021_binned.nc
cdo expr,'wind_dir_binned=360*(wind_dir>=-22.5)*(wind_dir<22.5)+45*(wind_dir>=22.5)*(wind_dir<67.5)+90*(wind_dir>=67.5)*(wind_dir<112.5)+135*(wind_dir>=112.5)*(wind_dir<157.5)+180*((wind_dir>=157.5)+(wind_dir<=-157.5))+225*(wind_dir>-157.5)*(wind_dir<=-112.5)+270*(wind_dir>-112.5)*(wind_dir<=-67.5)+315*(wind_dir>-67.5)*(wind_dir<=-22.5)' barkley/HRDPS_OPPwest_ps2.5km_y2022.nc barkley/HRDPS_OPPwest_ps2.5km_y2022_binned.nc

# 9. Calculate min and max values required for percentile calculations.
cdo timmin barkley/HRDPS_OPPwest_ps2.5km.nc barkley/HRDPS_OPPwest_ps2.5km_timmin.nc
cdo timmax barkley/HRDPS_OPPwest_ps2.5km.nc barkley/HRDPS_OPPwest_ps2.5km_timmax.nc

# 10. Calculate 95th percentile value for wind speed per point, over all time steps.
cdo timpctl,95 -chname,wind_spd,q95 -selvar,wind_spd barkley/HRDPS_OPPwest_ps2.5km.nc -selvar,wind_spd barkley/HRDPS_OPPwest_ps2.5km_timmin.nc -selvar,wind_spd barkley/HRDPS_OPPwest_ps2.5km_timmax.nc barkley/HRDPS_OPPwest_ps2.5km_q95.nc

# 11. Create a mask using 95 percentile values.
cdo -O ge -chname,wind_spd,mask -selvar,wind_spd barkley/HRDPS_OPPwest_ps2.5km.nc -chname,q95,wind_spd -selvar,q95 barkley/HRDPS_OPPwest_ps2.5km_q95.nc barkley/HRDPS_OPPwest_ps2.5km_mask.nc

# 12. Merge variables with output from step 7.
cdo merge barkley/HRDPS_OPPwest_ps2.5km.nc barkley/HRDPS_OPPwest_ps2.5km_binned360.nc  barkley/HRDPS_OPPwest_ps2.5km_q95.nc barkley/HRDPS_OPPwest_ps2.5km_mask.nc barkley/HRDPS_OPPwest_ps2.5km_merged.nc

# 13. Calculate frequency in each binned direction.
cdo histfreq,45,90,135,180,225,270,315,360,inf -chname,wind_dir_binned,freq_total -selname,wind_dir_binned barkley/HRDPS_OPPwest_ps2.5km_merged.nc barkley/HRDPS_OPPwest_ps2.5km_frequency.nc

# 14. Merge frequency and merged files.
cdo merge barkley/HRDPS_OPPwest_ps2.5km_merged.nc barkley/HRDPS_OPPwest_ps2.5km_frequency.nc barkley/HRDPS_OPPwest_ps2.5km_final.nc

# 15. Calculate grand mean.
# a) Subset data by wind_dir_binned value
cdo -eqc,45. -selvar,wind_dir_binned barkley/HRDPS_OPPwest_ps2.5km_final.nc barkley/binned/mask_45.nc
cdo -eqc,90. -selvar,wind_dir_binned barkley/HRDPS_OPPwest_ps2.5km_final.nc barkley/binned/mask_90.nc
cdo -eqc,135. -selvar,wind_dir_binned barkley/HRDPS_OPPwest_ps2.5km_final.nc barkley/binned/mask_135.nc
cdo -eqc,180. -selvar,wind_dir_binned barkley/HRDPS_OPPwest_ps2.5km_final.nc barkley/binned/mask_180.nc
cdo -eqc,225. -selvar,wind_dir_binned barkley/HRDPS_OPPwest_ps2.5km_final.nc barkley/binned/mask_225.nc
cdo -eqc,270. -selvar,wind_dir_binned barkley/HRDPS_OPPwest_ps2.5km_final.nc barkley/binned/mask_270.nc
cdo -eqc,315. -selvar,wind_dir_binned barkley/HRDPS_OPPwest_ps2.5km_final.nc barkley/binned/mask_315.nc
cdo -eqc,360. -selvar,wind_dir_binned barkley/HRDPS_OPPwest_ps2.5km_final.nc barkley/binned/mask_360.nc

# b) Assign NAs to data where the mask is 0
cdo ifthen barkley/binned/mask_45.nc barkley/binned/mask_45.nc barkley/binned/mask_45_with_nas.nc
cdo ifthen barkley/binned/mask_90.nc barkley/binned/mask_90.nc barkley/binned/mask_90_with_nas.nc
cdo ifthen barkley/binned/mask_135.nc barkley/binned/mask_135.nc barkley/binned/mask_135_with_nas.nc
cdo ifthen barkley/binned/mask_180.nc barkley/binned/mask_180.nc barkley/binned/mask_180_with_nas.nc
cdo ifthen barkley/binned/mask_225.nc barkley/binned/mask_225.nc barkley/binned/mask_225_with_nas.nc
cdo ifthen barkley/binned/mask_270.nc barkley/binned/mask_270.nc barkley/binned/mask_270_with_nas.nc
cdo ifthen barkley/binned/mask_315.nc barkley/binned/mask_315.nc barkley/binned/mask_315_with_nas.nc
cdo ifthen barkley/binned/mask_360.nc barkley/binned/mask_360.nc barkley/binned/mask_360_with_nas.nc

# c) Calculate daily max values for each binned direction
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd -mul -daymax barkley/HRDPS_OPPwest_ps2.5km_final.nc barkley/binned/mask_45_with_nas.nc barkley/binned/max_wind_45.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd -mul -daymax barkley/HRDPS_OPPwest_ps2.5km_final.nc barkley/binned/mask_90_with_nas.nc barkley/binned/max_wind_90.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd -mul -daymax barkley/HRDPS_OPPwest_ps2.5km_final.nc barkley/binned/mask_135_with_nas.nc barkley/binned/max_wind_135.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd -mul -daymax barkley/HRDPS_OPPwest_ps2.5km_final.nc barkley/binned/mask_180_with_nas.nc barkley/binned/max_wind_180.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd -mul -daymax barkley/HRDPS_OPPwest_ps2.5km_final.nc barkley/binned/mask_225_with_nas.nc barkley/binned/max_wind_225.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd -mul -daymax barkley/HRDPS_OPPwest_ps2.5km_final.nc barkley/binned/mask_270_with_nas.nc barkley/binned/max_wind_270.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd -mul -daymax barkley/HRDPS_OPPwest_ps2.5km_final.nc barkley/binned/mask_315_with_nas.nc barkley/binned/max_wind_315.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd -mul -daymax barkley/HRDPS_OPPwest_ps2.5km_final.nc barkley/binned/mask_360_with_nas.nc barkley/binned/max_wind_360.nc

# d) Calculate monthly mean of daily max values for each binned direction
cdo -monmean barkley/binned/max_wind_45.nc barkley/binned/monmean_45.nc 
cdo -monmean barkley/binned/max_wind_90.nc barkley/binned/monmean_90.nc 
cdo -monmean barkley/binned/max_wind_135.nc barkley/binned/monmean_135.nc 
cdo -monmean barkley/binned/max_wind_180.nc barkley/binned/monmean_180.nc 
cdo -monmean barkley/binned/max_wind_225.nc barkley/binned/monmean_225.nc 
cdo -monmean barkley/binned/max_wind_270.nc barkley/binned/monmean_270.nc 
cdo -monmean barkley/binned/max_wind_315.nc barkley/binned/monmean_315.nc 
cdo -monmean barkley/binned/max_wind_360.nc barkley/binned/monmean_360.nc

# e) Calculate grand mean (mean of monthly mean of daily max values) for each binned direction
cdo timmean barkley/binned/monmean_45.nc barkley/binned/grandmean_45.nc
cdo timmean barkley/binned/monmean_90.nc barkley/binned/grandmean_90.nc
cdo timmean barkley/binned/monmean_135.nc barkley/binned/grandmean_135.nc
cdo timmean barkley/binned/monmean_180.nc barkley/binned/grandmean_180.nc
cdo timmean barkley/binned/monmean_225.nc barkley/binned/grandmean_225.nc
cdo timmean barkley/binned/monmean_270.nc barkley/binned/grandmean_270.nc
cdo timmean barkley/binned/monmean_315.nc barkley/binned/grandmean_315.nc
cdo timmean barkley/binned/monmean_360.nc barkley/binned/grandmean_360.nc

# f) Add the wind_dir_binned constant value variable to each grand mean
cdo -expr,'wind_dir_binned=(max_wind_spd*0+45)' barkley/binned/grandmean_45.nc barkley/binned/45_tmp.nc
cdo merge barkley/binned/45_tmp.nc barkley/binned/grandmean_45.nc barkley/binned/grandmean_45_bin.nc
rm barkley/binned/45_tmp.nc barkley/binned/grandmean_45.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+90)' barkley/binned/grandmean_90.nc barkley/binned/90_tmp.nc
cdo merge barkley/binned/90_tmp.nc barkley/binned/grandmean_90.nc barkley/binned/grandmean_90_bin.nc
rm barkley/binned/90_tmp.nc barkley/binned/grandmean_90.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+135)' barkley/binned/grandmean_135.nc barkley/binned/135_tmp.nc
cdo merge barkley/binned/135_tmp.nc barkley/binned/grandmean_135.nc barkley/binned/grandmean_135_bin.nc
rm barkley/binned/135_tmp.nc barkley/binned/grandmean_135.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+180)' barkley/binned/grandmean_180.nc barkley/binned/180_tmp.nc
cdo merge barkley/binned/180_tmp.nc barkley/binned/grandmean_180.nc barkley/binned/grandmean_180_bin.nc
rm barkley/binned/180_tmp.nc barkley/binned/grandmean_180.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+225)' barkley/binned/grandmean_225.nc barkley/binned/225_tmp.nc
cdo merge barkley/binned/225_tmp.nc barkley/binned/grandmean_225.nc barkley/binned/grandmean_225_bin.nc
rm barkley/binned/225_tmp.nc barkley/binned/grandmean_225.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+270)' barkley/binned/grandmean_270.nc barkley/binned/270_tmp.nc
cdo merge barkley/binned/270_tmp.nc barkley/binned/grandmean_270.nc barkley/binned/grandmean_270_bin.nc
rm barkley/binned/270_tmp.nc barkley/binned/grandmean_270.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+315)' barkley/binned/grandmean_315.nc barkley/binned/315_tmp.nc
cdo merge barkley/binned/315_tmp.nc barkley/binned/grandmean_315.nc barkley/binned/grandmean_315_bin.nc
rm barkley/binned/315_tmp.nc barkley/binned/grandmean_315.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+360)' barkley/binned/grandmean_360.nc barkley/binned/360_tmp.nc
cdo merge barkley/binned/360_tmp.nc barkley/binned/grandmean_360.nc barkley/binned/grandmean_360_bin.nc
rm barkley/binned/360_tmp.nc barkley/binned/grandmean_360.nc

# 16. Merge all grand mean direction files
cdo merge [ barkley/binned/grandmean_*.nc ] barkley/HRDPS_OPPwest_ps2.5km_grandmean.nc
