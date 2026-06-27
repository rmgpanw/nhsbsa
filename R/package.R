# Dataset ("package") endpoints -----------------------------------------------
#
# In CKAN a dataset is a "package". These functions are thin wrappers around the
# corresponding CKAN actions, with one argument per documented API parameter.

#' List available datasets
#'
#' Wraps the CKAN `package_list` action to return the identifiers of every
#' dataset published on the NHSBSA Open Data Portal.
#'
#' @param .return_raw Logical. If `TRUE`, return the full parsed CKAN response
#'   envelope instead of the processed result. Defaults to `FALSE`.
#'
#' @return A character vector of dataset identifiers. With `.return_raw = TRUE`,
#'   the parsed response envelope as a list.
#'
#' @seealso [nhsbsa_package_show()] for a dataset's metadata,
#'   [nhsbsa_package_search()] to search datasets.
#'
#' @export
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' datasets <- nhsbsa_package_list()
#' length(datasets)
#' head(datasets)
nhsbsa_package_list <- function(.return_raw = FALSE) {
  out <- nhsbsa_query("package_list")
  if (.return_raw) {
    return(out)
  }
  purrr::map_chr(out, as.character)
}

#' Show a dataset's metadata
#'
#' Wraps the CKAN `package_show` action to return the full metadata for a single
#' dataset, including its list of resources (downloadable files and datastore
#' tables).
#'
#' @param id Character scalar. The dataset identifier or name, as returned by
#'   [nhsbsa_package_list()].
#' @inheritParams nhsbsa_package_list
#'
#' @return A list of dataset metadata. With `.return_raw = TRUE`, the parsed
#'   response envelope as a list.
#'
#' @seealso [nhsbsa_list_resources()] for a tidy table of a dataset's resources.
#'
#' @export
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' metadata <- nhsbsa_package_show("english-prescribing-data-epd")
#' metadata$title
#'
#' # The dataset's resources (files / datastore tables)
#' length(metadata$resources)
#' metadata$resources[[1]]$name
nhsbsa_package_show <- function(id, .return_raw = FALSE) {
  nhsbsa_query("package_show")
}

#' Search datasets
#'
#' Wraps the CKAN `package_search` action, a Solr-backed search over datasets.
#'
#' @param q Character scalar. The Solr query string (e.g. `"prescribing"`).
#'   Defaults to `NULL` (match all).
#' @param fq Character scalar. A Solr filter query.
#' @param sort Character scalar. Sort order, e.g. `"metadata_modified desc"`.
#' @param rows Integer. Maximum number of datasets to return.
#' @param start Integer. Offset into the result set, for paging.
#' @inheritParams nhsbsa_package_list
#'
#' @return A list with the search `count` and matching datasets in `results`.
#'   With `.return_raw = TRUE`, the parsed response envelope as a list.
#'
#' @export
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' # Free-text search
#' hits <- nhsbsa_package_search(q = "prescribing", rows = 5)
#' hits$count
#'
#' # Filter by tag (as clicking a tag on the website does) and sort the results
#' nhsbsa_package_search(
#'   fq = 'tags:"Prescribing"',
#'   sort = "metadata_modified desc",
#'   rows = 5
#' )
#'
#' # Page through results with `rows` and `start`
#' nhsbsa_package_search(q = "dental", rows = 10, start = 10)
nhsbsa_package_search <- function(
  q = NULL,
  fq = NULL,
  sort = NULL,
  rows = NULL,
  start = NULL,
  .return_raw = FALSE
) {
  nhsbsa_query("package_search")
}
