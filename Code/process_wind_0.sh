#! /bin/bash

# 0. Create directiories
mkdir merged

# 1. Merge daily files into a single file, only retain u_wind and v_wind variables.
cdo mergetime -apply,selname,u_wind,v_wind [ 2015/*.nc ] merged/2015.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2016/1/*.nc ] merged/2016_1.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2016/2/*.nc ] merged/2016_2.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2016/3/*.nc ] merged/2016_3.nc
cdo mergetime -apply,selname,u_wind,v_wind [ merged/2016*.nc ] merged/2016.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2017/1/*.nc ] merged/2017_1.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2017/2/*.nc ] merged/2017_2.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2017/3/*.nc ] merged/2017_3.nc
cdo mergetime -apply,selname,u_wind,v_wind [ merged/2017*.nc ] merged/2017.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2018/1/*.nc ] merged/2018_1.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2018/2/*.nc ] merged/2018_2.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2018/3/*.nc ] merged/2018_3.nc
cdo mergetime -apply,selname,u_wind,v_wind [ merged/2018*.nc ] merged/2018.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2019/1/*.nc ] merged/2019_1.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2019/2/*.nc ] merged/2019_2.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2019/3/*.nc ] merged/2019_3.nc
cdo mergetime -apply,selname,u_wind,v_wind [ merged/2019*.nc ] merged/2019.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2020/1/*.nc ] merged/2020_1.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2020/2/*.nc ] merged/2020_2.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2020/3/*.nc ] merged/2020_3.nc
cdo mergetime -apply,selname,u_wind,v_wind [ merged/2020*.nc ] merged/2020.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2021/1/*.nc ] merged/2021_1.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2021/2/*.nc ] merged/2021_2.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2021/3/*.nc ] merged/2021_3.nc
cdo mergetime -apply,selname,u_wind,v_wind [ merged/2021*.nc ] merged/2021.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2022/1/*.nc ] merged/2022_1.nc
cdo mergetime -apply,selname,u_wind,v_wind [ 2022/2/*.nc ] merged/2022_2.nc
cdo mergetime -apply,selname,u_wind,v_wind [ merged/2022*.nc ] merged/2022.nc

# 2. Calculate wind speed variable for each of the merged files.
cdo -O -expr,'wind_spd=sqrt(u_wind*u_wind+v_wind*v_wind)' -selname,u_wind,v_wind merged/2015.nc merged/2015_ws.nc
cdo -O -expr,'wind_spd=sqrt(u_wind*u_wind+v_wind*v_wind)' -selname,u_wind,v_wind merged/2016.nc merged/2016_ws.nc
cdo -O -expr,'wind_spd=sqrt(u_wind*u_wind+v_wind*v_wind)' -selname,u_wind,v_wind merged/2017.nc merged/2017_ws.nc
cdo -O -expr,'wind_spd=sqrt(u_wind*u_wind+v_wind*v_wind)' -selname,u_wind,v_wind merged/2018.nc merged/2018_ws.nc
cdo -O -expr,'wind_spd=sqrt(u_wind*u_wind+v_wind*v_wind)' -selname,u_wind,v_wind merged/2019.nc merged/2019_ws.nc
cdo -O -expr,'wind_spd=sqrt(u_wind*u_wind+v_wind*v_wind)' -selname,u_wind,v_wind merged/2020.nc merged/2020_ws.nc
cdo -O -expr,'wind_spd=sqrt(u_wind*u_wind+v_wind*v_wind)' -selname,u_wind,v_wind merged/2021.nc merged/2021_ws.nc
cdo -O -expr,'wind_spd=sqrt(u_wind*u_wind+v_wind*v_wind)' -selname,u_wind,v_wind merged/2022.nc merged/2022_ws.nc

# 3. Calculate wind direction for each of the merged files.
cdo -O -chname,u_wind,wind_dir -mulc,57.3 -atan2 -mulc,-1 -selname,u_wind merged/2015.nc -mulc,-1 -selname,v_wind merged/2015.nc merged/2015_wd.nc
cdo -O -chname,u_wind,wind_dir -mulc,57.3 -atan2 -mulc,-1 -selname,u_wind merged/2016.nc -mulc,-1 -selname,v_wind merged/2016.nc merged/2016_wd.nc
cdo -O -chname,u_wind,wind_dir -mulc,57.3 -atan2 -mulc,-1 -selname,u_wind merged/2017.nc -mulc,-1 -selname,v_wind merged/2017.nc merged/2017_wd.nc
cdo -O -chname,u_wind,wind_dir -mulc,57.3 -atan2 -mulc,-1 -selname,u_wind merged/2018.nc -mulc,-1 -selname,v_wind merged/2018.nc merged/2018_wd.nc
cdo -O -chname,u_wind,wind_dir -mulc,57.3 -atan2 -mulc,-1 -selname,u_wind merged/2019.nc -mulc,-1 -selname,v_wind merged/2019.nc merged/2019_wd.nc
cdo -O -chname,u_wind,wind_dir -mulc,57.3 -atan2 -mulc,-1 -selname,u_wind merged/2020.nc -mulc,-1 -selname,v_wind merged/2020.nc merged/2020_wd.nc
cdo -O -chname,u_wind,wind_dir -mulc,57.3 -atan2 -mulc,-1 -selname,u_wind merged/2021.nc -mulc,-1 -selname,v_wind merged/2021.nc merged/2021_wd.nc
cdo -O -chname,u_wind,wind_dir -mulc,57.3 -atan2 -mulc,-1 -selname,u_wind merged/2022.nc -mulc,-1 -selname,v_wind merged/2022.nc merged/2022_wd.nc

# 4. Merge wind speed and wind direction variables into a single file.
cdo -O -merge merged/2015_ws.nc merged/2015_wd.nc merged/HRDPS_OPPwest_ps2.5km_y2015.nc
cdo -O -merge merged/2016_ws.nc merged/2016_wd.nc merged/HRDPS_OPPwest_ps2.5km_y2016.nc
cdo -O -merge merged/2017_ws.nc merged/2017_wd.nc merged/HRDPS_OPPwest_ps2.5km_y2017.nc
cdo -O -merge merged/2018_ws.nc merged/2018_wd.nc merged/HRDPS_OPPwest_ps2.5km_y2018.nc
cdo -O -merge merged/2019_ws.nc merged/2019_wd.nc merged/HRDPS_OPPwest_ps2.5km_y2019.nc
cdo -O -merge merged/2020_ws.nc merged/2020_wd.nc merged/HRDPS_OPPwest_ps2.5km_y2020.nc
cdo -O -merge merged/2021_ws.nc merged/2021_wd.nc merged/HRDPS_OPPwest_ps2.5km_y2021.nc
cdo -O -merge merged/2022_ws.nc merged/2022_wd.nc merged/HRDPS_OPPwest_ps2.5km_y2022.nc

# 5. Remove intermediate files that are now merged.
rm merged/*_ws.nc
rm merged/*_wd.nc
