# Datastore (row-query) endpoints ---------------------------------------------
#
# The datastore lets you query the rows of a resource without downloading the
# whole file. These are pure wrappers around the CKAN `datastore_search` and
# `datastore_search_sql` actions, kept separate from the file-download helpers
# in resources.R.

#' Search a resource's rows
#'
#' Wraps the CKAN `datastore_search` action to read the rows of a datastore
#' resource. One argument is provided for each documented API parameter.
#'
#' Use this function to *read* rows — choosing and ordering columns with
#' `fields`, sorting with `sort`, and paging with `limit`/`offset`. To *filter*
#' by value or to aggregate, use [nhsbsa_datastore_search_sql()] instead (see
#' Details).
#'
#' The CKAN datastore returns at most one page of rows per request (the server
#' enforces a maximum `limit`). When more rows exist than are returned, a warning
#' of class `nhsbsa_incomplete_results` is signalled describing how to page
#' through the rest by increasing `offset`.
#'
#' @details
#' CKAN's `datastore_search` defines `filters` (exact field matching) and `q`
#' (full-text search) parameters, which this function exposes for API
#' completeness. **This portal's datastore does not apply them** — a query using
#' `filters` or `q` returns no matching rows — so to filter by value, aggregate
#' or compute expressions, use [nhsbsa_datastore_search_sql()] with a SQL
#' `WHERE`/`GROUP BY` clause. See `vignette("nhsbsa")` for worked examples.
#'
#' @param resource_id Character scalar. The resource to query. The NHSBSA
#'   datastore identifies a resource by its *name* (the `name` column of
#'   [nhsbsa_list_resources()]), e.g. `"EPD_201401"`, rather than its `id`.
#' @param q A full-text query (a character scalar, or a named list for a
#'   per-field search). Accepted for API completeness but not applied by this
#'   portal; use [nhsbsa_datastore_search_sql()] instead.
#' @param distinct Logical. Return only rows that are distinct across the
#'   selected `fields`?
#' @param plain Logical. Controls how a `q` full-text query is parsed (`TRUE`,
#'   the default, treats `q` as plain text). Only relevant to `q`, which this
#'   portal does not apply.
#' @param language Character scalar. The text-search language (e.g. `"english"`).
#' @param limit Integer. Maximum number of rows to return in this request.
#' @param offset Integer. Number of rows to skip, for paging.
#' @param fields Character vector. The fields to return, in order.
#' @param sort Character scalar or vector. Sort clause(s), e.g. `"ITEMS desc"`.
#' @param filters Named list. Field-value pairs to filter on. Accepted for API
#'   completeness but not applied by this portal; use
#'   [nhsbsa_datastore_search_sql()] instead.
#' @param include_total Logical. Include the total match count in the response?
#'   Required for the incomplete-results warning; defaults to the API default
#'   (`TRUE`) when left `NULL`.
#' @inheritParams nhsbsa_package_list
#'
#' @return A tibble with one row per record. With `.return_raw = TRUE`, the
#'   parsed response envelope as a list (including `total` and `fields`).
#'
#' @seealso [nhsbsa_datastore_search_sql()] to filter or aggregate with SQL,
#'   [nhsbsa_download_resource()] to download the whole resource file.
#'
#' @export
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' # Read selected columns, sorted (field names are case-sensitive)
#' nhsbsa_datastore_search(
#'   resource_id = "EPD_202401",
#'   fields = c("PCO_CODE", "BNF_CHEMICAL_SUBSTANCE", "ITEMS"),
#'   sort = "ITEMS desc",
#'   limit = 5
#' )
#'
#' # Distinct values of a column
#' nhsbsa_datastore_search(
#'   resource_id = "EPD_202401",
#'   fields = "PCO_CODE",
#'   distinct = TRUE,
#'   limit = 5
#' )
#'
#' # Page through rows with `limit` and `offset`
#' nhsbsa_datastore_search(resource_id = "EPD_202401", fields = "ITEMS", limit = 5)
#' nhsbsa_datastore_search(
#'   resource_id = "EPD_202401",
#'   fields = "ITEMS",
#'   limit = 5,
#'   offset = 5
#' )
#'
#' # Use the raw envelope to read the total number of rows
#' raw <- nhsbsa_datastore_search(
#'   resource_id = "EPD_202401",
#'   limit = 1,
#'   .return_raw = TRUE
#' )
#' raw$result$total
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
#' # Select specific columns
#' nhsbsa_datastore_search_sql(
#'   resource_id = "EPD_202401",
#'   sql = "SELECT YEAR_MONTH, PCO_CODE, ITEMS FROM `EPD_202401` LIMIT 10"
#' )
#'
#' # Filter by value with a WHERE clause (the reliable way to filter)
#' nhsbsa_datastore_search_sql(
#'   resource_id = "EPD_202401",
#'   sql = "SELECT PCO_CODE, BNF_CHEMICAL_SUBSTANCE, ITEMS
#'          FROM `EPD_202401`
#'          WHERE PCO_CODE = 'W2U3Z'
#'          LIMIT 10"
#' )
#'
#' # Aggregate server-side: total items prescribed per organisation
#' nhsbsa_datastore_search_sql(
#'   resource_id = "EPD_202401",
#'   sql = "SELECT PCO_CODE, SUM(ITEMS) AS items
#'          FROM `EPD_202401`
#'          GROUP BY PCO_CODE
#'          ORDER BY items DESC
#'          LIMIT 10"
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
