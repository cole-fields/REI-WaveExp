#! /bin/bash

# 6. Subset data by geographic location.
# Get the positions from D:\projects\sdm-framework\_Data\bounding_boxes.gdb polygon extents (LL, UR)
# ----------
# Barkley (note this is just from interpolated wind data done after the fact. not the poly extent.)
# ----------
# Upper Left  ( 1012715.598,  480733.400) (125d49'30.58"W, 49d20'34.08"N)
# Lower Left  ( 1012715.598,  389093.400) (125d49'41.59"W, 48d31' 3.43"N)
# Upper Right ( 1104655.598,  480733.400) (124d33'40.30"W, 49d20' 0.13"N)
# Lower Right ( 1104655.598,  389093.400) (124d35'10.85"W, 48d30'30.03"N)
# Center      ( 1058685.598,  434913.400) (125d12' 0.83"W, 48d55'39.00"N)
# ----------
# West Coast Vancouver Island
# ----------
# 761851.8870429138187319,341358.6138938328367658 : 1177962.7083740374073386,695430.8700691995909438
# Convert these to 4326 WGS84 in rei_functions.convert_coordinates
# Get string with rei_functions.get_bounding_box_str
# x, y = convert_coordinates(761851.8870429138187319, 341358.6138938328367658, 3005, 4326)
# ll = (x, y)
# x2, y2 = convert_coordinates(1177962.7083740374073386, 695430.8700691995909438, 3005, 4326)
# ur = (x2, y2)
# get_bounding_box_str(ll, ur)
# '230.813941,236.552349,48.039146,51.243657'
# ----------
# Strait of Georgia
# ----------
# 1013362.3517000004649162,352480.7473000008612871 : 1271604.4087000004947186,680043.4448000006377697
# '234.179265,237.881042,48.18761,51.067458'
# ----------
# Haida Gwaii
# ----------
# 518469.2995671915123239,764151.8948846120620146 : 667720.4941296024480835,1064361.7786147273145616
# '227.016025,228.856123,51.675875,54.471927'
# ----------
# Queen Charlotte Strait
# ----------
# 846215.6487249442143366,587245.4325569448992610 : 1058569.3713713241741061,702292.3004146919120103
# 231.841477,234.841499,50.279702,51.330927
# ----------
# North Central Coast
# ----------
# 595578.8932000007480383,655689.4747999999672174 : 1000324.0229000002145767,1226615.5230999998748302
# 228.256264,234.00521,50.768214,56.033751

# Use a bounding box to extract a subset of data
# sellonlatbox,lon1,lon2,lat1,lat2  infile outfile
# PARAMETER
#    lon1  FLOAT    Western longitude
#    lon2  FLOAT    Eastern longitude
#    lat1  FLOAT    Southern or northern latitude
#    lat2  FLOAT    Northern or southern latitude
# cdo sellonlatbox,$2 merged/HRDPS_OPPwest_ps2.5km_y2015.nc $1/HRDPS_OPPwest_ps2.5km_y2015.nc
# cdo sellonlatbox,$2 merged/HRDPS_OPPwest_ps2.5km_y2016.nc $1/HRDPS_OPPwest_ps2.5km_y2016.nc
# cdo sellonlatbox,$2 merged/HRDPS_OPPwest_ps2.5km_y2017.nc $1/HRDPS_OPPwest_ps2.5km_y2017.nc
# cdo sellonlatbox,$2 merged/HRDPS_OPPwest_ps2.5km_y2018.nc $1/HRDPS_OPPwest_ps2.5km_y2018.nc
# cdo sellonlatbox,$2 merged/HRDPS_OPPwest_ps2.5km_y2019.nc $1/HRDPS_OPPwest_ps2.5km_y2019.nc
# cdo sellonlatbox,$2 merged/HRDPS_OPPwest_ps2.5km_y2020.nc $1/HRDPS_OPPwest_ps2.5km_y2020.nc
# cdo sellonlatbox,$2 merged/HRDPS_OPPwest_ps2.5km_y2021.nc $1/HRDPS_OPPwest_ps2.5km_y2021.nc
# cdo sellonlatbox,$2 merged/HRDPS_OPPwest_ps2.5km_y2022.nc $1/HRDPS_OPPwest_ps2.5km_y2022.nc

