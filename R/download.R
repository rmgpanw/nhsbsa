#' Download Data from NHSBSA API
#'
#' Downloads data from a specific resource using SQL queries. This function
#' provides a flexible interface to query NHSBSA datasets.
#'
#' @param resource_name Character string. Name or ID of the resource to query
#' @param where_conditions Named list. Field-value pairs for WHERE conditions.
#'   Values should be character strings and will be properly quoted.
#' @param select_fields Character vector. Fields to select (default: all fields "*")
#' @param limit Integer. Maximum number of records to return (default: no limit)
#' @return A data frame containing the requested data
#' @export
#' @examples
#' \dontrun{
#' # Download data for specific CCG and chemical substance
#' data <- nhsbsa_download_data(
#'   resource_name = "EPD_202401",
#'   where_conditions = list(
#'     pco_code = "13T00",
#'     bnf_chemical_substance = "0407010H0"
#'   )
#' )
#' 
#' # Download only specific fields with limit
#' data_limited <- nhsbsa_download_data(
#'   resource_name = "EPD_202401",
#'   select_fields = c("pco_code", "practice_code", "total_items"),
#'   where_conditions = list(pco_code = "13T00"),
#'   limit = 1000
#' )
#' }
nhsbsa_download_data <- function(resource_name, 
                                 where_conditions = NULL, 
                                 select_fields = "*", 
                                 limit = NULL) {
  
  if (!is.character(resource_name) || length(resource_name) != 1) {
    rlang::abort("`resource_name` must be a character string")
  }
  
  if (!check_api_availability()) {
    rlang::abort("NHSBSA API is not available. Please check your internet connection.")
  }
  
  # Build SQL query
  sql_query <- build_sql_query(resource_name, where_conditions, select_fields)
  
  if (!is.null(limit)) {
    sql_query <- paste(sql_query, "LIMIT", limit)
  }
  
  # Build API URL
  url <- paste0(
    BASE_ENDPOINT,
    "datastore_search_sql?resource_id=",
    resource_name,
    "&sql=",
    utils::URLencode(sql_query)
  )
  
  resp <- httr2::request(url) |>
    httr2::req_timeout(60) |>  # Longer timeout for data downloads
    httr2::req_perform()
  
  if (httr2::resp_is_error(resp)) {
    rlang::abort("Failed to download data from resource: ", resource_name)
  }
  
  content <- httr2::resp_body_json(resp)
  
  if (!content$success) {
    rlang::abort("API returned error: ", content$error$message %||% "Unknown error")
  }
  
  # Extract records and convert to data frame
  records <- content$result$records
  
  if (length(records) == 0) {
    rlang::warn("No records found matching the specified criteria")
    return(data.frame())
  }
  
  # Convert list to data frame
  dplyr::bind_rows(records)
}

#' Download Multiple Resources
#'
#' Downloads and combines data from multiple resources. Useful for getting
#' data across multiple time periods.
#'
#' @param resource_names Character vector. Names or IDs of resources to query
#' @param where_conditions Named list. Field-value pairs for WHERE conditions
#' @param select_fields Character vector. Fields to select (default: all fields)
#' @param limit Integer. Maximum number of records per resource (default: no limit)
#' @param combine Logical. Whether to combine results into single data frame (default: TRUE)
#' @return A data frame (if combine=TRUE) or list of data frames (if combine=FALSE)
#' @export
#' @examples
#' \dontrun{
#' # Download EPD data for multiple months
#' epd_resources <- c("EPD_202401", "EPD_202402", "EPD_202403")
#' 
#' multi_month_data <- nhsbsa_download_multiple(
#'   resource_names = epd_resources,
#'   where_conditions = list(
#'     pco_code = "13T00",
#'     bnf_chemical_substance = "0407010H0"
#'   )
#' )
#' 
#' # Download as separate data frames
#' separate_data <- nhsbsa_download_multiple(
#'   resource_names = epd_resources,
#'   where_conditions = list(pco_code = "13T00"),
#'   combine = FALSE
#' )
#' }
nhsbsa_download_multiple <- function(resource_names, 
                                     where_conditions = NULL, 
                                     select_fields = "*", 
                                     limit = NULL, 
                                     combine = TRUE) {
  
  if (!is.character(resource_names) || length(resource_names) == 0) {
    rlang::abort("`resource_names` must be a non-empty character vector")
  }
  
  message("Downloading data from ", length(resource_names), " resources...")
  
  # Download data from each resource
  results <- purrr::map(resource_names, function(resource_name) {
    message("  Downloading: ", resource_name)
    tryCatch({
      nhsbsa_download_data(
        resource_name = resource_name,
        where_conditions = where_conditions,
        select_fields = select_fields,
        limit = limit
      )
    }, error = function(e) {
      rlang::warn("Failed to download ", resource_name, ": ", e$message)
      data.frame()
    })
  })
  
  names(results) <- resource_names
  
  if (combine) {
    message("Combining results...")
    dplyr::bind_rows(results, .id = "resource_name")
  } else {
    results
  }
}
