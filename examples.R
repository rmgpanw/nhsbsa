# NHSBSA Package Usage Examples

## Installation
# The package can be installed from source:
# devtools::install()

## Basic Usage

library(nhsbsa)

# List all available datasets
# datasets <- nhsbsa_list_datasets()
# print(datasets)

# Get metadata for a specific dataset
# metadata <- nhsbsa_get_metadata("english-prescribing-data-epd")
# print(names(metadata))

# List resources (data files) for a dataset
# resources <- nhsbsa_list_resources("english-prescribing-data-epd")
# print(head(resources))

# Download EPD data with filters
# epd_data <- nhsbsa_get_epd(
#   year = 2024,
#   month = 1,
#   pco_code = "13T00",  # Example PCO code
#   limit = 100
# )
# print(head(epd_data))

# Search for prescriptions by chemical name
# paracetamol_data <- nhsbsa_search_epd_chemical(
#   chemical_pattern = "paracetamol",
#   year = 2024,
#   month = 1,
#   exact_match = FALSE,
#   limit = 50
# )
# print(head(paracetamol_data))

# Download data directly from a resource
# data <- nhsbsa_download_data(
#   resource_name = "EPD_202401",
#   where_conditions = list(
#     pco_code = "13T00",
#     bnf_code = "0102000C0"
#   ),
#   limit = 100
# )
# print(head(data))

## Error Handling
# The package includes robust error handling:
# - API availability checks
# - Input validation
# - Informative error messages
# - Graceful handling of empty results

## Performance Tips
# - Use specific filters to reduce data size
# - Use limits for exploratory analysis
# - Cache results for repeated use
# - Use BNF codes instead of text searches when possible