# # 7. Merge all years.
# cdo mergetime [ $1/*.nc ] $1/HRDPS_OPPwest_ps2.5km.nc

# # 8. Create binned direction.
# cdo expr,'wind_dir_binned=(wind_dir>=-22.5)*(wind_dir<22.5)*360+(wind_dir>=22.5)*(wind_dir<67.5)*45+(wind_dir>=67.5)*(wind_dir<112.5)*90+(wind_dir>=112.5)*(wind_dir<157.5)*135+((wind_dir>=157.5)+(wind_dir<=-157.5))*180+(wind_dir>-157.5)*(wind_dir<=-112.5)*225+(wind_dir>-112.5)*(wind_dir<=-67.5)*270+(wind_dir>-67.5)*(wind_dir<=-22.5)*315' $1/HRDPS_OPPwest_ps2.5km.nc $1/HRDPS_OPPwest_ps2.5km_binned360.nc

# # 9. Calculate min and max values required for percentile calculations.
# cdo timmin $1/HRDPS_OPPwest_ps2.5km.nc $1/HRDPS_OPPwest_ps2.5km_timmin.nc
# cdo timmax $1/HRDPS_OPPwest_ps2.5km.nc $1/HRDPS_OPPwest_ps2.5km_timmax.nc

# 10. Calculate 95th percentile value for wind speed per point, over all time steps.
cdo timpctl,95 -chname,wind_spd,q95 -selvar,wind_spd $1/HRDPS_OPPwest_ps2.5km.nc -selvar,wind_spd $1/HRDPS_OPPwest_ps2.5km_timmin.nc -selvar,wind_spd $1/HRDPS_OPPwest_ps2.5km_timmax.nc $1/HRDPS_OPPwest_ps2.5km_q95.nc

# 11. Create a mask using 95 percentile values.
cdo -O ge -chname,wind_spd,mask -selvar,wind_spd $1/HRDPS_OPPwest_ps2.5km.nc -chname,q95,wind_spd -selvar,q95 $1/HRDPS_OPPwest_ps2.5km_q95.nc $1/HRDPS_OPPwest_ps2.5km_mask.nc

# 12. Merge variables with output from step 7.
cdo merge $1/HRDPS_OPPwest_ps2.5km.nc $1/HRDPS_OPPwest_ps2.5km_binned360.nc  $1/HRDPS_OPPwest_ps2.5km_q95.nc $1/HRDPS_OPPwest_ps2.5km_mask.nc $1/HRDPS_OPPwest_ps2.5km_merged.nc

# 13. Calculate frequency in each binned direction.
cdo histfreq,45,90,135,180,225,270,315,360,inf -chname,wind_dir_binned,freq_total -selname,wind_dir_binned $1/HRDPS_OPPwest_ps2.5km_merged.nc $1/HRDPS_OPPwest_ps2.5km_frequency.nc

# 14. Merge frequency and merged files.
cdo merge $1/HRDPS_OPPwest_ps2.5km_merged.nc $1/HRDPS_OPPwest_ps2.5km_frequency.nc $1/HRDPS_OPPwest_ps2.5km_final.nc

# 15. Calculate grand mean.
# a) Create mask layer with 1s and missing values (not zeros) for greater or equal to threshold for wind speed.
cdo -setctomiss,0 -eqc,1. -selvar,mask $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask_spd45.nc
cdo -setctomiss,0 -eqc,1. -selvar,mask $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask_spd90.nc
cdo -setctomiss,0 -eqc,1. -selvar,mask $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask_spd135.nc$2
cdo -setctomiss,0 -eqc,1. -selvar,mask $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask_spd180.nc
cdo -setctomiss,0 -eqc,1. -selvar,mask $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask_spd225.nc
cdo -setctomiss,0 -eqc,1. -selvar,mask $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask_spd270.nc
cdo -setctomiss,0 -eqc,1. -selvar,mask $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask_spd315.nc
cdo -setctomiss,0 -eqc,1. -selvar,mask $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask_spd360.nc

