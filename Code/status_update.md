#  Project Status Update: Relative Exposure Index (REI) in Pacific Canada

**Project Repository:** https://github.com/cole-fields/REI-WaveExp/tree/hrdps

**Date:** 2023-10-24

~~**Date:** 2023-10-04~~

~~**Date:** 2023-09-13~~

![Barkley Sound Relative Exposure Index](reference/barkley.png)

## Table of Contents
- [1. Introduction](#1-introduction)
- [2. Project Overview](#2-project-overview)
- [3. Objectives](#3-objectives)
- [4. Scope](#4-scope)
- [5. Methodology](#5-methodology)
- [6. Data Sources](#6-data-sources)
- [7. Tools and Technologies](#7-tools-and-technologies)
- [8. Progress Update](#8-progress-update)
- [9. Challenges](#9-challenges)
- [10. Next Steps](#10-next-steps)
- [11. Conclusion](#11-conclusion)

## 1. Introduction

This Project Status Update document provides a snapshot of the progress made in the spatial analysis project for the creation of the Relative Exposure Index (REI) layers in Pacific Canada. It includes key project details and highlights the current status of various project components.

## 2. Project Overview

The project's primary goal is to generate five regional spatial layers that provide a Relative Exposure Index (REI) to wind-driven waves along the coastal zone of Pacific Canada. The focus is on generating depth-attenuated Relative Exposure Index layers.

#### Updates:
* 2023-10-24: V1.4 of the data product was created using depth attenuation and including interpolated wave height data in the final calculation of REI values. A focal mean (circular 3 cell radius) was applied to the output of each region's REI layer. Next, they were normalized 0-1 between regions.
* 2023-10-04: V1.1 of the data product was created using depth attenuation and including slope in the final calculation of REI values. A focal mean (circular 5 cell radius) was applied to the output of each region's REI layer. Next, they were normalized 0-1 between regions.

## 3. Objectives

The project's main objectives remain unchanged:

- Translate existing R code: https://github.com/obrienjm25/REI-WaveExp into CDO operations and python scripts.
- Generate and deliver Relative Exposure Index geotiff raster files for five predefined regions for species distribution modelling.
- Implement depth attenuation to account for the diminishing effect of wind-wave energy with greater depth.
- Normalize output rasters on 0-1 scale and align with other predictor variables.
- Package data and metadata and publish on GIS Hub.
- Document code on repository.

#### Updates:
* 2023-10-24: V1.4 changes include taking the log of the REI array prior to attenuation by depth. Within the attenuation function, the product of the log of the REI values and the depth attenuation factors are multiplied by interpolated wave height (m) values. By taking the log of the REI values, the orders of magnitude of difference between the regions is reduced, making the values more comparable.

```
def get_attenuation_factor(k_values, variable_array):
    """ Return attenuation factor based on masked variable values (depth or wave height) and k array of values. """
    return np.exp(-k_values * variable_array)


def get_k_constant(rei_values):
    """ Return constant k using acceleration of gravity constant and relative exposure index array. """
    return (22**2)*((1/rei_values)**(2/3))*g**(1/3)


def attenuate(data_array, depth_attenuation_factors, wave_array, nodata):
    """ Return NumPy array that has the attenuation factor applied to its values and fill with NoData values. """
    attenuated =  np.log(data_array) * depth_attenuation_factors * wave_array
    return attenuated.filled(nodata)
```

* 2023-10-04: V1.1 is a modification of the formula below from DOI: 10.1080/01490410802053674. We also include slope in the calculations of REI values.

![Attenuation formula](reference/attenuation.png)

```
def get_attenuation_factor(k_values, depth_masked):
    """ Return attenuation factor based on masked depth values and k array of values. """
    return np.exp(-k_values * depth_masked)


def get_k_constant(rei_values):
    """ Return constant k using acceleration of gravity constant and relative exposure index array. """
    return (22**2)*((1/rei_values)**(2/3))*g**(1/3)


def attenuate(data_array, attenuation_factors, slope_masked, nodata):
    """ Return NumPy array that has the attenuation factor applied to its values and fill with NoData values. """
    attenuated =  data_array * attenuation_factors * slope_masked
    return attenuated.filled(nodata)
```

## 4. Scope

The project scope encompasses the following key areas:

- Spatial analysis of nearshore (<= 50 m depth and within 5km of coast) environment in Pacific Canada.
- Development and modification of R, Python, and shell scripts for data processing and analysis.
- Utilization of the Climate Data Operators (CDO) software for specific operations.
- Creation of geotiff raster files for the five predefined regions.

## 5. Methodology

The project continues to follow the established methodology, including data collection, preprocessing, spatial analysis, CDO integration, geotiff raster generation, quality control, and documentation.



## 6. Data Sources

Data from various sources, including the High Resolution Deterministic Prediction System (HRDPS) wind data and existing fetch data, have been collected and integrated into the analysis. Bathymetric data will be used to apply a exponential decay or other function.

[View Wind Rose for Max Speed (binned)](reference/mx_spd_bin_rose.html)

[Watch Video](https://youtu.be/ORtiZIZJf-M)

## 7. Tools and Technologies

The project relies on the following tools and technologies:

- Geographic Information System (GIS) software for spatial analysis.
- Python and R programming for data processing and analysis.
- Climate Data Operators (CDO) software and shell scripts for specific data operation procedures.
- Geospatial libraries and packages for Python (e.g., ArcPy, GeoPandas, xarray, and rasterio).

## 8. Progress Update

![Progress Chart](reference/status.png)

### Relative Exposure Index Layers
#### Updates:
* 2023-10-24: V1.4 (Depth and wave height). A Coastal Environmental Exposure layer (https://open.canada.ca/data/en/dataset/e6405791-c9b9-4246-a5ed-e5cf610075b5) was downloaded and processed as part of V1.4. The line feature class (WaveHeight) represents mean maximum significant wave height over 25 years. The Generate Points from Line tool in ArcGIS was used to create points every 10 km along the lines within each region. These points were then interpolated using the Spline statistical interpolation tool for each region. The main reason for testing wave height was to address areas such as Haida Gwaii where higher wave energy is known, but not captured using only wind data.

![Wave Height (m)](reference/wave-height-m.png)

![Wave Interpolated (m)](reference/wave-interpolated-m.png)

![Haida Gwaii](reference/hg-1.4.png)

![Salish Sea](reference/sog-1.4.png)

![Queen Charlotte Strait](reference/qcs-1.4.png)

![West Coast Vancouver Island](reference/wcvi-1.4.png)

![North Central Coast](reference/ncc-1.4.png)

* 2023-10-04: V1.1 (Regional wind rose plots)
![Salish Sea](reference/sog-wind-rose.png)

![Queen Charlotte Strait](reference/qcs-wind-rose.png)

![West Coast Vancouver Island](reference/wcvi-wind-rose.png)

![North Central Coast](reference/ncc-wind-rose.png)

![Haida Gwaii](reference/hg-wind-rose.png)

* 2023-10-04: V1.1 (Depth and slope attenuation)

![Salish Sea](reference/sog-att.png)

![Queen Charlotte Strait](reference/qcs-att.png)

![West Coast Vancouver Island](reference/wcvi-att.png)

![North Central Coast and Haida Gwaii](reference/ncc_hg-att.png)

* V1.0 (Relative Exposure Indices)
![Salish Sea](reference/sog.png)

![Queen Charlotte Strait](reference/qcs.png)

![West Coast Vancouver Island](reference/wcvi.png)

![North Central Coast and Haida Gwaii](reference/ncc_hg.png)


### Key Achievements:
- Translation of R code to CDO operations.
- High Resolution wind data processed for all regions.
- Initial REI layers created.

### Current Status:
- Data collection and preprocessing are complete. Preprocessing includes getting tabular fetch data from spatial files and ensuring consistency in attributes between all regions.
- Translation of R code into CDO software operations in shell scripts is complete.
- Spatial analysis for Relative Exposure Index is in progress. This includes running the shell scripts with CDO operations for each of the five regions.
- Python scripts for depth attenuation analysis are being refined. The remaining component testing and implementing a decay factor for depth attenuation of the REI products.
- Initial geotiff raster files have been generated.

#### Updates:
* 2023-10-04: V1.1 testing an attenuation factor formula from: Trine Bekkby , Pål Erik Isachsen , Martin Isæus & Vegar Bakkestuen (2008) GIS Modeling of Wave Exposure at the Seabed: A Depth-attenuated Wave Exposure Model, Marine Geodesy, 31:2, 117-127, DOI: 10.1080/01490410802053674

## 9. Challenges

![Challenges Image](reference/hsig.png)

### Current Challenges:
- Wave data: too many uncertainties about creating REI layer derived from modelled wave products. Different data sources, varying resolution, and most importantly an unknown process to calculate the REI. There are also data gaps to consider with modelled wave data. In contrast, using wind data follows an established methodology and a consistent source for all regions.
- Depth attenuation formula: currently looking at exponential decay factor applied to REI.
- Validating results: comparison to UVIC wave data showed greater agreement between original fetch and significant wave height because HSIG was greater further from coast which aligns with fetch sum calculations.
#### Updates:
* 2023-10-04: V1.1 Identified error with calculating grand mean of 95th percentile of wind data values from daily max wind speeds. Same patterns occur in the result, just with higher values for max wind speeds.

## 10. Next Steps

### Immediate Next Steps:
- Complete spatial analysis and depth attenuation.
- Finalize Python, shell, and R scripts for data processing.
- Update README.md file with all methods and data sources.
- Generate geotiff raster files for all regions and normalize.
- Package and publish on GIS Hub (align rasters, normalize, create metadata record).

## 11. Conclusion

The project is progressing steadily toward its objectives, with key milestones achieved and challenges being addressed. 
