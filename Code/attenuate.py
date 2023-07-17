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


def get_attenuation_factor(k, depth_masked):
    """ Return attenuation factor based on masked depth values and constant K. """
    return np.exp(-k * depth_masked)


def attenuate(data_array, attenuation_factor, nodata):
    """ Return NumPy array that has the attenuation factor applied to its values and fill with NoData values. """
    attenuated =  data_array * attenuation_factor
    return attenuated.filled(nodata)


def process(constant, depth, exposure, outdir):
    """ Call functions to process data for depth attenuation. """
    # Mask out NoData values in depth and exposure rasters
    depth_data, depth_nodata = load_layer(depth)
    exposure_data, exposure_nodata, exposure_profile = load_layer(exposure, rei=True)
    depth_masked = mask_nodata(depth_data, depth_nodata)
    exposure_masked = mask_nodata(exposure_data, exposure_nodata)
    # Calculate attenuation factor
    attenuation_factor = get_attenuation_factor(constant, depth_masked)
    # Apply the depth attenuation to the exposure data
    depth_attenuated_exposure = attenuate(exposure_masked, attenuation_factor, exposure_nodata)
    # Save the depth-attenuated exposure raster
    exposure_profile.update(count=1)
    out_file = os.path.join(outdir, f'depth_attenuated_exposure_{constant}.tif')
    with rasterio.open(out_file, 'w', **exposure_profile) as dst:
        dst.write(depth_attenuated_exposure, 1)


def main():
    """ Add arguments and process data. """
    parser = argparse.ArgumentParser(description='Apply exponential decay function to relative exposure index layer based in depth.')
    parser.add_argument('constant', type=float, help='Constant K used in the exponential decay function.')
    parser.add_argument('depth', type=str, help='Absolute filepath to input depth raster.')
    parser.add_argument('exposure', type=str, help='Absolute filepath to input exposure raster.')
    parser.add_argument('outdir', type=str, help='Output directory for depth-attenuated layer.')
    args = parser.parse_args()
    process(args.constant, args.depth, args.exposure, args.outdir)


if __name__ == '__main__':
    main()
