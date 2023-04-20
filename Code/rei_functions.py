import os
import sys
import cdsapi
import settings
import logging
import xarray as xr
import numpy as np
import dask.array as da
import pyproj


logging.basicConfig(format='%(asctime)s - %(message)s', level=logging.INFO)


def request_data(year, out_dir):
    """ Given an integer YEAR, make a request to the Climate Data Store - Copernicus.
        Parameters for the API request are pulled from settings. Data is downloaded to OUTPUT_DIR.
        Run sequential requests: https://github.com/ecmwf/cdsapi/issues/17#issuecomment-1447861102
        Return file path for downloaded .nc file.
    """
    logging.info(f'Requesting data for {year} from Copernicus Climate Data Store.')
    year = str(year)
    nc_name = settings.CDS_REQUEST['vars_short'] + '_hourly_era5_' + year + '.nc'
    output_file = os.path.join(out_dir, nc_name)
    cds_client = cdsapi.Client()
    cds_client.retrieve(settings.CDS_REQUEST['short_name'],
                        {
                            'variable': settings.CDS_REQUEST['vars'],
                            'year': year,
                            'month': settings.CDS_REQUEST['months'],
                            'day': settings.CDS_REQUEST['days'],
                            'time': settings.CDS_REQUEST['hours'],
                            'format': settings.CDS_REQUEST['format'],
                            'product_type': settings.CDS_REQUEST['product_type'],
                            'area': settings.CDS_REQUEST['bbox']
    }, output_file)
    if os.path.isfile(output_file):
        logging.info(f'Download for {year} complete.')
        return output_file
    else:
        logging.warning(f'Download for {year} failed.')


def setup_dirs(path_list):
    """ Given a list of filepaths, create output directories as needed. """
    logging.info('Setting up directories.')
    for d in path_list:
        if d:
            if not os.path.exists(d):
                logging.info(f'Creating directory: {d}')
                os.mkdir(d)
            else:
                logging.info(f'{d} already exists.')


def get_filepaths(directory, extension):
    """ Return list of file paths in DIRECTORY with matching EXTENSION. """
    logging.info(f'Getting list of file paths in {directory} matching extension: {extension}')
    return [os.path.join(directory, file) for file in os.listdir(directory) if file.endswith(extension)]


def calc_direction(u, v):
    """ Calculate wind direction based on u and v wind components. 
        https://confluence.ecmwf.int/pages/viewpage.action?pageId=133262398
    """
    return 180+(180/np.pi)*np.arctan2(u, v)


def add_variables(xr_dataset, direction_func):
    """ Given an xarray dataset, add wind_speed and direction variables
        derived from u v wind components
    """
    logging.info(f'Deriving wind speed and adding as variable to dataset...')
    speed = xr.apply_ufunc(np.sqrt,
                              xr_dataset.variables['u10']**2 +
                              xr_dataset.variables['v10']**2,
                              dask='parallelized')
    xr_dataset = xr_dataset.assign(wind_speed=speed)
    logging.info(f'Deriving wind direction and adding as variable to dataset...')
    direction = xr.apply_ufunc(direction_func,
                            xr_dataset.variables['u10'],
                            xr_dataset.variables['v10'],
                            dask='parallelized')
    xr_dataset = xr_dataset.assign(wind_dir=direction)                            
    return xr_dataset


def quantile(xr_dataset):
    return xr_dataset[xr_dataset.wind_speed < np.percentile(xr_dataset.wind_speed, 95)]


def percentile(xr_dataset):
    q = np.percentile(xr_dataset['wind_speed'], 95)
    mask = xr_dataset['wind_speed'] <= q
    # Array filled with NAs using mask.
    filtered_data = xr_dataset.where(mask)
    filtered_data2 = filtered_data.dropna('time')


