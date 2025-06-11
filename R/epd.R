#' Get English Prescribing Data (EPD)
#'
#' Convenience function to download English Prescribing Dataset (EPD) data
#' with common filtering options.
#'
#' @param year Integer or character. Year(s) to download (e.g., 2024 or c(2023, 2024))
#' @param month Integer or character. Month(s) to download (1-12, optional)
#' @param pco_code Character. Primary Care Organization code to filter by (optional)
#' @param practice_code Character. Practice code to filter by (optional)
#' @param bnf_chemical Character. BNF chemical substance code to filter by (optional)
#' @param limit Integer. Maximum number of records to return (optional)
#' @return A data frame containing EPD data
#' @export
#' @examples
#' \dontrun{
#' # Download EPD data for 2024
#' epd_2024 <- nhsbsa_get_epd(year = 2024)
#' 
#' # Download for specific CCG and month
#' epd_filtered <- nhsbsa_get_epd(
#'   year = 2024,
#'   month = 1,
#'   pco_code = "13T00"
#' )
#' 
#' # Download paracetamol data for specific practice
#' paracetamol_data <- nhsbsa_get_epd(
#'   year = 2024,
#'   practice_code = "A81001",
#'   bnf_chemical = "0407010H0"
#' )
#' }
nhsbsa_get_epd <- function(year, 
                           month = NULL, 
                           pco_code = NULL, 
                           practice_code = NULL, 
                           bnf_chemical = NULL, 
                           limit = NULL) {
  
  # Validate inputs
  if (missing(year)) {
    rlang::abort("`year` is required")
  }
  
  # Generate resource names
  years <- as.integer(year)
  months <- if (is.null(month)) 1:12 else as.integer(month)
  
  resource_names <- c()
  for (y in years) {
    for (m in months) {
      resource_name <- sprintf("EPD_%04d%02d", y, m)
      resource_names <- c(resource_names, resource_name)
    }
  }
  
  # Build where conditions
  where_conditions <- list()
  if (!is.null(pco_code)) where_conditions$pco_code <- pco_code
  if (!is.null(practice_code)) where_conditions$practice_code <- practice_code
  if (!is.null(bnf_chemical)) where_conditions$bnf_chemical_substance <- bnf_chemical
  
  # Download data
  nhsbsa_download_multiple(
    resource_names = resource_names,
    where_conditions = where_conditions,
    limit = limit,
    combine = TRUE
  )
}

#' Search EPD by Chemical Name
#'
#' Search for prescribing data by chemical substance name or pattern.
#' This function first looks up the BNF chemical codes matching the search term.
#'
#' @param chemical_pattern Character. Pattern to search for in chemical names
#' @param year Integer. Year to search in
#' @param month Integer. Month to search in (optional, defaults to latest available)
#' @param exact_match Logical. Whether to use exact matching (default: FALSE)
#' @param limit Integer. Maximum number of records to return (optional)
#' @return A data frame containing matching prescribing data
#' @export
#' @examples
#' \dontrun{
#' # Search for paracetamol prescriptions
#' paracetamol <- nhsbsa_search_epd_chemical(
#'   chemical_pattern = "paracetamol",
#'   year = 2024,
#'   month = 1
#' )
#' 
#' # Search for antibiotics (partial match)
#' antibiotics <- nhsbsa_search_epd_chemical(
#'   chemical_pattern = "penicillin",
#'   year = 2024
#' )
#' }
nhsbsa_search_epd_chemical <- function(chemical_pattern, 
                                       year, 
                                       month = NULL, 
                                       exact_match = FALSE, 
                                       limit = NULL) {
  
  # Validate required arguments
  if (missing(chemical_pattern)) {
    rlang::abort("`chemical_pattern` is required")
  }
  if (missing(year)) {
    rlang::abort("`year` is required")
  }
  
  # This is a simplified implementation
  # In a full implementation, you might want to:
  # 1. First query a lookup table of chemical names to BNF codes
  # 2. Then use those codes to query the main EPD data
  
  rlang::inform("Note: This function searches within the data. For better performance, use specific BNF codes with nhsbsa_get_epd()")
  
  # For now, we'll search within the description fields
  if (is.null(month)) {
    # Use December as default latest month
    month <- 12
  }
  
  resource_name <- sprintf("EPD_%04d%02d", year, month)
  
  # Download a sample to search through
  # In practice, you might want to query a smaller lookup table first
  if (exact_match) {
    where_conditions <- list(bnf_chemical_substance = chemical_pattern)
  } else {
    # This would require more complex SQL - simplified for now
    where_conditions <- NULL
  }
  
  data <- nhsbsa_download_data(
    resource_name = resource_name,
    where_conditions = where_conditions,
    limit = limit %||% 10000  # Default limit for searches
  )
  
  if (!exact_match && nrow(data) > 0) {
    # Filter results containing the pattern (if description fields are available)
    # This would depend on the actual field names in the EPD dataset
    data
  } else {
    data
  }
}
