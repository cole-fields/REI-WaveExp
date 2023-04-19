import os
import sys
import cdsapi
import settings
import logging
import xarray as xr
import numpy as np
import dask.array as da


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
    logging.info('Setting up output directories.')
    for d in path_list:
        if not os.path.exists(d):
            logging.info(f'Creating directory: {d}')
            os.mkdir(d)
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


def get_bounding_box_str(se_coords, nw_coords):
    """
    Creates a string representing a bounding box given southeast and northwest coordinates.

    Arguments:
        - se_coords (tuple): A tuple of x, y representing southeast coordinates.
        - nw_coords (tuple): A tuple of x, y representing northwest coordinates.

    Returns:
        A string in the format 'lon1,lon2,lat1,lat2', where lon1 is the westernmost longitude,
        lon2 is the easternmost longitude, lat1 is the southernmost latitude, and lat2 is the
        northernmost latitude.

    Note:
        The function will account for the y values being on a +-180 scale and will convert them
        into a 0 to 360 scale.
    """
    lon1 = se_coords[0]
    lon2 = nw_coords[0]
    lat1 = se_coords[1]
    lat2 = nw_coords[1]
    
    if lon1 < 0:
        lon1 += 360
    if lon2 < 0:
        lon2 += 360
        
    if lon1 > lon2:
        lon1, lon2 = lon2, lon1
        lat1, lat2 = lat2, lat1
        
    return f"{lon1},{lon2},{lat1},{lat2}"


def load_data(file_path_list):
    """ Load any number of NetCDF files from FILE_PATH_LIST into a single Dataset. """
    logging.info(f'Loading input NetCDF files: {file_path_list} into Dataset object.')
    return xr.open_mfdataset(file_path_list)


def process(inargs):
    """ Call functions to perform various operations. """
    wind_dir = os.path.join(settings.DATA_DIR, inargs.wind)
    setup_dirs([settings.DATA_DIR, wind_dir])
    if inargs.download:
        netcdf_paths = [request_data(year, wind_dir) for year in settings.CDS_REQUEST['years']]
    else:
        netcdf_paths = get_filepaths(wind_dir, '.nc')
    ds = load_data(netcdf_paths)
    ds2 = add_variables(ds, calc_direction)
    ds3 = add_binned_direction(ds2)