def add_binned_direction(xr_dataset):
    """ Given an xarray dataset, add the frequency that wind blew from each direction. 
         Bins define the direction cutoff points. The labels are the binned direction labels for
         each category. When creating binned_wind_labelled, offset by -1 because values in
         binned_wind are 1-9 inclusive and indices in labels are zero-indexed.
    """
    bins = np.array([0, 22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5, 361])
    labels = np.array([360, 45, 90, 135, 180, 225, 270, 315, 360])
    binned_wind = xr.apply_ufunc(da.digitize, xr_dataset.variables['wind_dir'], bins, dask='allowed', kwargs={'right': -1})
    binned_wind_labelled = da.from_array(da.take(labels, binned_wind-1))
    binned_wind.values = binned_wind_labelled
    xr_dataset = xr_dataset.assign(direction=binned_wind)
    return xr_dataset


def convert_coordinates(x, y, in_epsg, out_epsg):
    """
    Converts coordinates from one projection to another using EPSG codes.

    Args:
        x (float): The x-coordinate of the point to be converted.
        y (float): The y-coordinate of the point to be converted.
        in_epsg (int): The EPSG code of the input projection.
        out_epsg (int): The EPSG code of the output projection.

    Returns:
        A tuple containing the converted x and y coordinates.
    >>> convert_coordinates(1021928.428003, 398050.489959, 3005, 4326)
    (-125.703253, 48.598047)
    >>> convert_coordinates(1096050.279809, 471118.188193, 3005, 4326)   
    (-124.68193, 49.248361)
    """
    in_proj = pyproj.CRS.from_epsg(in_epsg)
    out_proj = pyproj.CRS.from_epsg(out_epsg)
    transformer = pyproj.Transformer.from_crs(in_proj, out_proj, always_xy=True)
    lon, lat = transformer.transform(x, y)
    return round(lon, 6), round(lat, 6)


def get_bounding_box_str(sw_coords, ne_coords):
    """
    Creates a string representing a bounding box given southwest and northeast coordinates.

    Arguments:
        - sw_coords (tuple): A tuple of x, y representing southwest coordinates.
        - ne_coords (tuple): A tuple of x, y representing northeast coordinates.

    Returns:
        A string in the format 'lon1,lon2,lat1,lat2', where lon1 is the westernmost longitude,
        lon2 is the easternmost longitude, lat1 is the southernmost latitude, and lat2 is the
        northernmost latitude.

    Note:
        The function will account for the y values being on a +-180 scale and will convert them
        into a 0 to 360 scale.
    >>> get_bounding_box_str((-125.703253, 48.598047), (-124.68193, 49.248361))
    '234.296747,235.31807,48.598047,49.248361'
    """
    lon1 = sw_coords[0]
    lon2 = ne_coords[0]
    lat1 = sw_coords[1]
    lat2 = ne_coords[1]
    if lon1 < 0:
        lon1 += 360
    if lon2 < 0:
        lon2 += 360
    if lon1 > lon2:
        lon1, lon2 = lon2, lon1
        lat1, lat2 = lat2, lat1
    return f"{round(lon1, 6)},{round(lon2, 6)},{round(lat1, 6)},{round(lat2, 6)}"


def load_data(file_path_list):
    """ Load any number of NetCDF files from FILE_PATH_LIST into a single Dataset. """
    try:
        logging.info(f'Loading input NetCDF files: {file_path_list} into Dataset object.')
        return xr.open_mfdataset(file_path_list, decode_times=False)
    except ValueError as e:
        logging.error(f'Error loading all netcdf files: {e}')


def process(inargs):
    """ Call functions to perform various operations. """
    setup_dirs([settings.DATA_DIR, inargs.source])
    if inargs.download:
        netcdf_paths = [request_data(year, inargs.source) for year in settings.CDS_REQUEST['years']]
    else:
        netcdf_paths = get_filepaths(inargs.source, '.nc')
    # ds = load_data(netcdf_paths)
    # ds2 = add_variables(ds, calc_direction)
    # ds3 = add_binned_direction(ds2)
