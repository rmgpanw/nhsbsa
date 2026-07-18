# Search a resource's rows

Wraps the CKAN `datastore_search` action to read the rows of a datastore
resource. One argument is provided for each documented API parameter.

## Usage

``` r
nhsbsa_datastore_search(
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
)
```

## Arguments

- resource_id:

  Character scalar. The resource to query. The NHSBSA datastore
  identifies a resource by its *name* (the `name` column of
  [`nhsbsa_list_resources()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_list_resources.md)),
  e.g. `"EPD_201401"`, rather than its `id`.

- q:

  A full-text query (a character scalar, or a named list for a per-field
  search). Accepted for API completeness but not applied by this portal;
  use
  [`nhsbsa_datastore_search_sql()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_datastore_search_sql.md)
  instead.

- distinct:

  Logical. Return only rows that are distinct across the selected
  `fields`?

- plain:

  Logical. Controls how a `q` full-text query is parsed (`TRUE`, the
  default, treats `q` as plain text). Only relevant to `q`, which this
  portal does not apply.

- language:

  Character scalar. The text-search language (e.g. `"english"`).

- limit:

  Integer. Maximum number of rows to return in this request.

- offset:

  Integer. Number of rows to skip, for paging.

- fields:

  Character vector. The fields to return, in order.

- sort:

  Character scalar or vector. Sort clause(s), e.g. `"ITEMS desc"`.

- filters:

  Named list. Field-value pairs to filter on. Accepted for API
  completeness but not applied by this portal; use
  [`nhsbsa_datastore_search_sql()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_datastore_search_sql.md)
  instead.

- include_total:

  Logical. Include the total match count in the response? Required for
  the incomplete-results warning; defaults to the API default (`TRUE`)
  when left `NULL`.

- .return_raw:

  Logical. If `TRUE`, return the full parsed CKAN response envelope
  instead of the processed result. Defaults to `FALSE`.

## Value

A tibble with one row per record. With `.return_raw = TRUE`, the parsed
response envelope as a list (including `total` and `fields`).

## Details

Use this function to *read* rows — choosing and ordering columns with
`fields`, sorting with `sort`, and paging with `limit`/`offset`. To
*filter* by value or to aggregate, use
[`nhsbsa_datastore_search_sql()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_datastore_search_sql.md)
instead (see Details).

The CKAN datastore returns at most one page of rows per request (the
server enforces a maximum `limit`). When more rows exist than are
returned, a warning of class `nhsbsa_incomplete_results` is signalled
describing how to page through the rest by increasing `offset`.

CKAN's `datastore_search` defines `filters` (exact field matching) and
`q` (full-text search) parameters, which this function exposes for API
completeness. **This portal's datastore does not apply them** — a query
using `filters` or `q` returns no matching rows — so to filter by value,
aggregate or compute expressions, use
[`nhsbsa_datastore_search_sql()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_datastore_search_sql.md)
with a SQL `WHERE`/`GROUP BY` clause. See
[`vignette("nhsbsa")`](https://rmgpanw.github.io/nhsbsa/articles/nhsbsa.md)
for worked examples.

## See also

[`nhsbsa_datastore_search_sql()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_datastore_search_sql.md)
to filter or aggregate with SQL,
[`nhsbsa_download_resource()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_download_resource.md)
to download the whole resource file.

## Examples

``` r
# Read selected columns, sorted (field names are case-sensitive)
nhsbsa_datastore_search(
  resource_id = "EPD_202401",
  fields = c("PCO_CODE", "BNF_CHEMICAL_SUBSTANCE", "ITEMS"),
  sort = "ITEMS desc",
  limit = 5
)
#> Warning: ! Retrieved 5 of 18080573 matching rows; 18080568 not returned.
#> ℹ Fetch the next page with `offset = 5` (reusing your other arguments),
#>   increasing `offset` until all rows are retrieved.
#> ℹ Raising `limit` returns more rows per request, up to the server-side maximum.
#> # A tibble: 5 × 3
#>   PCO_CODE BNF_CHEMICAL_SUBSTANCE ITEMS
#>   <chr>    <chr>                  <int>
#> 1 11J00    1404000H0               3584
#> 2 06H00    0212000B0               3571
#> 3 02Y00    0212000B0               3469
#> 4 12F00    1404000H0               3160
#> 5 11M00    1404000H0               3038

# Distinct values of a column
nhsbsa_datastore_search(
  resource_id = "EPD_202401",
  fields = "PCO_CODE",
  distinct = TRUE,
  limit = 5
)
#> Warning: ! Retrieved 5 of 18080573 matching rows; 18080568 not returned.
#> ℹ Fetch the next page with `offset = 5` (reusing your other arguments),
#>   increasing `offset` until all rows are retrieved.
#> ℹ Raising `limit` returns more rows per request, up to the server-side maximum.
#> # A tibble: 5 × 1
#>   PCO_CODE
#>   <chr>   
#> 1 -       
#> 2 DT300   
#> 3 15E00   
#> 4 11J00   
#> 5 15C00   

# Page through rows with `limit` and `offset`
nhsbsa_datastore_search(resource_id = "EPD_202401", fields = "ITEMS", limit = 5)
#> Warning: ! Retrieved 5 of 18080573 matching rows; 18080568 not returned.
#> ℹ Fetch the next page with `offset = 5` (reusing your other arguments),
#>   increasing `offset` until all rows are retrieved.
#> ℹ Raising `limit` returns more rows per request, up to the server-side maximum.
#> # A tibble: 5 × 1
#>   ITEMS
#>   <int>
#> 1     1
#> 2     1
#> 3     3
#> 4     1
#> 5     2
nhsbsa_datastore_search(
  resource_id = "EPD_202401",
  fields = "ITEMS",
  limit = 5,
  offset = 5
)
#> Warning: ! Retrieved 5 of 18080573 matching rows; 18080563 not returned.
#> ℹ Fetch the next page with `offset = 10` (reusing your other arguments),
#>   increasing `offset` until all rows are retrieved.
#> ℹ Raising `limit` returns more rows per request, up to the server-side maximum.
#> # A tibble: 5 × 1
#>   ITEMS
#>   <int>
#> 1    11
#> 2     3
#> 3     1
#> 4     1
#> 5     1

# Use the raw envelope to read the total number of rows
raw <- nhsbsa_datastore_search(
  resource_id = "EPD_202401",
  limit = 1,
  .return_raw = TRUE
)
raw$result$total
#> [1] 18080573
```
