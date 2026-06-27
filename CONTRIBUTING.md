# Contributing to nhsbsa

Thank you for taking the time to contribute! This package is a low-level
client for the NHS Business Services Authority Open Data Portal, and
contributions that keep it a thin, general-purpose wrapper are very
welcome.

## Scope

`nhsbsa` deliberately contains **no dataset-specific or domain
knowledge**. New endpoint wrappers should map one-to-one onto a CKAN API
action, exposing an argument for each documented API parameter. Logic
specific to a particular dataset belongs in a separate package that
depends on this one.

## Reporting bugs and requesting features

Please open an issue at <https://github.com/rmgpanw/nhsbsa/issues>. For
bugs, a minimal [reprex](https://reprex.tidyverse.org) is enormously
helpful.

## Pull requests

1.  Fork the repository and create a branch for your change.

2.  Make your change, following the conventions in `CLAUDE.md` (UK
    English, `snake_case`, `nhsbsa_`-prefixed exports, `cli` for
    messages via the internal
    [`nhsbsa_abort()`](https://rmgpanw.github.io/nhsbsa/reference/conditions.md)
    /
    [`nhsbsa_warn()`](https://rmgpanw.github.io/nhsbsa/reference/conditions.md)
    /
    [`nhsbsa_inform()`](https://rmgpanw.github.io/nhsbsa/reference/conditions.md)
    helpers).

3.  Add or update tests. Offline tests use recorded `httptest2`
    fixtures; live tests are gated behind the `NHSBSA_LIVE_TESTS`
    environment variable.

4.  Run the checks before submitting:

    ``` r
    air format .
    devtools::document()
    devtools::test()
    lintr::lint_package()
    devtools::check()
    ```

5.  Open a pull request describing the change and linking any related
    issue.

## Code of conduct

Please be respectful and constructive in all project interactions.
