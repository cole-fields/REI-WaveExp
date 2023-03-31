import os
import sys
import cdsapi
import settings
import logging
import xarray as xr


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
    output_file  = os.path.join(settings.OUTPUT_DIR, nc_name)
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


def get_nc(directory, extension):
    """ Return list of files in DIRECTORY with matching EXTENSION. """
    return [os.path.join(directory, file) for file in os.listdir(directory) if file.endswith(extension)]


def process(inargs):
    """ Call functions to perform various operations. """
    setup_dirs([settings.DATA_DIR, settings.OUTPUT_DIR])
    if inargs.download:
        netcdf_paths = [request_data(year) for year in settings.CDS_REQUEST['years']]
    else:
        netcdf_paths = get_nc(settings.OUTPUT_DIR, '.nc')

