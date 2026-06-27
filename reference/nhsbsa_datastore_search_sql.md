# Query a resource with SQL

Wraps the CKAN `datastore_search_sql` action, which runs a read-only SQL
query against the datastore. The `sql` string is sent to the API
verbatim; paging is the caller's responsibility (via `LIMIT`/`OFFSET` in
the query).

## Usage

``` r
nhsbsa_datastore_search_sql(resource_id, sql, .return_raw = FALSE)
```

## Arguments

- resource_id:

  Character scalar. The resource the query targets. The NHSBSA datastore
  requires this alongside `sql`, and identifies a resource by its *name*
  (the `name` column of
  [`nhsbsa_list_resources()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_list_resources.md)),
  e.g. `"EPD_201401"`. Reference the same name in the query's `FROM`
  clause.

- sql:

  Character scalar. A single read-only SQL `SELECT` statement, e.g.
  `` 'SELECT * FROM `EPD_201401` LIMIT 10' ``.

- .return_raw:

  Logical. If `TRUE`, return the full parsed CKAN response envelope
  instead of the processed result. Defaults to `FALSE`.

## Value

A tibble with one row per record returned by the query. With
`.return_raw = TRUE`, the parsed response envelope as a list.

## See also

[`nhsbsa_datastore_search()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_datastore_search.md)
for a parameterised search.

## Examples

``` r
# Select specific columns
nhsbsa_datastore_search_sql(
  resource_id = "EPD_202401",
  sql = "SELECT YEAR_MONTH, PCO_CODE, ITEMS FROM `EPD_202401` LIMIT 10"
)
#> # A tibble: 10 × 3
#>    YEAR_MONTH PCO_CODE ITEMS
#>         <int> <chr>    <int>
#>  1     202401 -            1
#>  2     202401 -            1
#>  3     202401 -            5
#>  4     202401 -            1
#>  5     202401 -            2
#>  6     202401 -            1
#>  7     202401 -            1
#>  8     202401 -            1
#>  9     202401 -            4
#> 10     202401 -            1

# Filter by value with a WHERE clause (the reliable way to filter)
nhsbsa_datastore_search_sql(
  resource_id = "EPD_202401",
  sql = "SELECT PCO_CODE, BNF_CHEMICAL_SUBSTANCE, ITEMS
         FROM `EPD_202401`
         WHERE PCO_CODE = 'W2U3Z'
         LIMIT 10"
)
#> # A tibble: 10 × 3
#>    PCO_CODE BNF_CHEMICAL_SUBSTANCE ITEMS
#>    <chr>    <chr>                  <int>
#>  1 W2U3Z    0202020D0                  1
#>  2 W2U3Z    0403030E0                 12
#>  3 W2U3Z    0602010V0                 13
#>  4 W2U3Z    2130                       1
#>  5 W2U3Z    1304000H0                  1
#>  6 W2U3Z    0704020N0                  1
#>  7 W2U3Z    0208020V0                  1
#>  8 W2U3Z    1304000F0                  1
#>  9 W2U3Z    0913011V0                  1
#> 10 W2U3Z    1003020AF                  3

# Aggregate server-side: total items prescribed per organisation
nhsbsa_datastore_search_sql(
  resource_id = "EPD_202401",
  sql = "SELECT PCO_CODE, SUM(ITEMS) AS items
         FROM `EPD_202401`
         GROUP BY PCO_CODE
         ORDER BY items DESC
         LIMIT 10"
)
#> # A tibble: 10 × 2
#>    PCO_CODE   items
#>    <chr>      <int>
#>  1 91Q00    3151968
#>  2 W2U3Z    3129964
#>  3 A3A8R    3124609
#>  4 D9Y0V    2697474
#>  5 15N00    2413359
#>  6 26A00    2276127
#>  7 D2P2L    2273324
#>  8 72Q00    2256407
#>  9 15E00    2248968
#> 10 36L00    2116336
```
