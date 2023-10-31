"""
The purpose of this Python script is to apply an exponential decay function to a relative exposure index layer based on a depth raster. 
The script takes input arguments including a constant 'K' for the exponential decay function, the file paths to the input depth and 
exposure rasters, and the output directory for the depth-attenuated layer.

The script performs the following steps:

Loads the depth raster data and retrieves the nodata value.
Masks out the nodata values in the depth raster.
Calculates the attenuation factor based on the masked depth values and the constant 'K'.
Loads the exposure raster data and retrieves the nodata value, as well as the profile information.
Masks out the nodata values in the exposure raster.
Applies the attenuation factor to the exposure data.
Saves the depth-attenuated exposure raster in the specified output directory.

Usage: python attenuate.py constant depth_raster.tif exposure_raster.tif output_directory
Example: python attenuate.py 0.05 D:\projects\bathymetry\data\20m-dfo\bathymetry-20m\west_coast_vancouver_island.tif D:\projects\REI-WaveExp\data\wcvi\rei_wcvi.tif D:\projects\REI-WaveExp\data\wcvi\

"""
import numpy as np
import rasterio
import argparse
import os
from scipy import constants
from datetime import datetime


now = datetime.now().strftime("%Y-%m-%d-%H%M")

# standard acceleration of gravity
g = constants.g


def load_layer(file_path, rei=False):
    """ Return depth data and nodata from source file. """
    with rasterio.open(file_path) as src:
        data = src.read(1)
        nodata = src.nodata
        if rei:
            profile = src.profile
            return data, nodata, profile
        return data, nodata


def mask_nodata(data, nodata):
    """ Return masked NumPy array (NoData values masked out). """
    return np.ma.masked_equal(data, nodata)


def get_attenuation_factor(k_values, variable_array):
    """ Return attenuation factor based on masked variable values (depth or wave height) and k array of values. """
    return np.exp(-k_values * variable_array)


def get_k_constant(rei_values):
    """ Return constant k using acceleration of gravity constant and relative exposure index array. """
    return (22**2)*((1/rei_values)**(2/3))*g**(1/3)


def attenuate(data_array, depth_attenuation_factors, nodata):
    """ Return NumPy array that has the attenuation factor applied to its values and fill with NoData values. """
    attenuated =  data_array * depth_attenuation_factors
    return attenuated.filled(nodata)


def process(raster_dir, region, version, exposure, outdir):
    """ Call functions to process data for depth attenuation. """
    # Mask out NoData values in depth and exposure rasters
    # depth, exposure, outdir = r"D:\projects\sdm-layers\data\_20m\HG\envlayers-20m-hg\bathymetry.tif", r"D:\projects\REI-WaveExp\data\hg\rei_20m_hg.tif", r"D:\projects\REI-WaveExp\data\hg"
    # raster_dir, region, version, exposure, outdir = r"D:\projects\sdm-layers\data\_20m\HG\envlayers-20m-hg", "hg", "4", r"D:\projects\REI-WaveExp\data\hg\v1.1\rei_20m_hg.tif", r"D:\projects\REI-WaveExp\data\hg\v1.4"
    depth = os.path.join(raster_dir, 'bathymetry.tif')
    depth_data, depth_nodata = load_layer(depth)
    exposure_data, exposure_nodata, exposure_profile = load_layer(exposure, rei=True)
    depth_masked = mask_nodata(depth_data, depth_nodata)
    land_mask = (depth_masked <= 1.0)
    depth_masked[land_mask] = 1.0
    exposure_masked = mask_nodata(exposure_data, exposure_nodata)
    # Apply the function element-wise to the exposure_masked array
    k_exposure_constants = get_k_constant(exposure_masked)
    # Calculate attenuation factor
    depth_attenuation_factors = get_attenuation_factor(k_exposure_constants, depth_masked)
    # Apply the depth attenuation to the exposure data
    attenuated_exposure = attenuate(exposure_masked, depth_attenuation_factors, exposure_nodata)
    # Save the depth-attenuated exposure raster
    exposure_profile.update(count=1)
    out_file = os.path.join(outdir, f'rei_{region}_{version}.tif')
    with rasterio.open(out_file, 'w', **exposure_profile) as dst:
        dst.write(attenuated_exposure, 1)


def main():
    """ Add arguments and process data. """
    # python attenuate.py D:\projects\sdm-layers\data\_20m\HG\envlayers-20m-hg hg 5 D:\projects\REI-WaveExp\data\hg\v1.5\rei_20m_hg_focal.tif D:\projects\REI-WaveExp\data\hg\v1.5
    # python attenuate.py D:\projects\sdm-layers\data\_20m\QCS\envlayers-20m-qcs qcs 5 D:\projects\REI-WaveExp\data\qcs\v1.5\rei_20m_qcs_focal.tif D:\projects\REI-WaveExp\data\qcs\v1.5
    # python attenuate.py D:\projects\sdm-layers\data\_20m\WCVI\envlayers-20m-wcvi wcvi 5 D:\projects\REI-WaveExp\data\wcvi\v1.5\rei_20m_wcvi_focal.tif D:\projects\REI-WaveExp\data\wcvi\v1.5
    # python attenuate.py D:\projects\sdm-layers\data\_20m\SalishSea\envlayers-20m-shelfsalishsea sog 5 D:\projects\REI-WaveExp\data\sog\v1.5\rei_20m_sog_focal.tif D:\projects\REI-WaveExp\data\sog\v1.5
    # python attenuate.py D:\projects\sdm-layers\data\_20m\NCC\envlayers-20m-ncc ncc 5 D:\projects\REI-WaveExp\data\ncc\v1.5\rei_20m_ncc_focal.tif D:\projects\REI-WaveExp\data\ncc\v1.5
    parser = argparse.ArgumentParser(description='Apply exponential decay function to relative exposure index layer based in depth.')
    parser.add_argument('raster_dir', type=str, help='Absolute filepath to data directory with depth and wave raster (named bathymetry.tif and wave_height.tif).')
    parser.add_argument('region', type=str, choices=['sog', 'qcs', 'ncc', 'wcvi', 'hg'], help='Choose a region: sog, qcs, ncc, wcvi, hg')
    parser.add_argument('version', type=int, choices=[1, 2, 3, 4, 5], help='Choose a version: 1, 2, 3, 4, 5')
    parser.add_argument('exposure', type=str, help='Absolute filepath to input exposure raster.')
    parser.add_argument('outdir', type=str, help='Output directory for attenuated layer.')
    args = parser.parse_args()
    process(args.raster_dir, args.region, args.version, args.exposure, args.outdir)


if __name__ == '__main__':
    main()
