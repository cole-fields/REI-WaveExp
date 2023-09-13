#  Project Status Update: Relative Exposure Index (REI) in Pacific Canada

**Project Repository:** https://github.com/cole-fields/REI-WaveExp/tree/hrdps

**Date:** 2023-09-13

![Barkley Sound Relative Exposure Index](barkley.png)

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

The project's primary goal is to generate five regional spatial layers that provide a relative exposure index (REI) to wind-driven waves along the coastal zone of Pacific Canada. The focus is on generating depth-attenuated Relative Exposure Index layers.

## 3. Objectives

The project's main objectives remain unchanged:

- Generate and deliver Relative Exposure Index geotiff raster files for five predefined regions for species distribution modelling.
- Implement depth attenuation to account for the diminishing effect of wind-wave energy with greater depth.
- Normalize output rasters on 0-1 scale and align with other predictor variables.
- Package data and metadata and publish on GIS Hub.
- Document code on repository.

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

## 7. Tools and Technologies

The project relies on the following tools and technologies:

- Geographic Information System (GIS) software for spatial analysis.
- Python and R programming for data processing and analysis.
- Climate Data Operators (CDO) software and shell scripts for specific data operation procedures.
- Geospatial libraries and packages for Python (e.g., GeoPandas, xarray, and rasterio).

## 8. Progress Update

![Progress Chart](insert_progress_chart_url_here) <!-- You can add a progress chart or graph here -->

### Key Achievements:
- [Insert Achievement 1]
- [Insert Achievement 2]
- [Insert Achievement 3]

### Current Status:
- Data collection and preprocessing are complete.
- Spatial analysis for Relative Exposure Index is in progress.
- Python scripts for analysis are being refined.
- CDO software integration is underway.
- Initial geotiff raster files have been generated.

## 9. Challenges

![Challenges Image](insert_challenges_image_url_here) <!-- You can add an image highlighting project challenges -->

### Current Challenges:
- [Insert Challenge 1]
- [Insert Challenge 2]
- [Insert Challenge 3]

## 10. Next Steps

### Immediate Next Steps:
- Complete spatial analysis and depth attenuation.
- Finalize Python scripts for data processing.
- Ensure accuracy of CDO software integration.
- Generate geotiff raster files for all regions.
- Begin documentation of the methodology and workflows.

## 11. Conclusion

The project is progressing steadily toward its objectives, with key milestones achieved and challenges being addressed. The team remains committed to delivering high-quality geospatial data to support Fisheries and Oceans Canada in effective fisheries management.

![Project Team](insert_team_photo_url_here) <!-- You can add a team photo for a personal touch -->

For any inquiries or updates, please contact [Insert Project Manager's Name] at [Insert Contact Information].