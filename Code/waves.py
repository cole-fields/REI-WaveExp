"""
This script reads in monthly significant wave height data from text files. The source data is for the entire domain (WCVI).
Use the --coords flag followed by a string of lat longs such as "48.517618 49.33337 -125.828219 -124.561191" to subset by location.
Each file has one value per location (mean HSIG). From the monthly mean, calculate the overall mean. Save the overall mean as a 
spatial file -- change projection to BC Albers (EPSG 3005).

Barkley LL: (-125.828219, 48.517618)
Barkley UR: (-124.561191, 49.33337)

python waves.py D:\projects\REI-WaveExp\data\wave\DFO_data\WholeDomainStats\HSIG hsig txt mean --coords "48.517618 49.33337 -125.828219 -124.561191"
"""
import os
import argparse
import sys
import pandas as pd
import geopandas as gpd


def search_files(directory, extension, search_string):
    """ Return list of files within DIRECTORY that contain SEARCH_STRING and are of type EXTENSION."""
    found_files = []
    if not os.path.exists(directory):
        print('Directory does not exist.')
        return found_files
    for file_name in os.listdir(directory):
        if file_name.endswith(extension) and search_string in file_name:
            found_files.append(file_name)
    return found_files


def load_data(directory, file_names, var):
    """ Given a DIRECTORY and a list of FILE_NAMES, load each file as a DataFrame. """
    dfs = []
    for file_name in file_names:
        filepath = os.path.join(directory, file_name)
        df = pd.read_csv(filepath, delim_whitespace=True, header=None, names=["longitude", "latitude", var])
        dfs.append(df)
    return dfs


def subset_data(dataframe, lat_min, lat_max, lon_min, lon_max):
    """ Given a DATAFRAME and min/max coordinates, subset and return the data.
    Barkley LL: (-125.828219, 48.517618)
    Barkley UR: (-124.561191, 49.33337)
    df_new = subset_data(df, 48.517618, 49.33337, -125.828219, -124.561191)
    """
    subset = dataframe[(dataframe['latitude'] >= lat_min) & (dataframe['latitude'] <= lat_max) & 
                       (dataframe['longitude'] >= lon_min) & (dataframe['longitude'] <= lon_max)]
    return subset


def create_mean_dataframe(dataframes, var):
    """ Return dataframe with coordinate and mean value of VAR. """
    print(f'Creating mean dataframe from variable: {var}')
    merged_df = pd.concat(dataframes, axis=1)
    mean_var = merged_df[var].mean(axis=1)
    longitude = dataframes[0]['longitude']
    latitude = dataframes[0]['latitude']
    return pd.DataFrame({'longitude': longitude, 'latitude': latitude, f'mean_{var}': mean_var})


def save_geo(dataframe, directory):
    """ Create a GeoDataFrame from the mean DataFrame, reproject data to B.C. Albers and write to disk as GeoPackage layer. """
    var_name = dataframe.columns[-1]
    filepath = os.path.join(directory, var_name.split('_')[-1] + '.gpkg')
    if os.path.exists(filepath):
        print(f'{filepath} already exists. Exiting program.')
        sys.exit()
    gdf = gpd.GeoDataFrame(dataframe, geometry=gpd.points_from_xy(dataframe.longitude, dataframe.latitude), crs='EPSG:4326')
    print('Converting GeoDataFrame to EPSG Code 3005')
    gdf = gdf.to_crs(3005)
    print(f'Saving layer {var_name} to {filepath}')
    gdf.to_file(filepath, layer=var_name, driver='GPKG')


def check_shape(dataframes):
    """ The shape of each dataframe should be the same. Exit the program if that's not the case. """
    shape_reference = dataframes[0].shape
    shapes = [df.shape == shape_reference for df in dataframes]
    if not all(shapes):
        print('Dataframes have different shapes. Exiting program.')
        sys.exit()


def process(data_dir, variable, ext, search, coords_string):
    """ Process data. """
    file_list = search_files(data_dir, ext, search)
    print(f'{len(file_list)} files found in {data_dir} with string "{search}" and extension "{ext}".')
    if not file_list:
        print('Exiting program.')
        sys.exit()
    dfs = load_data(data_dir, file_list, variable)
    if coords_string:
        print(f'Coordinates provided. Subsetting data based on: {coords_string}.')
        coords = [float(coord) for coord in coords_string.split()]
        dfs = [subset_data(df, coords[0], coords[1], coords[2], coords[3]) for df in dfs]
    else:
        print('No coordinates provided. Skipping subset.')
    check_shape(dfs)
    mean_df = create_mean_dataframe(dfs, variable)
    save_geo(mean_df, data_dir)
    

def main():
    """ Add arguments and process data. """
    parser = argparse.ArgumentParser(description='Search files within a directory.')
    parser.add_argument('directory', type=str, help='Directory path')
    parser.add_argument('variable', type=str, help='Name of variable in data')
    parser.add_argument('extension', type=str, help='File extension')
    parser.add_argument('search_string', type=str, help='String to search in file names')
    parser.add_argument('--coords', type=str, 
                        help='String of coordinates (space-delimited) in the order lat_min lat_max lon_min lon_max such as "48.517618 49.33337 -125.828219 -124.561191"')
    args = parser.parse_args()
    process(args.directory, args.variable, args.extension, args.search_string, args.coords)


if __name__ == '__main__':
    main()
