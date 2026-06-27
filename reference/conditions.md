# nhsbsa condition constructors *(internal helpers)*

Internal helpers for constructing structured nhsbsa error, warning and
informational conditions.

## Usage

``` r
nhsbsa_abort(
  message,
  class = NULL,
  ...,
  call = rlang::caller_env(),
  .envir = rlang::caller_env()
)

nhsbsa_warn(message, class = NULL, ..., .envir = rlang::caller_env())

nhsbsa_inform(message, class = NULL, ..., .envir = rlang::caller_env())
```

## Arguments

- message:

  It is formatted via a call to
  [`cli_bullets()`](https://cli.r-lib.org/reference/cli_bullets.html).

- class:

  Optional character vector of additional classes to prepend before the
  nhsbsa base class.

- ...:

  Passed through to the underlying `cli` signalling function.

- call:

  Call environment (only used by `nhsbsa_abort()`).

- .envir:

  Environment to evaluate the glue expressions in.

## Details

These wrap the corresponding `cli` signalling functions
([`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html),
[`cli::cli_warn()`](https://cli.r-lib.org/reference/cli_abort.html),
[`cli::cli_inform()`](https://cli.r-lib.org/reference/cli_abort.html))
and always append an nhsbsa-specific base class (`nhsbsa_error`,
`nhsbsa_warning`, `nhsbsa_message`).

Additional custom classes may be optionally prepended via the `class`
argument, allowing callers to test for and handle specific conditions
programmatically.

The original named `cli` message vector is stored in `cli_message` so a
condition can be re-thrown to reproduce an identical message (see
examples).

## Examples

``` r
# Capture an nhsbsa error condition and inspect it
dataset_id <- "does-not-exist"

named_cli_message_vector <- c(
  x = "Dataset {.val {dataset_id}} was not found.",
  i = "List available datasets with `nhsbsa_package_list()`."
)

e <- tryCatch(
  nhsbsa_abort(
    named_cli_message_vector,
    class = "nhsbsa_dataset_not_found"
  ),
  error = function(cnd) cnd
)

# Inspect the condition class hierarchy
class(e)
#> [1] "simpleError" "error"       "condition"  

# Inspect the stored structured `cli` message
e$cli_message
#> NULL

# Inspect the default formatted condition message
conditionMessage(e)
#> [1] "could not find function \"nhsbsa_abort\""
```
