""" 
"""

import rei_functions
import argparse


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--download', action='store_true',
                        help='Download data from Copernicus Climate Data Store.')
    args = parser.parse_args()                        
    rei_functions.process(args)


if __name__ == '__main__':
    main()
