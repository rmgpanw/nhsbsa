# Search datasets

Wraps the CKAN `package_search` action, a Solr-backed search over
datasets.

## Usage

``` r
nhsbsa_package_search(
  q = NULL,
  fq = NULL,
  sort = NULL,
  rows = NULL,
  start = NULL,
  .return_raw = FALSE
)
```

## Arguments

- q:

  Character scalar. The Solr query string (e.g. `"prescribing"`).
  Defaults to `NULL` (match all).

- fq:

  Character scalar. A Solr filter query.

- sort:

  Character scalar. Sort order, e.g. `"metadata_modified desc"`.

- rows:

  Integer. Maximum number of datasets to return.

- start:

  Integer. Offset into the result set, for paging.

- .return_raw:

  Logical. If `TRUE`, return the full parsed CKAN response envelope
  instead of the processed result. Defaults to `FALSE`.

## Value

A list with the search `count` and matching datasets in `results`, with
class `nhsbsa_package_search` and a
[print()](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa-methods.md)
method;
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
turns the results into one row per dataset. With `.return_raw = TRUE`,
the parsed response envelope as a plain list.

## Examples

``` r
# Free-text search
hits <- nhsbsa_package_search(q = "prescribing", rows = 5)
hits
#> <nhsbsa package search> 640 datasets found
#> Showing the first 5; increase `rows` for more.
#> # A tibble: 5 × 5
#>   name                        title organisation num_resources metadata_modified
#>   <chr>                       <chr> <chr>                <int> <chr>            
#> 1 prescriber-details          Pres… community_p…            47 2026-06-03T08:09…
#> 2 foi-03835                   FOI-… freedom-of-…            41 2026-06-16T12:59…
#> 3 english-prescribing-data-e… RETI… community_p…           138 2026-03-06T12:49…
#> 4 hospital-prescribing-dispe… Hosp… community_p…           113 2026-06-23T09:31…
#> 5 english-prescribing-datase… Engl… community_p…            66 2026-06-22T09:54…
tibble::as_tibble(hits)
#> # A tibble: 5 × 5
#>   name                        title organisation num_resources metadata_modified
#>   <chr>                       <chr> <chr>                <int> <chr>            
#> 1 prescriber-details          Pres… community_p…            47 2026-06-03T08:09…
#> 2 foi-03835                   FOI-… freedom-of-…            41 2026-06-16T12:59…
#> 3 english-prescribing-data-e… RETI… community_p…           138 2026-03-06T12:49…
#> 4 hospital-prescribing-dispe… Hosp… community_p…           113 2026-06-23T09:31…
#> 5 english-prescribing-datase… Engl… community_p…            66 2026-06-22T09:54…

# Filter by tag (as clicking a tag on the website does) and sort the results
nhsbsa_package_search(
  fq = 'tags:"Prescribing"',
  sort = "metadata_modified desc",
  rows = 5
)
#> <nhsbsa package search> 18 datasets found
#> Showing the first 5; increase `rows` for more.
#> # A tibble: 5 × 5
#>   name                        title organisation num_resources metadata_modified
#>   <chr>                       <chr> <chr>                <int> <chr>            
#> 1 prescription-cost-analysis… Pres… community_p…            64 2026-06-22T14:22…
#> 2 english-prescribing-datase… Engl… community_p…            66 2026-06-22T09:54…
#> 3 prescription-cost-analysis… Pres… community_p…            24 2026-06-05T14:01…
#> 4 scottish-dispensed-data     Miss… ad-hoc-rele…            13 2026-04-28T11:00…
#> 5 english-prescribing-data-e… RETI… community_p…           138 2026-03-06T12:49…

# Page through results with `rows` and `start`
nhsbsa_package_search(q = "dental", rows = 10, start = 10)
#> <nhsbsa package search> 302 datasets found
#> Showing the first 10; increase `rows` for more.
#> # A tibble: 10 × 5
#>    name                       title organisation num_resources metadata_modified
#>    <chr>                      <chr> <chr>                <int> <chr>            
#>  1 foi-02768                  FOI-… freedom-of-…             1 2025-05-19T12:44…
#>  2 foi-01670                  FOI-… freedom-of-…             1 2024-02-15T11:42…
#>  3 dental-activity-data-engl… Mont… dental-data              1 2026-05-22T07:23…
#>  4 regional-uda-by-performer  Regi… dental-data              6 2026-04-27T12:09…
#>  5 national-uda-by-performer… Nati… dental-data              6 2026-04-21T15:48…
#>  6 foi-03534                  FOI-… freedom-of-…            10 2026-03-24T16:54…
#>  7 foi-03419                  FOI-… freedom-of-…             0 2025-12-16T09:43…
#>  8 foi-03467                  FOI-… freedom-of-…             0 2026-03-25T10:08…
#>  9 foi-03505                  FOI-… freedom-of-…             0 2026-01-23T13:38…
#> 10 foi-02861                  FOI-… freedom-of-…            24 2025-06-26T08:28…
```
