# List dataset groups

Wraps the CKAN `group_list` action to list the groups (thematic
collections) that datasets can belong to.

## Usage

``` r
nhsbsa_group_list(all_fields = NULL, .return_raw = FALSE)
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

A character vector of group names. If `all_fields = TRUE`, a list of
group records. With `.return_raw = TRUE`, the parsed response envelope
as a list.

## See also

[`nhsbsa_organization_list()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_organization_list.md),
[`nhsbsa_tag_list()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_tag_list.md).

## Examples

``` r
nhsbsa_group_list()
#> character(0)
```
