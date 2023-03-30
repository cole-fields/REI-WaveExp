""" This file contains global variables and dictionaries used
     throughout the main program.
"""
import os
from dotenv import load_dotenv

load_dotenv(os.path.join('..', '.env'))

# Directories.
PWD = os.getcwd()
DATA_DIR = os.path.join(os.path.dirname(PWD), 'Data')
OUTPUT_DIR = os.path.join(DATA_DIR, 'era5_nc')

# CDS Authorization.
CDS_UID = os.getenv('CDS_UID')
CDS_KEY = os.getenv('CDS_KEY')

# Global vars and Dictionaries.
SPATIAL_REF_SYS = 3005
DATASET_SHORT_NAME = 'reanalysis-era5-single-levels'
CDS_DICT = {'years': list(range(2019, 2021)),
            'months': [f'{n:02}' for n in range(0, 13)],
            'days': [f'{n:02}' for n in range(0, 32)],
            'hours': [f'{n:02}:00' for n in range(0, 24)],
            'bbox': '55.8/-133.4/48.2/-122.5',
            'format': 'netcdf',
            'product_type': 'reanalysis',
            'vars': ['10m_v_component_of_wind', '10m_u_component_of_wind']}
