# Show a resource's metadata

Wraps the CKAN `resource_show` action to return the metadata for a
single resource (a file or datastore table).

## Usage

``` r
nhsbsa_resource_show(id, .return_raw = FALSE)
```

## Arguments

- id:

  Character scalar. The resource identifier.

- .return_raw:

  Logical. If `TRUE`, return the full parsed CKAN response envelope
  instead of the processed result. Defaults to `FALSE`.

## Value

A list of resource metadata, with class `nhsbsa_resource` and a
[print()](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa-methods.md)
method. With `.return_raw = TRUE`, the parsed response envelope as a
plain list.

## Examples

``` r
resources <- nhsbsa_list_resources("english-prescribing-data-epd")
meta <- nhsbsa_resource_show(resources$id[[1]])
meta$name
#> [1] "EPD_201401"
meta$datastore_active
#> [1] FALSE
```