# b) Create mask layer with 1s and missing values (not zeros) for binned wind direction.
cdo -setctomiss,0 -eqc,45. -selvar,wind_dir_binned $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask_bin45.nc
cdo -setctomiss,0 -eqc,90. -selvar,wind_dir_binned $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask_bin90.nc
cdo -setctomiss,0 -eqc,135. -selvar,wind_dir_binned $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask_bin135.nc
cdo -setctomiss,0 -eqc,180. -selvar,wind_dir_binned $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask_bin180.nc
cdo -setctomiss,0 -eqc,225. -selvar,wind_dir_binned $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask_bin225.nc
cdo -setctomiss,0 -eqc,270. -selvar,wind_dir_binned $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask_bin270.nc
cdo -setctomiss,0 -eqc,315. -selvar,wind_dir_binned $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask_bin315.nc
cdo -setctomiss,0 -eqc,360. -selvar,wind_dir_binned $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask_bin360.nc

# c) Multiply these together for a mask where both conditions must be met (>= threshold wind speed and the binned wind direction).
cdo mul $1/binned/mask_bin45.nc $1/binned/mask_spd45.nc $1/binned/mask45.nc
rm $1/binned/mask_spd45.nc $1/binned/mask_bin45.nc
cdo mul $1/binned/mask_bin90.nc $1/binned/mask_spd90.nc $1/binned/mask90.nc
rm $1/binned/mask_spd90.nc $1/binned/mask_bin90.nc
cdo mul $1/binned/mask_bin135.nc $1/binned/mask_spd135.nc $1/binned/mask135.nc
rm $1/binned/mask_spd135.nc $1/binned/mask_bin135.nc
cdo mul $1/binned/mask_bin180.nc $1/binned/mask_spd180.nc $1/binned/mask180.nc
rm $1/binned/mask_spd180.nc $1/binned/mask_bin180.nc
cdo mul $1/binned/mask_bin225.nc $1/binned/mask_spd225.nc $1/binned/mask225.nc
rm $1/binned/mask_spd225.nc $1/binned/mask_bin225.nc
cdo mul $1/binned/mask_bin270.nc $1/binned/mask_spd270.nc $1/binned/mask270.nc
rm $1/binned/mask_spd270.nc $1/binned/mask_bin270.nc
cdo mul $1/binned/mask_bin315.nc $1/binned/mask_spd315.nc $1/binned/mask315.nc
rm $1/binned/mask_spd315.nc $1/binned/mask_bin315.nc
cdo mul $1/binned/mask_bin360.nc $1/binned/mask_spd360.nc $1/binned/mask360.nc
rm $1/binned/mask_spd360.nc $1/binned/mask_bin360.nc

# d) Now multiply mask by our data.
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd  -daymax -mul $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask45.nc $1/binned/max_wind_45.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd  -daymax -mul $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask90.nc $1/binned/max_wind_90.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd  -daymax -mul $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask135.nc $1/binned/max_wind_135.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd  -daymax -mul $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask180.nc $1/binned/max_wind_180.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd  -daymax -mul $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask225.nc $1/binned/max_wind_225.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd  -daymax -mul $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask270.nc $1/binned/max_wind_270.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd  -daymax -mul $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask315.nc $1/binned/max_wind_315.nc
cdo -chname,wind_spd,max_wind_spd -selname,wind_spd  -daymax -mul $1/HRDPS_OPPwest_ps2.5km_final.nc $1/binned/mask360.nc $1/binned/max_wind_360.nc

