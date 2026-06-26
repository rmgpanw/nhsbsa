# Datastore (row-query) endpoints ---------------------------------------------
#
# The datastore lets you query the rows of a resource without downloading the
# whole file. These are pure wrappers around the CKAN `datastore_search` and
# `datastore_search_sql` actions, kept separate from the file-download helpers
# in resources.R.

#' Search a resource's rows
#'
#' Wraps the CKAN `datastore_search` action to query the rows of a datastore
#' resource. One argument is provided for each documented API parameter.
#'
#' The CKAN datastore returns at most one page of rows per request (the server
#' enforces a maximum `limit`). When more rows match than are returned, a warning
#' of class `nhsbsa_incomplete_results` is signalled describing how to page
#' through the rest by increasing `offset`.
#'
#' @param resource_id Character scalar. The resource to query. The NHSBSA
#'   datastore identifies a resource by its *name* (the `name` column of
#'   [nhsbsa_list_resources()]), e.g. `"EPD_201401"`, rather than its `id`.
#' @param q Character scalar, or a JSON object string for fielded search. A
#'   full-text query.
#' @param distinct Logical. Return only distinct rows?
#' @param plain Logical. Treat `q` as plain text (rather than a complex search
#'   expression)?
#' @param language Character scalar. The text-search language (e.g. `"english"`).
#' @param limit Integer. Maximum number of rows to return in this request.
#' @param offset Integer. Number of rows to skip, for paging.
#' @param fields Character vector. The fields to return, in order.
#' @param sort Character scalar or vector. Sort clause(s), e.g.
#'   `"total_items desc"`.
#' @param filters Named list. Field-value pairs to filter on, sent to the API as
#'   a JSON object (e.g. `list(bnf_chemical_substance = "0407010H0")`).
#' @param include_total Logical. Include the total match count in the response?
#'   Required for the incomplete-results warning; defaults to the API default
#'   (`TRUE`) when left `NULL`.
#' @inheritParams nhsbsa_package_list
#'
#' @return A tibble with one row per matching record. With `.return_raw = TRUE`,
#'   the parsed response envelope as a list (including `total` and `fields`).
#'
#' @seealso [nhsbsa_datastore_search_sql()] to query with SQL,
#'   [nhsbsa_download_resource()] to download the whole resource file.
#'
#' @export
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' nhsbsa_datastore_search(
#'   resource_id = "EPD_202401",
#'   filters = list(pco_code = "13T00"),
#'   limit = 10
#' )
nhsbsa_datastore_search <- function(
  resource_id,
  q = NULL,
  distinct = NULL,
  plain = NULL,
  language = NULL,
  limit = NULL,
  offset = NULL,
  fields = NULL,
  sort = NULL,
  filters = NULL,
  include_total = NULL,
  .return_raw = FALSE
) {
  result <- nhsbsa_query("datastore_search")
  if (.return_raw) {
    return(result)
  }

  records <- nhsbsa_records_to_tibble(result$records)
  nhsbsa_warn_incomplete_results(
    result,
    n_returned = nrow(records),
    offset = offset
  )
  records
}

#' Query a resource with SQL
#'
#' Wraps the CKAN `datastore_search_sql` action, which runs a read-only SQL query
#' against the datastore. The `sql` string is sent to the API verbatim; paging is
#' the caller's responsibility (via `LIMIT`/`OFFSET` in the query).
#'
#' @param resource_id Character scalar. The resource the query targets. The
#'   NHSBSA datastore requires this alongside `sql`, and identifies a resource by
#'   its *name* (the `name` column of [nhsbsa_list_resources()]), e.g.
#'   `"EPD_201401"`. Reference the same name in the query's `FROM` clause.
#' @param sql Character scalar. A single read-only SQL `SELECT` statement, e.g.
#'   ``'SELECT * FROM `EPD_201401` LIMIT 10'``.
#' @inheritParams nhsbsa_package_list
#'
#' @return A tibble with one row per record returned by the query. With
#'   `.return_raw = TRUE`, the parsed response envelope as a list.
#'
#' @seealso [nhsbsa_datastore_search()] for a parameterised search.
#'
#' @export
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' nhsbsa_datastore_search_sql(
#'   resource_id = "EPD_202401",
#'   sql = "SELECT * FROM `EPD_202401` LIMIT 10"
#' )
nhsbsa_datastore_search_sql <- function(resource_id, sql, .return_raw = FALSE) {
  result <- nhsbsa_query("datastore_search_sql")
  if (.return_raw) {
    return(result)
  }
  # The NHSBSA endpoint wraps the query outcome in a second envelope, reporting
  # query-level failures (e.g. invalid SQL) via an inner `success` flag.
  if (isFALSE(result$success)) {
    nhsbsa_abort_api_error(list(message = result$message))
  }
  nhsbsa_records_to_tibble(result$result$records)
}

# Warn when a datastore_search returned fewer rows than match the query, telling
# the caller how to page through the remainder.
nhsbsa_warn_incomplete_results <- function(result, n_returned, offset) {
  total <- result$total
  if (is.null(total)) {
    return(invisible())
  }
  total <- as.numeric(total)
  offset <- offset %||% 0
  retrieved <- offset + n_returned

  if (total > retrieved) {
    remaining <- total - retrieved
    next_offset <- retrieved
    nhsbsa_warn(
      c(
        "!" = "Retrieved {n_returned} of {total} matching row{?s};
               {remaining} not returned.",
        "i" = "Fetch the next page with {.code offset = {next_offset}} (reusing
               your other arguments), increasing {.arg offset} until all rows
               are retrieved.",
        "i" = "Raising {.arg limit} returns more rows per request, up to the
               server-side maximum."
      ),
      class = "nhsbsa_incomplete_results"
    )
  }

  invisible()
}
