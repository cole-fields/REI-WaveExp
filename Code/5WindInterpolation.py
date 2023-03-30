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
arcpy.env.overwriteOutput = True
arcpy.CheckOutExtension("Spatial")

# Set up environmental workspace
workingDir = r"C:\Temp\era"
arcpy.env.workspace = workingDir

# Set up path to the output geodatabase
folderName = "spline_era5"
splinesavepath = os.path.join(workingDir, folderName)

# Set the output folder
if not os.path.isdir(splinesavepath):
    # A folder hasn't been created yet
    arcpy.AddMessage("Creating output folder in " + workingDir)
    os.mkdir(splinesavepath)
    # arcpy.CreateFileGDB_management(workingDir, folderName)

arcpy.AddMessage("Output folder: " + splinesavepath)

# Set local variables
inPntFeat = "Copernicus_era5_summary_wide.shp" # input point shapefile
fieldList = arcpy.ListFields(inPntFeat, "*", "Double") # list of fields to interpolate
cellSize = 20.0 # value of output raster cell size (numeric) or existing raster template (string)
splineType = "REGULARIZED" # spline method
weight = 0.1 # parameter affecting rigidness of interpolated surface

print("Listing field names, types, and lengths")

for field in fieldList:
    try:
        print("{0} is a type of {1} with a length of {2}".format(field.name, field.type, field.length))
        outsplinesave = os.path.join(splinesavepath, field.name + "_" + "spline" + '.tif')
        zfield = field.name
        # Run spline interpolation
        print("interpolating wind data")
        outSpline = Spline(os.path.join(workingDir, inPntFeat), zfield, cellSize, splineType, weight)
        outSpline.save(outsplinesave)
    except:
        # If an error occured print the message to the screen
        print(arcpy.GetMessages())

print("Script complete")
