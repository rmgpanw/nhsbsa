#' List Available Datasets
#'
#' Retrieves a list of all available datasets from the NHSBSA Open Data Portal.
#'
#' @return A character vector of dataset IDs available in the portal
#' @export
#' @examples
#' \dontrun{
#' # List all available datasets
#' datasets <- nhsbsa_list_datasets()
#' print(datasets)
#' }
nhsbsa_list_datasets <- function() {
  if (!check_api_availability()) {
    rlang::abort("NHSBSA API is not available. Please check your internet connection.")
  }
  
  resp <- httr2::request(paste0(BASE_ENDPOINT, "package_list")) |>
    httr2::req_perform()
  
  if (httr2::resp_is_error(resp)) {
    rlang::abort("Failed to retrieve datasets from NHSBSA API")
  }
  
  content <- httr2::resp_body_json(resp)
  
  if (!content$success) {
    rlang::abort("API returned error: ", content$error$message %||% "Unknown error")
  }
  
  content$result
}

#' Get Dataset Metadata
#'
#' Retrieves detailed metadata for a specific dataset, including available
#' resources (files) and their properties.
#'
#' @param dataset_id Character string. The ID of the dataset to retrieve metadata for
#' @return A list containing dataset metadata including resources information
#' @export
#' @examples
#' \dontrun{
#' # Get metadata for English Prescribing Dataset
#' metadata <- nhsbsa_get_metadata("english-prescribing-data-epd")
#' 
#' # View available resources
#' resources <- metadata$resources
#' print(resources[c("name", "created", "format")])
#' }
nhsbsa_get_metadata <- function(dataset_id) {
  if (!validate_dataset_id(dataset_id)) {
    rlang::abort("`dataset_id` must be a non-empty character string")
  }
  
  if (!check_api_availability()) {
    rlang::abort("NHSBSA API is not available. Please check your internet connection.")
  }
  
  url <- paste0(BASE_ENDPOINT, "package_show?id=", dataset_id)
  
  resp <- httr2::request(url) |>
    httr2::req_perform()
  
  if (httr2::resp_is_error(resp)) {
    rlang::abort("Failed to retrieve metadata for dataset: ", dataset_id)
  }
  
  content <- httr2::resp_body_json(resp)
  
  if (!content$success) {
    rlang::abort("API returned error: ", content$error$message %||% "Unknown error")
  }
  
  content$result
}

#' List Dataset Resources
#'
#' Retrieves a simplified list of resources (files) available for a dataset.
#'
#' @param dataset_id Character string. The ID of the dataset
#' @param pattern Character string. Optional regex pattern to filter resource names
#' @return A data frame with resource information (name, id, created, format)
#' @export
#' @examples
#' \dontrun{
#' # List all resources for EPD dataset
#' resources <- nhsbsa_list_resources("english-prescribing-data-epd")
#' 
#' # Filter for 2024 data only
#' resources_2024 <- nhsbsa_list_resources(
#'   "english-prescribing-data-epd", 
#'   pattern = "2024"
#' )
#' print(resources_2024)
#' }
nhsbsa_list_resources <- function(dataset_id, pattern = NULL) {
  metadata <- nhsbsa_get_metadata(dataset_id)
  resources <- metadata$resources
  
  # Convert to data frame with key information
  resource_df <- data.frame(
    name = sapply(resources, function(x) x$name %||% NA_character_),
    id = sapply(resources, function(x) x$id %||% NA_character_),
    created = sapply(resources, function(x) x$created %||% NA_character_),
    format = sapply(resources, function(x) x$format %||% NA_character_),
    stringsAsFactors = FALSE
  )
  
  # Apply pattern filter if provided
  if (!is.null(pattern)) {
    matches <- grepl(pattern, resource_df$name, ignore.case = TRUE)
    resource_df <- resource_df[matches, ]
  }
  
  resource_df
}
