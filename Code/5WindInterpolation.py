# Name: WindInterpolation.py
# Description: Loops through fields of a point shapefile and interpolates the
#	the values of that field onto a Grid raster using a minimum curvature 
#	regularized spline technique with a weight of 0.1 for the 3rd derivatives
# Requirements: Spatial Analyst Extension

# Import system modules
import sys
import os
import arcpy
from arcpy.sa import *
import argparse
arcpy.CheckOutExtension('Spatial')
arcpy.env.overwriteOutput = True
arcpy.env.nodata = -9999


def process(inargs):
    # Set up environmental workspace
    workingDir = inargs.working_dir
    arcpy.env.workspace = workingDir
    # Set up path to the output geodatabase
    folderName = 'spline_hrdps'
    splinesavepath = os.path.join(workingDir, folderName)
    # Set the output folder
    if not os.path.isdir(splinesavepath):
        # A folder hasn't been created yet
        arcpy.AddMessage('Creating output folder in ' + workingDir)
        os.mkdir(splinesavepath)
        # arcpy.CreateFileGDB_management(workingDir, folderName)
    arcpy.AddMessage('Output folder: ' + splinesavepath)
    # Set local variables
    geopackage = 'hrdps.gpkg' # input point shapefile
    layer_name = inargs.region
    lyr_ref = f'{geopackage}/{layer_name}'
    # Use ListFields to get a list of all the fields in the layer
    fields = arcpy.ListFields(lyr_ref)
    interp_fields = [f for f in fields if 'mx_spd' in f.name or 'freq' in f.name]
    # Loop through the fields and print their names
    for field in interp_fields:
        print(field.name)
    cellSize = 20.0 # value of output raster cell size (numeric) or existing raster template (string)
    splineType = 'REGULARIZED' # spline method
    weight = 0.1 # parameter affecting rigidness of interpolated surface
    print('Listing field names, types, and lengths')
    for field in interp_fields:
        try:
            print('{0} is a type of {1} with a length of {2}'.format(field.name, field.type, field.length))
            outsplinesave = os.path.join(splinesavepath, field.name + '_' + 'spline' + '.tif')
            zfield = field.name
            # Run spline interpolation
            print('interpolating wind data')
            outSpline = Spline(os.path.join(workingDir, lyr_ref), zfield, cellSize, splineType, weight)
            outSpline.save(outsplinesave)
        except:
            # If an error occured print the message to the screen
            print(arcpy.GetMessages())
    print('Script complete')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('working_dir', 
                        type=str, 
                        help='Source data directory.')
    parser.add_argument('region', 
                    type=str, 
                    help='Region name.')
    args = parser.parse_args()
    process(args)

if __name__ == '__main__':
    main()
