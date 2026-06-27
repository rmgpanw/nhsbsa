# List a dataset's resources as a tibble

A convenience wrapper around
[`nhsbsa_package_show()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_show.md)
that returns a dataset's resources as a tibble, optionally filtered by a
pattern matched against the resource name. This is the most direct way
to discover the resources (and their download URLs) available for a
dataset.

## Usage

``` r
nhsbsa_list_resources(dataset_id, pattern = NULL)
```

## Arguments

- dataset_id:

  Character scalar. The dataset identifier, as returned by
  [`nhsbsa_package_list()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_list.md).

- pattern:

  Character scalar. An optional regular expression; only resources whose
  `name` matches (case-insensitively) are returned.

## Value

A tibble with one row per resource and columns `name`, `id`, `format`,
`created`, `last_modified`, `url` and `size`.

## See also

[`nhsbsa_download_resource()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_download_resource.md)
to download a resource file.

## Examples

``` r
# All resources for a dataset
nhsbsa_list_resources("english-prescribing-data-epd")
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

# Only resources whose name matches a pattern
nhsbsa_list_resources("english-prescribing-data-epd", pattern = "202401")
#> # A tibble: 1 × 7
#>   name       id                         format created last_modified url   size 
#>   <chr>      <chr>                      <chr>  <chr>   <chr>         <chr> <chr>
#> 1 EPD_202401 fe7c75f9-7ac6-4d03-8941-7… CSV    2024-0… 2024-03-19T0… http… 6965…
```
