# Download a resource file

Resolves a single resource within a dataset and streams its file to
disk. This is the file-download counterpart to the datastore row-query
functions
([`nhsbsa_datastore_search()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_datastore_search.md)
and friends): it fetches the whole resource file (e.g. a CSV) rather
than running a query.

## Usage

``` r
nhsbsa_download_resource(
  dataset_id,
  resource_id = NULL,
  pattern = NULL,
  directory = ".",
  overwrite = FALSE,
  quiet = FALSE
)
```

## Arguments

- dataset_id:

  Character scalar. The dataset identifier, as returned by
  [`nhsbsa_package_list()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_list.md).

- resource_id:

  Character scalar. The identifier of the resource to download. Takes
  precedence over `pattern`.

- pattern:

  Character scalar. A regular expression matched (case-insensitively)
  against resource names to select a single resource.

- directory:

  Character scalar. The directory to download into. Defaults to the
  current working directory. The directory must already exist.

- overwrite:

  Logical. Overwrite the file if it already exists in `directory`?
  Defaults to `FALSE`, in which case the existing file is left untouched
  and its path returned.

- quiet:

  Logical. Suppress informational messages? Defaults to `FALSE`.

## Value

The path to the downloaded file, invisibly.

## Details

Exactly one resource must be identified. Supply either `resource_id` or
a `pattern` that matches a single resource name; if neither is given and
the dataset has more than one resource, an error is raised.

The file is saved into `directory` under its own name (the file name
from the resource's download URL, e.g.
`bnf_code_current_202503_version_88.csv`).

## See also

[`nhsbsa_list_resources()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_list_resources.md)
to discover resources.

## Examples

``` r
resources <- nhsbsa_list_resources("bnf-code-information-current-year")

# Identify a resource by a pattern matching a single resource name
path <- nhsbsa_download_resource(
  "bnf-code-information-current-year",
  pattern = resources$name[[1]],
  directory = tempdir()
)
#> ℹ Downloading "BNF_CODE_CURRENT_202503_VERSION_88" to
#>   /tmp/RtmpPehOCP/bnf_code_current_202503_version_88.csv.
path
#> [1] "/tmp/RtmpPehOCP/bnf_code_current_202503_version_88.csv"

# ...or by its exact id. An existing file is not re-downloaded unless
# `overwrite = TRUE`, so this call short-circuits and returns the path.
nhsbsa_download_resource(
  "bnf-code-information-current-year",
  resource_id = resources$id[[1]],
  directory = tempdir()
)
#> ℹ /tmp/RtmpPehOCP/bnf_code_current_202503_version_88.csv already exists;
#>   skipping download.
#> ℹ Set `overwrite = TRUE` to download it again.
```
