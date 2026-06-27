# Perform a request against a CKAN action endpoint *(internal)*

Builds the request for `action`, collecting query parameters from the
calling endpoint function's arguments, performs it with retry/backoff
and returns the parsed `result` element of the CKAN response envelope.

## Usage

``` r
nhsbsa_query(action, call = rlang::caller_env())
```

## Arguments

- action:

  Character scalar. The CKAN action to call (e.g. `"package_show"`),
  appended to the base API path.

- call:

  Environment to report in error messages.

## Value

The `result` element of the CKAN response, or — when the calling
function was invoked with `.return_raw = TRUE` — the full parsed
response envelope.
