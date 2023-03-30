import dotenv
import os
import sys
import cdsapi
import settings


def request_data(year):
    """ Given an integer YEAR, make a request to the Climate Data Store - Copernicus.
        Parameters for the API request are pulled from settings. Data is downloaded to OUTPUT_DIR.
    """
    year = str(year)
    cds_client = cdsapi.Client()
    cds_client.retrieve(settings.DATASET_SHORT_NAME,
                        {
                            'variable': settings.CDS_DICT['vars'],
                            'year': year,
                            'month': settings.CDS_DICT['months'],
                            'day': settings.CDS_DICT['days'],
                            'time': settings.CDS_DICT['hours'],
                            'format': settings.CDS_DICT['format'],
                            'product_type': settings.CDS_DICT['product_type'],
                            'area': settings.CDS_DICT['bbox']
                        }, 
                        os.path.join(settings.OUTPUT_DIR, 'era5_' + year + '.nc'))


def setup_dirs():
    """ Create dirs if not exist. """
    for d in [settings.DATA_DIR, settings.OUTPUT_DIR]:
        if not os.path.exists(d):
            os.mkdir(d)