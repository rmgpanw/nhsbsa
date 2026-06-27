# Catalogue endpoints ----------------------------------------------------------
#
# Pure wrappers around the CKAN actions that list the portal's catalogue
# taxonomy: the organisations that publish data, the groups datasets can belong
# to, and the tags applied across datasets.

#' List publishing organisations
#'
#' Wraps the CKAN `organization_list` action to list the organisations that
#' publish datasets on the portal.
#'
#' @param all_fields Logical. If `TRUE`, return a richer record for each
#'   organisation rather than just its name. Defaults to the API default
#'   (`FALSE`) when left `NULL`.
#' @inheritParams nhsbsa_package_list
#'
#' @return A character vector of organisation names. If `all_fields = TRUE`, a
#'   list of organisation records. With `.return_raw = TRUE`, the parsed response
#'   envelope as a list.
#'
#' @seealso [nhsbsa_group_list()], [nhsbsa_tag_list()].
#'
#' @export
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' # Organisation names
#' nhsbsa_organization_list()
#'
#' # Richer records (title, description, dataset count, ...) for each organisation
#' orgs <- nhsbsa_organization_list(all_fields = TRUE)
#' orgs[[1]]$title
nhsbsa_organization_list <- function(all_fields = NULL, .return_raw = FALSE) {
  out <- nhsbsa_query("organization_list")
  if (.return_raw) {
    return(out)
  }
  nhsbsa_simplify_catalogue(out)
}

#' List dataset groups
#'
#' Wraps the CKAN `group_list` action to list the groups (thematic collections)
#' that datasets can belong to.
#'
#' @inheritParams nhsbsa_organization_list
#'
#' @return A character vector of group names. If `all_fields = TRUE`, a list of
#'   group records. With `.return_raw = TRUE`, the parsed response envelope as a
#'   list.
#'
#' @seealso [nhsbsa_organization_list()], [nhsbsa_tag_list()].
#'
#' @export
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' nhsbsa_group_list()
nhsbsa_group_list <- function(all_fields = NULL, .return_raw = FALSE) {
  out <- nhsbsa_query("group_list")
  if (.return_raw) {
    return(out)
  }
  nhsbsa_simplify_catalogue(out)
}

#' List tags
#'
#' Wraps the CKAN `tag_list` action to list the tags applied to datasets. These
#' are the same tags shown on the portal website; you can filter datasets by a
#' tag with [nhsbsa_package_search()] (see `vignette("nhsbsa")`).
#'
#' @param query Character scalar. Restrict the results to tags containing this
#'   string.
#' @param vocabulary_id Character scalar. Restrict the results to tags in a
#'   particular CKAN tag vocabulary.
#' @inheritParams nhsbsa_package_list
#'
#' @return A character vector of tags. With `.return_raw = TRUE`, the parsed
#'   response envelope as a list.
#'
#' @seealso [nhsbsa_package_search()] to find datasets by tag.
#'
#' @export
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' # All tags
#' tags <- nhsbsa_tag_list()
#' length(tags)
#'
#' # Only tags containing a given string
#' nhsbsa_tag_list(query = "prescribing")
nhsbsa_tag_list <- function(
  query = NULL,
  vocabulary_id = NULL,
  .return_raw = FALSE
) {
  out <- nhsbsa_query("tag_list")
  if (.return_raw) {
    return(out)
  }
  nhsbsa_simplify_catalogue(out)
}

# Catalogue actions return either a list of name strings or, with
# `all_fields = TRUE`, a list of records. Collapse the former to a character
# vector and leave the latter as a list.
nhsbsa_simplify_catalogue <- function(x) {
  if (length(x) == 0) {
    return(character(0))
  }
  is_scalar_string <- function(element) {
    is.character(element) && length(element) == 1
  }
  if (all(vapply(x, is_scalar_string, logical(1)))) {
    return(purrr::map_chr(x, as.character))
  }
  x
}
