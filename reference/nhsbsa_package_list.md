# List available datasets

Wraps the CKAN `package_list` action to return the identifiers of every
dataset published on the NHSBSA Open Data Portal.

## Usage

``` r
nhsbsa_package_list(.return_raw = FALSE)
```

## Arguments

- .return_raw:

  Logical. If `TRUE`, return the full parsed CKAN response envelope
  instead of the processed result. Defaults to `FALSE`.

## Value

A character vector of dataset identifiers. With `.return_raw = TRUE`,
the parsed response envelope as a list.

## See also

[`nhsbsa_package_show()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_show.md)
for a dataset's metadata,
[`nhsbsa_package_search()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_search.md)
to search datasets.

## Examples

``` r
datasets <- nhsbsa_package_list()
length(datasets)
#> [1] 2218
head(datasets)
#> [1] "03449"                                           
#> [2] "03500"                                           
#> [3] "baby-loss-certificate-key-performance-indicators"
#> [4] "bnf-code-information-current-year"               
#> [5] "bnf-code-information-historic"                   
#> [6] "bnf-code-information-monthly-changes"            
```
