# Core utilities for NHSBSA API

#' Base URL for NHSBSA Open Data Portal API
#' @noRd
BASE_ENDPOINT <- "https://opendata.nhsbsa.net/api/3/action/"

#' Check if URL is reachable
#' @param url Character string of URL to check
#' @return Logical indicating if URL is reachable
#' @noRd
check_api_availability <- function(url = BASE_ENDPOINT) {
  tryCatch({
    resp <- httr2::request(paste0(url, "package_list")) |>
      httr2::req_timeout(10) |>
      httr2::req_perform()
    !httr2::resp_is_error(resp)
  }, error = function(e) {
    FALSE
  })
}

#' Validate dataset ID format
#' @param dataset_id Character string of dataset ID
#' @return Logical indicating if format is valid
#' @noRd
validate_dataset_id <- function(dataset_id) {
  if (!is.character(dataset_id) || length(dataset_id) != 1) {
    return(FALSE)
  }
  # Basic validation - should be non-empty string
  nzchar(dataset_id)
}

#' Build SQL query for API
#' @param resource_name Character string of resource name
#' @param where_conditions Named list of where conditions
#' @param select_fields Character vector of fields to select (default "*")
#' @return Character string of SQL query
#' @noRd
build_sql_query <- function(resource_name, where_conditions = NULL, select_fields = "*") {
  select_clause <- paste(select_fields, collapse = ", ")
  
  query <- paste0(
    "SELECT ", select_clause, " FROM `", resource_name, "`"
  )
  
  if (!is.null(where_conditions) && length(where_conditions) > 0) {
    where_clauses <- mapply(
      function(field, value) {
        paste0(field, " = '", value, "'")
      },
      names(where_conditions),
      where_conditions,
      USE.NAMES = FALSE
    )
    query <- paste0(query, " WHERE ", paste(where_clauses, collapse = " AND "))
  }
  
  query
}
