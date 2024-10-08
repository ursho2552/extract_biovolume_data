# Translating Biovolume Image Data to DarwinCore CSV Format

## Overview

This MATLAB script translates biovolume image data from various instruments used during the Tara Oceans Cruise into CSV files formatted according to the DarwinCore standard. The data originates from different imaging devices, and the script processes and consolidates it into a structured dataset with relevant metadata.

The script handles three layers of data:

   - **Raw Datasets** from Ecotaxa exports and various imaging devices.
   - **Mergedbase.mat:** A MATLAB struct file that contains pre-processed, quality-checked datasets with environmental measurements and biovolume calculations.
   - **MergedbaseC.mat:** A similar dataset, with additional conversion of normalized biomass size spectra into carbon units.

## Structure of Data

The script processes data from a variety of instruments such as:

   - Flowcytometry
   - Imaging Flowcytobot (IFCB)
   - Zooscan
   - UVP data
   - eHFCM nets (5µm and 20µm)

The primary calculations include:

   -  **Biovolume per group** (mm³.m⁻³)
   -  **Normalized biovolume size spectra** assuming plain area, extruded area, or ellipsoidal equivalent estimates.
   -  **Carbon conversion** using size-biomass conversion factors.

The script performs operations to fill in missing metadata, correct station latitude and longitude, and apply functional and trophic group classifications. It also merges supplementary environmental data.

## Usage

1. Setup

Ensure that the necessary dataset files (Mergedbase.mat, MergedbaseC.mat, and supplementary files) are available in the working directory. The script uses various data sources, including CSV files (TARA_locs_date.csv) and supplementary information from an Excel file (table SI-4.xlsx).


2. Load Data

The script starts by loading the imaging dataset (Mergedbase and MergedbaseC) and initializes variables for processing the data.


3. Process Data

The script extracts and processes biovolume, abundance, and carbon data for each instrument. It performs operations such as:

   - Extracting station latitude and longitude
   - Extending the dataset with additional metadata (e.g., year, month)
   - Filling in missing data using supplementary information

4. Generate CSV

After processing, the script organizes the data into a table, which is then saved as a CSV file in the specified output directory.


5. Visualize and Correct Data

The script includes a section for visualizing station locations using latitude and longitude data, identifying potential misaligned stations, and correcting them based on hydrographical information.

6. NetCDF Preparation

The script also prepares data for gridding into 1°x1° latitude-longitude grids for each instrument and computes mean carbon and biovolume values for further analysis.
## Key Outputs

### CSV Files

   - The primary output is a CSV file  that contains the processed data, ready for downstream analysis or sharing.
   - An additional CSV file for a subset of the data that contains data on functional plankton types, total biovolume, and carbon content.

### Variables Included in CSV

  -  ProjectID: Identifier for the project (e.g., TARA_Oceans_imaging_devices)
  -  SampleID: Unique identifier for each sample, generated if missing
  -  ContactName, ContactAddress: Contact information for dataset curators
  -  occurrenceID: Unique identifier for each occurrence (combination of latitude, longitude, date, etc.)
  -  Latitude, Longitude: Geographical coordinates of the sampling station
  -  PFT: Planktonic functional type
  -  Living: Indicator of whether the taxa is living or non-living
  -  Biovolume, Carbon Biomass: Biovolume and carbon biomass for each sample
  -  Instrument: The imaging device used to capture the data
  -  Trophic_group, Carbon_conversion_scaling, Carbon_conversion_exponent: Data for trophic group and carbon conversion factors
  -  Sample volume, Net mesh, and other metadata

### Visualization

The script generates a map to visualize the station locations and compare them with the original TARA event locations, helping to identify any discrepancies.

### Prerequisites

  -  MATLAB
  -  Datasets:
    - Mergedbase.mat and MergedbaseC.mat
    - Supplementary files (table SI-4.xlsx, TARA_locs_date.csv)
  -  Coastlines data for visualization

### Supplementary Functions

    get_tot_values(): Extracts total values from the Mergedbase and MergedbaseC datasets.
    importfile(): Imports data from CSV files.
    get_supplementary_information(): Loads supplementary data from the Excel file.
    findLargestSubstring(): Matches taxa names with the supplementary table.
    get_stations(): Extracts station information from metaplankton datasets.
