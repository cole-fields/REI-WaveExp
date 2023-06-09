"""
This script opens 2 existing NetCDF files and should be run from in the directory where these files are located. Set the REGION variable. 
One that contains frequency of wind direction for a given location and one that contains the grand mean wind speed (mean of the monthly 
means of daily maximums for each grid location). Pandas dataframes are used to combine
the data into a single dataframe such as this:

                    lat_dd      lon_dd  direction     mx_spd      freq
6534  48.517288 -125.655457       45.0   9.791371  0.043672
7623  48.517288 -125.655457       90.0  10.101445  0.098437
0     48.517288 -125.655457      135.0   9.358426  0.145371
1089  48.517288 -125.655457      180.0   9.747580  0.138621
2178  48.517288 -125.655457      225.0   9.630091  0.097670
3267  48.517288 -125.655457      270.0   9.765584  0.141691
4356  48.517288 -125.655457      315.0   9.580989  0.295608
5445  48.517288 -125.655457      360.0  10.503599  0.038928

For each location, there are 8 binned directions with a mx_spd (grand mean value) and the 
frequency (freq) of winds that occurred in within the direction bin. The total of freq 
for each location should equal 1.

The dataframe example above is then converted into a wide format and written to disk 
as a spatial object. Wide format dataframe sample:settings.

                lat_dd      lon_dd  mx_spd_45  mx_spd_90  mx_spd_135  mx_spd_180  mx_spd_225  mx_spd_270  ...   freq_45   freq_90  freq_135  freq_180  freq_225  freq_270  freq_315  freq_360
0     48.517288 -125.655457   9.791371  10.101445    9.358426    9.747580    9.630091    9.765584  ...  0.043672  0.098437  0.145371  0.138621  0.097670  0.141691  0.295608  0.038928
1     48.520733 -125.622025   9.497159  10.024062    9.247731    9.869636    9.494383    9.771334  ...  0.044492  0.100565  0.145912  0.138028  0.097286  0.142895  0.292731  0.038091
2     48.524174 -125.588562   9.322028   9.652866    9.258135    9.913542    9.548833    9.898525  ...  0.045521  0.102309  0.147325  0.136999  0.096885  0.144778  0.287987  0.038196

Note: the source data are on a 0-360 longitudinal grid and so we need to account for that when creating a lon_dd column on a +-180 scale.
"""
import xarray as xr
import geopandas as gpd
import pyproj
import os
import argparse


def process(data_directory, region):
    subdir = os.path.join(data_directory, region)
    # Load frequency and grand mean netcdf files as DataSets.
    frequency = os.path.join(subdir, 'HRDPS_OPPwest_ps2.5km_frequency.nc')
    grandmean = os.path.join(subdir, 'HRDPS_OPPwest_ps2.5km_grandmean.nc')
    fr = xr.open_dataset(frequency)
    gm = xr.open_dataset(grandmean)

    # Get arrays of max wind speed and direction (binned).
    gm_spd, gm_bin = gm['max_wind_spd'], gm['wind_dir_binned']
    # Convert both DataArrays to DataFrames (max_wind_spd and wind_dir_binned from grand mean).
    df_gm = gm_spd.to_dataframe(name='max_wind_spd')
    df_bin = gm_bin.to_dataframe(name='wind_dir_binned')
    df_gm['wind_dir_binned'] = df_bin['wind_dir_binned']
    # Convert DataArray of frequency of binned directions to DataFrame and rename.
    fr_total = fr['freq_total']
    df_freq = fr_total.to_dataframe()
    df_freq = df_freq.reset_index(level=['bin'])
    df_freq = df_freq.rename(columns={'bin': 'wind_dir_binned'})

    # Merge frequency and grand mean dataframes. 
    merged_df = df_gm.merge(df_freq, on=['nav_lat', 'nav_lon', 'wind_dir_binned'])
    merged_df['lon_dd'] = merged_df['nav_lon']-360
    merged_df = merged_df.rename(columns={'nav_lat': 'lat_dd', 
                                                                'max_wind_spd': 'mx_spd',
                                                                'freq_total': 'freq',
                                                                'wind_dir_binned': 'direction'})
    merged_df = merged_df.drop(['nav_lon'], axis=1)
    merged_df = merged_df[['lat_dd', 'lon_dd', 'direction', 'mx_spd', 'freq']]
    # Save as csv file.
    outcsv = os.path.join(subdir, 'freq_mxspd.csv')
    merged_df.to_csv(outcsv, index=False)

    # Pivot to wide format based on direction.
    df_wide = merged_df.pivot(index=['lat_dd', 'lon_dd'], columns='direction', values=['mx_spd', 'freq'])
    df_wide.columns = [f'{c[0]}_{int(c[1])}' if isinstance(c[1], float) else c[0] for c in df_wide.columns]
    # Reset index to make lat_dd and lon_dd regular columns.
    df_wide = df_wide.reset_index()

    # Create a GeoDataFrame from your pandas DataFrame
    gdf = gpd.GeoDataFrame(df_wide, geometry=gpd.points_from_xy(df_wide.lon_dd, df_wide.lat_dd))
    # Assign the CRS using the EPSG code 4326 and reproject to BC Albers.
    gdf.crs = pyproj.CRS.from_epsg(4326)
    gdf_3005 = gdf.to_crs('EPSG:3005')
    outgpkg = os.path.join(subdir, 'hrdps.gpkg')
    gdf_3005.to_file(outgpkg, driver='GPKG', layer=region)


def main(inargs):
    # Process data.
    process(inargs.path, inargs.region)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('path', help='Path to netcdf data')
    parser.add_argument('region', help='Name of region')
    args = parser.parse_args()
    main(args)
