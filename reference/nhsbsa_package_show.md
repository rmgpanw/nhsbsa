# Show a dataset's metadata

Wraps the CKAN `package_show` action to return the full metadata for a
single dataset, including its list of resources (downloadable files and
datastore tables).

## Usage

``` r
nhsbsa_package_show(id, .return_raw = FALSE)
```

## Arguments

- id:

  Character scalar. The dataset identifier or name, as returned by
  [`nhsbsa_package_list()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_list.md).

- .return_raw:

  Logical. If `TRUE`, return the full parsed CKAN response envelope
  instead of the processed result. Defaults to `FALSE`.

## Value

A list of dataset metadata, with class `nhsbsa_package` and a
[print()](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa-methods.md)
method;
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
turns it into a table of its resources. With `.return_raw = TRUE`, the
parsed response envelope as a plain list.

## See also

[`nhsbsa_list_resources()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_list_resources.md)
for a tidy table of a dataset's resources.

## Examples

``` r
metadata <- nhsbsa_package_show("english-prescribing-data-epd")
metadata
#> <nhsbsa dataset> "english-prescribing-data-epd"
#> Title: RETIRED - English Prescribing Dataset (EPD)
#> Organisation: Community Prescribing & Dispensing
#> Modified: 2026-03-06
#> Resources: 138
#> Tags: Prescribing, Prescriptions
#> Use `tibble::as_tibble()` for its resources.
metadata$title
#> [1] "RETIRED - English Prescribing Dataset (EPD)"

# The dataset's resources as a tibble
tibble::as_tibble(metadata)
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
```
