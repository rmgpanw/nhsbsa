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

A list of dataset metadata. With `.return_raw = TRUE`, the parsed
response envelope as a list.

## See also

[`nhsbsa_list_resources()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_list_resources.md)
for a tidy table of a dataset's resources.

## Examples

``` r
metadata <- nhsbsa_package_show("english-prescribing-data-epd")
metadata$title
#> [1] "RETIRED - English Prescribing Dataset (EPD)"

# The dataset's resources (files / datastore tables)
length(metadata$resources)
#> [1] 138
metadata$resources[[1]]$name
#> [1] "EPD_201401"
```