#e) Calculate monthly mean of daily maxes.
cdo -monmean  $1/binned/max_wind_45.nc $1/binned/monmean_45.nc
cdo -monmean  $1/binned/max_wind_90.nc $1/binned/monmean_90.nc 
cdo -monmean  $1/binned/max_wind_135.nc $1/binned/monmean_135.nc 
cdo -monmean  $1/binned/max_wind_180.nc $1/binned/monmean_180.nc 
cdo -monmean  $1/binned/max_wind_225.nc $1/binned/monmean_225.nc
cdo -monmean  $1/binned/max_wind_270.nc $1/binned/monmean_270.nc 
cdo -monmean  $1/binned/max_wind_315.nc $1/binned/monmean_315.nc 
cdo -monmean  $1/binned/max_wind_360.nc $1/binned/monmean_360.nc 

# f) Calculate grand mean (mean of monthly mean of daily max values) for each binned direction.
cdo timmean $1/binned/monmean_45.nc $1/binned/grandmean_45.nc
cdo timmean $1/binned/monmean_90.nc $1/binned/grandmean_90.nc
cdo timmean $1/binned/monmean_135.nc $1/binned/grandmean_135.nc
cdo timmean $1/binned/monmean_180.nc $1/binned/grandmean_180.nc
cdo timmean $1/binned/monmean_225.nc $1/binned/grandmean_225.nc
cdo timmean $1/binned/monmean_270.nc $1/binned/grandmean_270.nc
cdo timmean $1/binned/monmean_315.nc $1/binned/grandmean_315.nc
cdo timmean $1/binned/monmean_360.nc $1/binned/grandmean_360.nc

# g) Add the wind_dir_binned constant value variable to each grand mean
cdo -expr,'wind_dir_binned=(max_wind_spd*0+45)' $1/binned/grandmean_45.nc $1/binned/45_tmp.nc
cdo merge $1/binned/45_tmp.nc $1/binned/grandmean_45.nc $1/binned/grandmean_45_bin.nc
rm $1/binned/45_tmp.nc $1/binned/grandmean_45.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+90)' $1/binned/grandmean_90.nc $1/binned/90_tmp.nc
cdo merge $1/binned/90_tmp.nc $1/binned/grandmean_90.nc $1/binned/grandmean_90_bin.nc
rm $1/binned/90_tmp.nc $1/binned/grandmean_90.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+135)' $1/binned/grandmean_135.nc $1/binned/135_tmp.nc
cdo merge $1/binned/135_tmp.nc $1/binned/grandmean_135.nc $1/binned/grandmean_135_bin.nc
rm $1/binned/135_tmp.nc $1/binned/grandmean_135.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+180)' $1/binned/grandmean_180.nc $1/binned/180_tmp.nc
cdo merge $1/binned/180_tmp.nc $1/binned/grandmean_180.nc $1/binned/grandmean_180_bin.nc
rm $1/binned/180_tmp.nc $1/binned/grandmean_180.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+225)' $1/binned/grandmean_225.nc $1/binned/225_tmp.nc
cdo merge $1/binned/225_tmp.nc $1/binned/grandmean_225.nc $1/binned/grandmean_225_bin.nc
rm $1/binned/225_tmp.nc $1/binned/grandmean_225.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+270)' $1/binned/grandmean_270.nc $1/binned/270_tmp.nc
cdo merge $1/binned/270_tmp.nc $1/binned/grandmean_270.nc $1/binned/grandmean_270_bin.nc
rm $1/binned/270_tmp.nc $1/binned/grandmean_270.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+315)' $1/binned/grandmean_315.nc $1/binned/315_tmp.nc
cdo merge $1/binned/315_tmp.nc $1/binned/grandmean_315.nc $1/binned/grandmean_315_bin.nc
rm $1/binned/315_tmp.nc $1/binned/grandmean_315.nc

cdo -expr,'wind_dir_binned=(max_wind_spd*0+360)' $1/binned/grandmean_360.nc $1/binned/360_tmp.nc
cdo merge $1/binned/360_tmp.nc $1/binned/grandmean_360.nc $1/binned/grandmean_360_bin.nc
rm $1/binned/360_tmp.nc $1/binned/grandmean_360.nc

# 16. Merge all grand mean direction files
cdo merge [ $1/binned/grandmean_*.nc ] $1/HRDPS_OPPwest_ps2.5km_grandmean.nc