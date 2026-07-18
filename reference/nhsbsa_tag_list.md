# List tags

Wraps the CKAN `tag_list` action to list the tags applied to datasets.
These are the same tags shown on the portal website; you can filter
datasets by a tag with
[`nhsbsa_package_search()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_search.md)
(see
[`vignette("nhsbsa")`](https://rmgpanw.github.io/nhsbsa/articles/nhsbsa.md)).

## Usage

``` r
nhsbsa_tag_list(query = NULL, vocabulary_id = NULL, .return_raw = FALSE)
```

## Arguments

- query:

  Character scalar. Restrict the results to tags containing this string.

- vocabulary_id:

  Character scalar. Restrict the results to tags in a particular CKAN
  tag vocabulary.

- .return_raw:

  Logical. If `TRUE`, return the full parsed CKAN response envelope
  instead of the processed result. Defaults to `FALSE`.

## Value

A character vector of tags. With `.return_raw = TRUE`, the parsed
response envelope as a list.

## See also

[`nhsbsa_package_search()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_search.md)
to find datasets by tag.

## Examples

``` r
# All tags
tags <- nhsbsa_tag_list()
length(tags)
#> [1] 1067

# Only tags containing a given string
nhsbsa_tag_list(query = "prescribing")
#>  [1] "English Prescribing Data"   "Prescribing"               
#>  [3] "Hypnotic Prescribing Data"  "prescribing data"          
#>  [5] "Prison Prescribing"         "prescribing"               
#>  [7] "Prescribing data"           "secondary care prescribing"
#>  [9] "Hospital Prescribing"       "Dental prescribing"        
#> [11] "Prescribing Data"          
```
