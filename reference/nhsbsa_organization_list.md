# List publishing organisations

Wraps the CKAN `organization_list` action to list the organisations that
publish datasets on the portal.

## Usage

``` r
nhsbsa_organization_list(all_fields = NULL, .return_raw = FALSE)
```

## Arguments

- all_fields:

  Logical. If `TRUE`, return a richer record for each organisation
  rather than just its name. Defaults to the API default (`FALSE`) when
  left `NULL`.

- .return_raw:

  Logical. If `TRUE`, return the full parsed CKAN response envelope
  instead of the processed result. Defaults to `FALSE`.

## Value

A character vector of organisation names. If `all_fields = TRUE`, a list
of organisation records. With `.return_raw = TRUE`, the parsed response
envelope as a list.

## See also

[`nhsbsa_group_list()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_group_list.md),
[`nhsbsa_tag_list()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_tag_list.md).

## Examples

``` r
# Organisation names
nhsbsa_organization_list()
#> [1] "ad-hoc-releases"                      
#> [2] "community_prescribing_dispensing"     
#> [3] "dental-data"                          
#> [4] "digital-service-performance-and-usage"
#> [5] "dispensing-contractors"               
#> [6] "freedom-of-information-disclosure-log"
#> [7] "hospital-provider-medicines"          
#> [8] "nhsbsa-business-intelligence"         
#> [9] "public-services-schemes-and-payments" 

# Richer records (title, description, dataset count, ...) for each organisation
orgs <- nhsbsa_organization_list(all_fields = TRUE)
orgs[[1]]$title
#> [1] "Ad hoc releases"
```
