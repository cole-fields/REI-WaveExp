""" 
"""

import rei_functions
import argparse
import settings
import os

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-w', '--wind', choices=['era5', 'hrdps'],
                        help='Modelled wind data source selection.')
    parser.add_argument('-d', '--download', action='store_true',
                        help='Download data from Copernicus Climate Data Store.')
    parser.add_argument('-s', '--source', type=str, 
                    help=f'Source wind data directory. If not provided, one will be created in \
                        ../data/<wind> if it does not exist.')
    args = parser.parse_args()
    if not args.wind:
        raise ValueError(f'Must provide a selection for -w (--wind) argument.\n \
                         {settings.ARG_EX}')
    if args.wind == 'hrdps' and args.download:
        raise ValueError(f'-d flag can only be provided if -w (--wind) argument is era5.\n \
                         {settings.ARG_EX}')
    if args.download and args.source:
        raise ValueError(f'-d and -s flags may not both be provided, only one or the other.\n \
                            {settings.ARG_EX}')
    rei_functions.process(args)

if __name__ == '__main__':
    main()
