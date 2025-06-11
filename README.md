# nhsbsa

An R package to access the NHS Business Services Authority (NHSBSA) Open Data Portal API.

## Overview

The `nhsbsa` package provides convenient functions to access and download data from the NHSBSA Open Data Portal. It includes functions to:

- List available datasets
- Retrieve dataset metadata
- Download prescribing and other healthcare data
- Search for specific medications or treatments
- Filter data by various criteria

## Installation

You can install the development version of nhsbsa from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("username/nhsbsa")
```

## Usage

### Basic Operations

``` r
library(nhsbsa)

# List all available datasets
datasets <- nhsbsa_list_datasets()

# Get metadata for English Prescribing Data
metadata <- nhsbsa_get_metadata("english-prescribing-data-epd")

# List available data files
resources <- nhsbsa_list_resources("english-prescribing-data-epd")
```

### Download Prescribing Data

``` r
# Download EPD data for a specific month and organization
epd_data <- nhsbsa_get_epd(
  year = 2024,
  month = 1,
  pco_code = "13T00",  # NHS Greater Manchester ICB
  limit = 1000
)

# Search for specific medications
paracetamol_data <- nhsbsa_search_epd_chemical(
  chemical_pattern = "paracetamol",
  year = 2024,
  month = 1,
  exact_match = FALSE,
  limit = 500
)
```

### Direct Data Download

``` r
# Download data directly from a resource with custom filters
data <- nhsbsa_download_data(
  resource_name = "EPD_202401",
  where_conditions = list(
    pco_code = "13T00",
    bnf_code = "0102000C0"
  ),
  limit = 100
)
```

## Key Features

- **Tidyverse Integration**: Uses modern R practices and the native pipe `|>`
- **Error Handling**: Robust error checking and informative error messages
- **API Validation**: Checks API availability before making requests
- **Flexible Filtering**: Support for complex SQL-like filtering conditions
- **Performance**: Efficient data retrieval with optional result limits
- **Documentation**: Comprehensive function documentation with examples

## Data Sources

The package accesses data from the NHSBSA Open Data Portal, including:

- English Prescribing Dataset (EPD)
- Pharmacy and contractor data
- Prescribing statistics
- And other healthcare datasets

## Requirements

- R (>= 4.1.0) for native pipe support
- Internet connection to access the NHSBSA API
- Required packages: httr2, dplyr, purrr, rlang

## License

MIT License

## Support

For issues and questions, please file an issue on the GitHub repository.
