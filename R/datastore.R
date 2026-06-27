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
#' @details
#' There are three ways to narrow a datastore query, from simplest to most
#' powerful:
#'
#' * `filters` — exact field/value matching, e.g.
#'   `filters = list(PCO_CODE = "13T00")`. The most reliable option.
#' * `q` — full-text search. As a *per-field* query, pass a named list, e.g.
#'   `q = list(BNF_CHEMICAL_SUBSTANCE = "Paracetamol")`. As a plain string it
#'   searches across all fields, but full-text search is not enabled for every
#'   resource and may return a server error.
#' * [nhsbsa_datastore_search_sql()] — arbitrary read-only SQL, for selecting
#'   columns, expressions, aggregation, joins and sorting.
#'
#' See `vignette("nhsbsa")` for worked examples of each.
#'
#' @param resource_id Character scalar. The resource to query. The NHSBSA
#'   datastore identifies a resource by its *name* (the `name` column of
#'   [nhsbsa_list_resources()]), e.g. `"EPD_201401"`, rather than its `id`.
#' @param q A full-text query. Either a character scalar (searched across all
#'   fields) or a named list for a per-field search, e.g.
#'   `list(BNF_CHEMICAL_SUBSTANCE = "Paracetamol")` (sent to the API as a JSON
#'   object). See Details.
#' @param distinct Logical. Return only rows that are distinct across the
#'   selected `fields`?
#' @param plain Logical. Controls how a `q` full-text query is parsed. When
#'   `TRUE` (the default), `q` is treated as plain text. When `FALSE`, the
#'   datastore's full-text query syntax is enabled, so `q` may contain operators
#'   such as `&` (and), `|` (or) and `:*` (prefix), e.g.
#'   `q = list(BNF_DESCRIPTION = "Para:*")`.
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
#' # Exact field matching with `filters` (field names are case-sensitive)
#' nhsbsa_datastore_search(
#'   resource_id = "EPD_202401",
#'   filters = list(PCO_CODE = "13T00", BNF_CHEMICAL_SUBSTANCE = "0407010H0"),
#'   limit = 10
#' )
#'
#' # Per-field full-text search with `q`
#' nhsbsa_datastore_search(
#'   resource_id = "EPD_202401",
#'   q = list(BNF_CHEMICAL_SUBSTANCE = "0407010H0"),
#'   limit = 10
#' )
#'
#' # Select and order columns, and return only distinct rows
#' nhsbsa_datastore_search(
#'   resource_id = "EPD_202401",
#'   fields = c("PRACTICE_CODE", "ITEMS"),
#'   sort = "ITEMS desc",
#'   distinct = TRUE,
#'   limit = 5
#' )
#'
#' # Page through results with `limit` and `offset`
#' nhsbsa_datastore_search(resource_id = "EPD_202401", limit = 100)
#' nhsbsa_datastore_search(resource_id = "EPD_202401", limit = 100, offset = 100)
#'
#' # Use the raw envelope to read the total number of matching rows
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
