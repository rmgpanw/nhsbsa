# Getting started with nhsbsa

``` r

library(nhsbsa)
```

## The NHSBSA Open Data Portal

The [NHS Business Services Authority (NHSBSA) Open Data
Portal](https://opendata.nhsbsa.net) publishes open datasets about NHS
activity in England — prescribing, dental, pharmaceutical and contractor
data among them. All of it is freely available under the Open Government
Licence.

The portal runs on [CKAN](https://ckan.org), a widely used open-source
data catalogue. CKAN organises data into **datasets** (called
“packages”) which each contain one or more **resources** — the
individual files (usually CSV) that you can download, and, for tabular
resources, query row by row.

`nhsbsa` is a thin, low-level client for this portal. It wraps the CKAN
API and returns plain data for you to work with: tibbles for tabular
results and lists for metadata. It contains no knowledge of any
particular dataset, so you supply the dataset identifiers and interpret
the results yourself. If you are familiar with the CKAN API, the package
will feel familiar too: function names and arguments mirror the API.

## The API and the response envelope

Every request goes to a CKAN *action* under

    https://opendata.nhsbsa.net/api/3/action/<action>

and comes back as a JSON envelope of the form

``` json
{ "success": true, "result": ... }
```

or, on failure,

``` json
{ "success": false, "error": { "message": "..." } }
```

`nhsbsa` handles this envelope for you: it checks the `success` flag,
returns the `result`, and otherwise raises an informative error. If the
portal cannot be reached (for example with no internet connection) it
fails gracefully with a clear message rather than an obscure low-level
error.

The full set of actions is documented in the [CKAN Action API
reference](https://docs.ckan.org/en/latest/api/#action-api-reference),
and the portal will return the documentation for any individual action
it supports, e.g.
`https://opendata.nhsbsa.net/api/3/action/help_show?name=datastore_search_sql`.

## What the package wraps

The package wraps the *useful read subset* of the portal’s actions, in
four small groups (the package reference index is organised the same
way). If you need an action that is not yet wrapped, please [open an
issue](https://github.com/rmgpanw/nhsbsa/issues).

- **Datasets** — discover and inspect datasets (“packages”):
  [`nhsbsa_package_list()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_list.md)
  (every dataset id),
  [`nhsbsa_package_search()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_search.md)
  (search), and
  [`nhsbsa_package_show()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_show.md)
  (one dataset’s metadata, including its resources).
- **Resources** — work with the files in a dataset:
  [`nhsbsa_resource_show()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_resource_show.md)
  (one resource’s metadata), plus two convenience helpers,
  [`nhsbsa_list_resources()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_list_resources.md)
  and
  [`nhsbsa_download_resource()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_download_resource.md).
- **Datastore** — query the rows of a tabular resource without
  downloading it:
  [`nhsbsa_datastore_search()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_datastore_search.md)
  and
  [`nhsbsa_datastore_search_sql()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_datastore_search_sql.md).
- **Catalogue** — list the portal’s taxonomy:
  [`nhsbsa_organization_list()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_organization_list.md),
  [`nhsbsa_group_list()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_group_list.md)
  and
  [`nhsbsa_tag_list()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_tag_list.md).

Almost every function maps one-to-one onto a CKAN action of the same
name. The two exceptions are the resource helpers, which combine an
action with a little extra work and so are not pure wrappers:

- [`nhsbsa_list_resources()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_list_resources.md)
  calls
  [`nhsbsa_package_show()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_show.md)
  and reshapes its nested `resources` into a tibble — one row per file,
  including each file’s download `url`.
- [`nhsbsa_download_resource()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_download_resource.md)
  resolves a single resource (again via
  [`nhsbsa_package_show()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_show.md))
  and then streams that resource’s file `url` to disk. The download
  itself is an ordinary HTTP request, not a CKAN action.

([`nhsbsa_group_list()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_group_list.md)
is included for completeness; this portal currently defines no groups
and so returns an empty vector — it organises data by *organisation* and
*tags* instead.) Most read-only functions also accept
`.return_raw = TRUE`, which returns the full parsed response envelope
instead of the processed result — useful when you need fields the helper
does not surface, such as a datastore query’s `total`.

## From the portal website to the API

It helps to think of the package as a programmatic version of the
[portal website](https://opendata.nhsbsa.net). The things you click
there map onto API calls:

- **Browsing all datasets** is
  [`nhsbsa_package_list()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_list.md)
  (identifiers) or
  [`nhsbsa_package_search()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_search.md)
  (richer records, with searching and paging).

- **Clicking a tag**, say **\#Prescribing**, takes the website to
  `/dataset/?tags=Prescribing`. A *filter query* on the `tags` field
  returns the datasets carrying that tag:

  ``` r

  nhsbsa_package_search(fq = 'tags:"Prescribing"')$count
  #> [1] 18
  ```

  This returns *more* datasets than the website shows for the same tag,
  because the website’s dataset view hides the Freedom of Information
  disclosure log by default. To match what the website displays, exclude
  that organisation as well. The result is a list, whose `results`
  element holds one record per dataset; pull out the `title` of each to
  compare against the website:

  ``` r

  hits <- nhsbsa_package_search(
    fq = 'tags:"Prescribing" -organization:freedom-of-information-disclosure-log'
  )
  hits$count
  #> [1] 5
  purrr::map_chr(hits$results, "title")
  #> [1] "Prescription Cost Analysis (PCA) Monthly Administrative Data"
  #> [2] "English Prescribing Dataset (EPD) with SNOMED Code"          
  #> [3] "Prescription Cost Analysis (PCA) Annual Statistics"          
  #> [4] "Missing Scottish Dispensing Data from June 2023 to June 2024"
  #> [5] "RETIRED - English Prescribing Dataset (EPD)"
  ```

  Tags are case-sensitive; list them with
  [`nhsbsa_tag_list()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_tag_list.md),
  and the organisations you can filter on with
  [`nhsbsa_organization_list()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_organization_list.md).

- **Opening a dataset’s page** (e.g.
  `/dataset/english-prescribing-data-epd`) corresponds to
  `nhsbsa_package_show("english-prescribing-data-epd")`, whose
  `resources` element lists the files shown on that page.
  [`nhsbsa_list_resources()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_list_resources.md)
  tidies those resources into a tibble.

- **The “Download” button** on a resource fetches the file that
  [`nhsbsa_download_resource()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_download_resource.md)
  streams to disk; **the data preview / “Data API”** for a resource is
  backed by the datastore that
  [`nhsbsa_datastore_search()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_datastore_search.md)
  queries.

## A worked example

### Find a dataset

[`nhsbsa_package_list()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_list.md)
returns the identifier of every dataset; use it when you want to scan or
search the ids yourself:

``` r

datasets <- nhsbsa_package_list()
length(datasets)
#> [1] 2169
head(datasets)
#> [1] "03449"                                           
#> [2] "03500"                                           
#> [3] "25521"                                           
#> [4] "baby-loss-certificate-key-performance-indicators"
#> [5] "bnf-code-information-current-year"               
#> [6] "bnf-code-information-historic"
```

When you do not already know the id, search for one with
[`nhsbsa_package_search()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_search.md).
It returns a list with a match `count` and the matching dataset records
in `results`:

``` r

hits <- nhsbsa_package_search(q = "prescribing", rows = 5)
hits$count
#> [1] 639
vapply(hits$results, function(x) x$name, character(1))
#> [1] "prescriber-details"                              
#> [2] "foi-03835"                                       
#> [3] "english-prescribing-data-epd"                    
#> [4] "hospital-prescribing-dispensed-in-the-community" 
#> [5] "english-prescribing-dataset-epd-with-snomed-code"
```

### Inspect a dataset’s resources

A dataset is a container of *resources* (files).
[`nhsbsa_list_resources()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_list_resources.md)
lists them as a tibble, including the download `url` of each:

``` r

resources <- nhsbsa_list_resources("english-prescribing-data-epd")
nrow(resources)
#> [1] 138
head(resources[, c("name", "format", "url")])
#> # A tibble: 6 × 3
#>   name       format url                                                         
#>   <chr>      <chr>  <chr>                                                       
#> 1 EPD_201401 CSV    https://opendata.nhsbsa.net/dataset/65050ec0-5abd-48ce-989d…
#> 2 EPD_201402 CSV    https://opendata.nhsbsa.net/dataset/65050ec0-5abd-48ce-989d…
#> 3 EPD_201403 CSV    https://opendata.nhsbsa.net/dataset/65050ec0-5abd-48ce-989d…
#> 4 EPD_201404 CSV    https://opendata.nhsbsa.net/dataset/65050ec0-5abd-48ce-989d…
#> 5 EPD_201405 CSV    https://opendata.nhsbsa.net/dataset/65050ec0-5abd-48ce-989d…
#> 6 EPD_201406 CSV    https://opendata.nhsbsa.net/dataset/65050ec0-5abd-48ce-989d…
```

Filter by a pattern matched against the resource name:

``` r

nhsbsa_list_resources("english-prescribing-data-epd", pattern = "202401")[,
  c("name", "id", "last_modified")
]
#> # A tibble: 1 × 3
#>   name       id                                   last_modified             
#>   <chr>      <chr>                                <chr>                     
#> 1 EPD_202401 fe7c75f9-7ac6-4d03-8941-74f596db4a5a 2024-03-19T09:39:16.950431
```

[`nhsbsa_resource_show()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_resource_show.md)
returns the full metadata for a single resource (by its `id`), if you
need more detail than the table above:

``` r

resource <- nhsbsa_resource_show(resources$id[[1]])
resource$name
#> [1] "EPD_201401"
resource$format
#> [1] "CSV"
```

### Download a resource file

Identify a single resource — by `resource_id`, or by a `pattern` that
matches exactly one resource name — and stream its file to disk. The
file is saved into `directory` (the current working directory by
default) under its own name; here we use a (smaller) resource from the
BNF code dataset and save to a temporary directory:

``` r

bnf <- nhsbsa_list_resources("bnf-code-information-current-year")
path <- nhsbsa_download_resource(
  "bnf-code-information-current-year",
  resource_id = bnf$id[[1]],
  directory = tempdir()
)
#> ℹ Downloading "BNF_CODE_CURRENT_202503_VERSION_88" to
#>   /tmp/RtmpqfHG8C/bnf_code_current_202503_version_88.csv.
basename(path)
#> [1] "bnf_code_current_202503_version_88.csv"
```

### Query rows without downloading the whole file

Not every resource can be queried row by row. The datastore is a
separate, queryable copy of the **tabular** resources (CSVs);
non-tabular files such as PDFs can only be downloaded. Where a resource
is in the datastore, you can query it directly.

Two things to know about this portal specifically:

- The datastore identifies a resource by its **name**
  (e.g. `"EPD_202401"`, shown in the `name` column of
  [`nhsbsa_list_resources()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_list_resources.md)),
  not by its `id`.
- The `datastore_active` metadata flag is unreliable here (it is often
  `FALSE` even for resources that *are* queryable), so rather than
  trusting it, simply try the query — CSV resources are generally
  queryable by name, and a non-tabular resource returns an error.

## Ways to query datastore data

There are two functions, and on this portal they have a clear division
of labour: use
[`nhsbsa_datastore_search()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_datastore_search.md)
to **read** rows, and
[`nhsbsa_datastore_search_sql()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_datastore_search_sql.md)
to **filter or aggregate** them.

### Reading rows with `nhsbsa_datastore_search()`

[`nhsbsa_datastore_search()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_datastore_search.md)
returns rows from a resource. You can choose and order columns with
`fields`, sort with `sort`, and page with `limit`/`offset`. Field names
are case-sensitive and must match the resource’s columns exactly (for
the EPD they are upper case, e.g. `PCO_CODE`):

``` r

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
```

The datastore returns at most one page of rows per request. When more
rows exist than were returned,
[`nhsbsa_datastore_search()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_datastore_search.md)
warns you and explains how to page through the rest by increasing
`offset`:

``` r

nhsbsa_datastore_search(
  resource_id = "EPD_202401",
  fields = c("PCO_CODE", "ITEMS"),
  limit = 5,
  offset = 5
)
#> Warning: ! Retrieved 5 of 18080573 matching rows; 18080563 not returned.
#> ℹ Fetch the next page with `offset = 10` (reusing your other arguments),
#>   increasing `offset` until all rows are retrieved.
#> ℹ Raising `limit` returns more rows per request, up to the server-side maximum.
#> # A tibble: 5 × 2
#>   PCO_CODE ITEMS
#>   <chr>    <int>
#> 1 -            1
#> 2 -            1
#> 3 -            1
#> 4 -            1
#> 5 -            1
```

CKAN’s `datastore_search` also defines `filters` (exact field matching)
and `q` (full-text search) parameters, and
[`nhsbsa_datastore_search()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_datastore_search.md)
exposes them for completeness. **Be aware that this portal’s datastore
does not apply them** — they return no matching rows — so to filter by
value, use SQL instead.

### Filtering and aggregating with SQL

[`nhsbsa_datastore_search_sql()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_datastore_search_sql.md)
runs a read-only SQL query, which is the reliable way to filter, compute
expressions, aggregate and sort on this portal. The portal requires the
`resource_id` alongside the query, and you reference the same resource
name in the `FROM` clause:

``` r

# Filter to one organisation
nhsbsa_datastore_search_sql(
  resource_id = "EPD_202401",
  sql = "SELECT PCO_CODE, BNF_CHEMICAL_SUBSTANCE, ITEMS
         FROM `EPD_202401`
         WHERE PCO_CODE = 'W2U3Z'
         LIMIT 5"
)
#> # A tibble: 5 × 3
#>   PCO_CODE BNF_CHEMICAL_SUBSTANCE ITEMS
#>   <chr>    <chr>                  <int>
#> 1 W2U3Z    0913011N0                  4
#> 2 W2U3Z    0703021Q0                  1
#> 3 W2U3Z    0408010H0                  4
#> 4 W2U3Z    0601022B0                  1
#> 5 W2U3Z    0906040G0                  1
```

``` r

# Aggregate: total items prescribed per organisation
nhsbsa_datastore_search_sql(
  resource_id = "EPD_202401",
  sql = "SELECT PCO_CODE, SUM(ITEMS) AS items
         FROM `EPD_202401`
         GROUP BY PCO_CODE
         ORDER BY items DESC
         LIMIT 5"
)
#> # A tibble: 5 × 2
#>   PCO_CODE   items
#>   <chr>      <int>
#> 1 91Q00    3151968
#> 2 W2U3Z    3129964
#> 3 A3A8R    3124609
#> 4 D9Y0V    2697474
#> 5 15N00    2413359
```

The SQL string is sent to the API verbatim, so you are responsible for
paging (via `LIMIT`/`OFFSET`) and for quoting identifiers correctly.
