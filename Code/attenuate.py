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


def get_attenuation_factor(k_values, depth_masked):
    """ Return attenuation factor based on masked depth values and k array of values. """
    return np.exp(k_values * depth_masked)


def get_k_constant(rei_values):
    """ Return constant k using acceleration of gravity constant and relative exposure index array. """
    return (22**2)*((1/rei_values)**(2/3))*g**(1/3)


def attenuate(data_array, attenuation_factor, nodata):
    """ Return NumPy array that has the attenuation factor applied to its values and fill with NoData values. """
    attenuated =  data_array * attenuation_factor
    return attenuated.filled(nodata)


def process(depth, exposure, outdir):
    """ Call functions to process data for depth attenuation. """
    # Mask out NoData values in depth and exposure rasters
    # depth, exposure, outdir = r"D:\projects\sdm-layers\data\_20m\HG\envlayers-20m-hg\bathymetry.tif", r"D:\projects\REI-WaveExp\data\hg\rei_20m_hg.tif", r"D:\projects\REI-WaveExp\data\hg"
    depth_data, depth_nodata = load_layer(depth)
    exposure_data, exposure_nodata, exposure_profile = load_layer(exposure, rei=True)
    depth_masked = mask_nodata(depth_data, depth_nodata)
    exposure_masked = mask_nodata(exposure_data, exposure_nodata)
    # Apply the function element-wise to the exposure_masked array
    k_constants = get_k_constant(exposure_masked)
    # Calculate attenuation factor
    attenuation_factor = get_attenuation_factor(k_constants, depth_masked)
    # Apply the depth attenuation to the exposure data
    depth_attenuated_exposure = attenuate(exposure_masked, attenuation_factor, exposure_nodata)
    # Save the depth-attenuated exposure raster
    exposure_profile.update(count=1)
    out_file = os.path.join(outdir, f'depth_attenuated_exposure.tif')
    with rasterio.open(out_file, 'w', **exposure_profile) as dst:
        dst.write(depth_attenuated_exposure, 1)


def main():
    """ Add arguments and process data. """
    # python attenuate.py D:\projects\sdm-layers\data\_20m\HG\envlayers-20m-hg\bathymetry.tif D:\projects\REI-WaveExp\data\hg\rei_20m_hg.tif D:\projects\REI-WaveExp\data\hg
    # python attenuate.py D:\projects\sdm-layers\data\_20m\WCVI\envlayers-20m-wcvi\bathymetry.tif D:\projects\REI-WaveExp\data\wcvi\rei_20m_wcvi.tif D:\projects\REI-WaveExp\data\wcvi
    parser = argparse.ArgumentParser(description='Apply exponential decay function to relative exposure index layer based in depth.')
    parser.add_argument('depth', type=str, help='Absolute filepath to input depth raster.')
    parser.add_argument('exposure', type=str, help='Absolute filepath to input exposure raster.')
    parser.add_argument('outdir', type=str, help='Output directory for depth-attenuated layer.')
    args = parser.parse_args()
    process(args.depth, args.exposure, args.outdir)


if __name__ == '__main__':
    main()
