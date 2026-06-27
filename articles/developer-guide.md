# Developer guide

This guide is for people extending or maintaining `nhsbsa`. It explains
how the package is put together and how to add new functionality
consistently. For using the package, see
[`vignette("nhsbsa")`](https://rmgpanw.github.io/nhsbsa/articles/nhsbsa.md)
instead.

## Design goals

`nhsbsa` is a **low-level, general-purpose client** for the NHS Business
Services Authority Open Data Portal, a [CKAN](https://ckan.org)
catalogue. Two principles shape every decision:

1.  **Purity.** There is one exported function per CKAN action, named
    after it, with an argument for every documented API parameter. A
    user who knows the CKAN API should not have to learn anything new.
    The only deliberate exceptions are the two convenience helpers
    [`nhsbsa_list_resources()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_list_resources.md)
    and
    [`nhsbsa_download_resource()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_download_resource.md).
    They are “exceptions” because, unlike every other exported function,
    neither corresponds to a single CKAN action:
    [`nhsbsa_list_resources()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_list_resources.md)
    calls
    [`nhsbsa_package_show()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_show.md)
    and reshapes the nested `resources` list into a tibble, and
    [`nhsbsa_download_resource()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_download_resource.md)
    resolves a resource (via
    [`nhsbsa_package_show()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_package_show.md))
    and then streams its file `url` — an ordinary HTTP download that is
    not part of the `/action/` API at all. They earn their place because
    together they are the operations a caller most often needs.
2.  **No domain knowledge.** The package knows nothing about specific
    datasets (BNF, prescribing, dental, and so on). It returns plain
    data — tibbles for tabular results, lists for metadata — and leaves
    interpretation to the caller. Dataset-specific logic belongs in a
    separate package that depends on this one.

## Architecture

The package is a thin shell around a single request layer.

    endpoint functions  ->  nhsbsa_query()  ->  httr2  ->  CKAN
       (R/package.R,         (R/core.R)
        resources.R,
        datastore.R,
        catalogue.R)

### The core request layer (`R/core.R`)

`nhsbsa_query(action)` does all the work:

- It inspects the **calling endpoint function** with
  [`rlang::caller_fn()`](https://rlang.r-lib.org/reference/stack.html)
  and
  [`rlang::fn_fmls_names()`](https://rlang.r-lib.org/reference/fn_fmls.html),
  reads those argument values from the caller’s environment, and turns
  them into query parameters. Arguments prefixed with `.` (such as
  `.return_raw`) are reserved for client behaviour and never sent to the
  API.
- Values are coerced for CKAN by `nhsbsa_format_query_value()`: `NULL`s
  are dropped, logicals become `"true"`/`"false"`, multi-element vectors
  are joined with commas, and lists (such as `filters`) are encoded as
  JSON.
- The request is performed with retry/backoff. `nhsbsa_perform()`
  translates transport failures into a graceful `nhsbsa_offline` error
  and HTTP errors into `nhsbsa_api_error` (plus a status-specific
  subclass such as `nhsbsa_http_404`).
- The CKAN envelope is validated: on `success = FALSE` it raises an
  `nhsbsa_api_error`; otherwise it returns the `result` element (or,
  when the caller passed `.return_raw = TRUE`, the whole parsed
  envelope).

Because parameters are read from the function signature, an endpoint
wrapper is usually a single line — see below.

### Conditions (`R/conditions.R`)

All messages, warnings and errors go through
[`nhsbsa_abort()`](https://rmgpanw.github.io/nhsbsa/reference/conditions.md),
[`nhsbsa_warn()`](https://rmgpanw.github.io/nhsbsa/reference/conditions.md)
and
[`nhsbsa_inform()`](https://rmgpanw.github.io/nhsbsa/reference/conditions.md).
These wrap the corresponding `cli` functions, always append a base class
(`nhsbsa_error` / `nhsbsa_warning` / `nhsbsa_message`), and accept an
optional `class` to prepend a more specific subclass. Give a condition a
specific subclass whenever a caller might reasonably want to catch it,
e.g.

``` r

nhsbsa_abort(
  c("x" = "No resource matched."),
  class = "nhsbsa_resource_not_found"
)
```

Do not call
[`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html) (or
any other package’s error helpers) directly.

### Return-type conventions

- Catalogue/metadata actions return a **list** (`package_show`,
  `package_search`, `resource_show`).
- Listing actions return a **character vector** (`package_list`,
  `organization_list`, `group_list`, `tag_list`).
- Row queries return a **tibble** (`datastore_search`,
  `datastore_search_sql`, `list_resources`).
- [`nhsbsa_download_resource()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_download_resource.md)
  returns the destination path invisibly.
- Any read-only function called with `.return_raw = TRUE` returns the
  parsed envelope as a list.

## Which actions are wrapped

The portal exposes the standard CKAN read API (you can confirm what a
given instance supports with `help_show`, e.g.
`https://opendata.nhsbsa.net/api/3/action/help_show?name=package_search`).
The package wraps the **useful read subset** of those actions — dataset
discovery, resource listing/metadata/download, datastore queries, and
the catalogue listings. Other registered actions (the `*_autocomplete`
family, `datastore_info`, `license_list`, `status_show`, and so on) are
intentionally not wrapped yet. If a gap is discovered, the convention is
to [open an issue](https://github.com/rmgpanw/nhsbsa/issues) and then
add the wrapper as below.

## Adding a new endpoint

To wrap another CKAN action, add a thin function whose arguments mirror
the API parameters. For example, to wrap `tag_show`:

``` r

#' Show a tag
#'
#' Wraps the CKAN `tag_show` action.
#'
#' @param id Character scalar. The tag name or id.
#' @inheritParams nhsbsa_package_list
#'
#' @return A list of tag metadata.
#' @export
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' nhsbsa_tag_show("prescribing")
nhsbsa_tag_show <- function(id, .return_raw = FALSE) {
  nhsbsa_query("tag_show")
}
```

That is the whole implementation:
[`nhsbsa_query()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_query.md)
picks up `id` from the signature and sends it as a query parameter. If
the action returns tabular data, post-process the result with
`nhsbsa_records_to_tibble()`.

Then:

``` r

devtools::document() # regenerate NAMESPACE and the .Rd file
```

Keep examples gated with
`@examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")` so they render
on the documentation site but never run on CRAN.

## Testing

Tests use `testthat` (edition 3). The suite is designed to run fully
offline and deterministically; a small set of live tests is gated
separately.

### Offline tests with recorded fixtures

Network calls are recorded as [httptest2](https://enpiar.com/httptest2/)
fixtures and replayed. Wrap a block in `with_mock_dir()`; the first run
records the responses, later runs replay them:

``` r

with_mock_dir("pl", {
  test_that("nhsbsa_package_list returns dataset ids", {
    out <- nhsbsa_package_list()
    expect_type(out, "character")
  })
})
```

Keep the mock directory name **short**. The portal’s URL path
(`opendata.nhsbsa.net/api/3/action/`) is deep, and R CMD check rejects
tarball paths longer than 100 bytes, so a long directory name plus a
long action name can tip a fixture over the limit.

### Offline tests with mocked responses

For error paths and edge cases it is simpler to mock the HTTP response
directly, without a fixture, using
[`httr2::with_mocked_responses()`](https://httr2.r-lib.org/reference/with_mocked_responses.html):

``` r

test_that("an HTTP error surfaces as nhsbsa_api_error", {
  resp <- httr2::response(
    status_code = 404L,
    headers = list(`Content-Type` = "application/json"),
    body = charToRaw('{"success":false,"error":{"message":"nope"}}')
  )
  httr2::with_mocked_responses(function(req) resp, {
    expect_error(nhsbsa_package_show("x"), class = "nhsbsa_http_404")
  })
})
```

### Live tests

Tests that contact the real API live in `tests/testthat/test-live.R`.
They are skipped on CRAN, skipped when offline, and only run when the
`NHSBSA_LIVE_TESTS` environment variable is set. The continuous
integration workflows set this variable so the live tests run there. Use
live tests sparingly, as a smoke test that the real API still behaves as
expected.

## Checks before a pull request

``` sh
air format .
```

``` r

devtools::document()
devtools::test()
lintr::lint_package()
spelling::spell_check_package()
devtools::check()
```

Aim for a clean `devtools::check()` (no errors, warnings or notes). New
user-facing terms that the spell checker flags can be added to
`inst/WORDLIST`.
