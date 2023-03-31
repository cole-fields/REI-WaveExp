import os
import sys
import cdsapi
import settings
import logging
import xarray as xr
import numpy as np
import dask.array as da


logging.basicConfig(format='%(asctime)s - %(message)s', level=logging.INFO)


def request_data(year):
    """ Given an integer YEAR, make a request to the Climate Data Store - Copernicus.
        Parameters for the API request are pulled from settings. Data is downloaded to OUTPUT_DIR.
        Run sequential requests: https://github.com/ecmwf/cdsapi/issues/17#issuecomment-1447861102
        Return file path for downloaded .nc file.
    """
    logging.info(f'Requesting data for {year} from Copernicus Climate Data Store.')
    year = str(year)
    nc_name = settings.CDS_REQUEST['vars_short'] + '_hourly_era5_' + year + '.nc'
    output_file = os.path.join(settings.OUTPUT_DIR, nc_name)
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


def wrap_digitize(data, bins):
    return np.digitize(data, bins)


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


def load_data(file_path_list):
    """ Load any number of NetCDF files from FILE_PATH_LIST into a single Dataset. """
    logging.info(f'Loading input NetCDF files: {file_path_list} into Dataset object.')
    return xr.open_mfdataset(file_path_list)


def process(inargs):
    """ Call functions to perform various operations. """
    setup_dirs([settings.DATA_DIR, settings.OUTPUT_DIR])
    if inargs.download:
        netcdf_paths = [request_data(year) for year in settings.CDS_REQUEST['years']]
    else:
        netcdf_paths = get_filepaths(settings.OUTPUT_DIR, '.nc')
