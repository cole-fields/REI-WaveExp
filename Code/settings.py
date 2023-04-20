""" This file contains global variables and dictionaries used
     throughout the main program.
"""
import os

# Argument example.
ARG_EX = 'usage: rei.py [-h] [-w {era5,hrdps}] [-d] [-s SOURCE]'

# Directories.
PWD = os.getcwd()
DATA_DIR = os.path.join(os.path.dirname(PWD), 'data')

# Global vars and Dictionaries.
SPATIAL_REF_SYS = 3005
CDS_REQUEST = {'years': list(range(2019, 2021)),
            'months': [f'{n:02}' for n in range(0, 13)],
            'days': [f'{n:02}' for n in range(0, 32)],
            'hours': [f'{n:02}:00' for n in range(0, 24)],
            # Bounding box for region of interest (N, W, S, E)
            'bbox': '55.8/-133.4/48.2/-122.5',
            'format': 'netcdf',
            'product_type': 'reanalysis',
            'vars': ['10m_v_component_of_wind', '10m_u_component_of_wind'],
            'vars_shorthand': 'u10_v10',
            'short_name': 'reanalysis-era5-single-levels'}
