# Methods for nhsbsa objects

Some `nhsbsa` functions return classed lists with a tailored
[print()](https://rdrr.io/r/base/print.html) method and a
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
method for turning them into a table:

## Usage

``` r
# S3 method for class 'nhsbsa_package'
print(x, ...)

# S3 method for class 'nhsbsa_resource'
print(x, ...)

# S3 method for class 'nhsbsa_package_search'
print(x, ...)

# S3 method for class 'nhsbsa_package'
as_tibble(x, ...)

# S3 method for class 'nhsbsa_package_search'
as_tibble(x, ...)
```

## Arguments

- x:

  An object returned by the relevant `nhsbsa` function.

- ...:

  Ignored, for S3 method consistency.

## Value

The [`print()`](https://rdrr.io/r/base/print.html) methods return `x`
invisibly. The
[`as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
methods return a
[tibble](https://tibble.tidyverse.org/reference/tibble.html).

## Details

- [`nhsbsa_package_show()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_show.md)
  returns an `nhsbsa_package`;
  [`as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
  returns its resources (one row per file). This is the same table as
  [`nhsbsa_list_resources()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_list_resources.md),
  but built from metadata you have already fetched, so it avoids a
  second request (and does not filter by `pattern`).

- [`nhsbsa_resource_show()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_resource_show.md)
  returns an `nhsbsa_resource`.

- [`nhsbsa_package_search()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_search.md)
  returns an `nhsbsa_package_search`;
  [`as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
  returns one row per matching dataset.

These objects are still plain lists, so `$`, `[[` and
[`utils::str()`](https://rdrr.io/r/utils/str.html) work as usual. Pass
`.return_raw = TRUE` to the originating function, or use
[`unclass()`](https://rdrr.io/r/base/class.html), to get the underlying
list without a class.

## Examples

``` r
pkg <- nhsbsa_package_show("english-prescribing-data-epd")
pkg
#> <nhsbsa dataset> "english-prescribing-data-epd"
#> Title: RETIRED - English Prescribing Dataset (EPD)
#> Organisation: Community Prescribing & Dispensing
#> Modified: 2026-03-06
#> Resources: 138
#> Tags: Prescribing, Prescriptions
#> Use `tibble::as_tibble()` for its resources.
tibble::as_tibble(pkg)
#> # A tibble: 138 × 7
#>    name       id                        format created last_modified url   size 
#>    <chr>      <chr>                     <chr>  <chr>   <chr>         <chr> <chr>
#>  1 EPD_201401 8ae6b792-2a0c-4f4b-826c-… CSV    2020-1… NA            http… 6618…
#>  2 EPD_201402 78b8c360-1048-4d30-82fd-… CSV    2020-1… NA            http… 6338…
#>  3 EPD_201403 54584067-3109-4f27-8c48-… CSV    2020-1… NA            http… 6566…
#>  4 EPD_201404 5e25a419-8334-4fb2-bcef-… CSV    2020-1… NA            http… 6501…
#>  5 EPD_201405 5763be28-0dde-430c-bddc-… CSV    2020-1… NA            http… 6623…
#>  6 EPD_201406 32c2c600-2e9d-47e2-9d45-… CSV    2020-1… NA            http… 6566…
#>  7 EPD_201407 9f185ff8-aad4-4555-b1fe-… CSV    2020-1… NA            http… 6716…
#>  8 EPD_201408 3afbd596-a511-4c4f-9a4e-… CSV    2020-1… NA            http… 6429…
#>  9 EPD_201409 d6fa3292-0ba8-468e-ae2d-… CSV    2020-1… NA            http… 6609…
#> 10 EPD_201410 e131e18d-9561-4ba2-98aa-… CSV    2020-1… NA            http… 6696…
#> # ℹ 128 more rows

hits <- nhsbsa_package_search(q = "prescribing", rows = 5)
hits
#> <nhsbsa package search> 661 datasets found
#> Showing the first 5; increase `rows` for more.
#> # A tibble: 5 × 5
#>   name                        title organisation num_resources metadata_modified
#>   <chr>                       <chr> <chr>                <int> <chr>            
#> 1 prescriber-details          Pres… community_p…            48 2026-07-29T11:29…
#> 2 foi-03835                   FOI-… freedom-of-…            41 2026-06-16T12:59…
#> 3 english-prescribing-data-e… RETI… community_p…           138 2026-03-06T12:49…
#> 4 hospital-prescribing-dispe… Hosp… community_p…           114 2026-07-22T08:04…
#> 5 english-prescribing-datase… Engl… community_p…            67 2026-07-22T14:12…
tibble::as_tibble(hits)
#> # A tibble: 5 × 5
#>   name                        title organisation num_resources metadata_modified
#>   <chr>                       <chr> <chr>                <int> <chr>            
#> 1 prescriber-details          Pres… community_p…            48 2026-07-29T11:29…
#> 2 foi-03835                   FOI-… freedom-of-…            41 2026-06-16T12:59…
#> 3 english-prescribing-data-e… RETI… community_p…           138 2026-03-06T12:49…
#> 4 hospital-prescribing-dispe… Hosp… community_p…           114 2026-07-22T08:04…
#> 5 english-prescribing-datase… Engl… community_p…            67 2026-07-22T14:12…
```
