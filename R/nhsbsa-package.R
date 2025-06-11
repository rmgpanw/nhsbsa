#' nhsbsa: Access NHS Business Services Authority Open Data Portal API
#'
#' This package provides functions to access and download data from the 
#' NHS Business Services Authority (NHSBSA) Open Data Portal API. 
#'
#' @section Main functions:
#' \describe{
#'   \item{\code{\link{nhsbsa_list_datasets}}}{List all available datasets}
#'   \item{\code{\link{nhsbsa_get_metadata}}}{Get metadata for a specific dataset}
#'   \item{\code{\link{nhsbsa_download_data}}}{Download data from a specific resource}
#'   \item{\code{\link{nhsbsa_get_epd}}}{Get English Prescribing Dataset (EPD) data}
#' }
#'
#' @section API Information:
#' The NHSBSA Open Data Portal provides access to various healthcare datasets
#' including prescribing data, dental statistics, and more. All data is 
#' publicly available and subject to the Open Government Licence.
#'
#' @keywords internal
"_PACKAGE"

# Import pipe operator - note: |> is base R, no import needed
NULL
