# CLAUDE.md

## Project overview

`nhsbsa` is a low-level R client for the NHS Business Services Authority
(NHSBSA) Open Data Portal — a standard [CKAN](https://ckan.org)
catalogue at `https://opendata.nhsbsa.net/api/3/action/`. It is a
**generic client with no domain knowledge**: functions wrap CKAN API
actions one-to-one and return plain data (tibbles for tabular results,
lists for metadata). Callers supply dataset identifiers and interpret
the results; any domain-specific logic belongs in a separate consumer
package, not here.

## Design principles

- **Purity.** One exported function per CKAN action, named after it,
  with an argument for every documented API parameter, so users familiar
  with the API need not relearn anything. The only deliberate exceptions
  are the two convenience helpers
  [`nhsbsa_list_resources()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_list_resources.md)
  and
  [`nhsbsa_download_resource()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_download_resource.md).
- **One request layer.** Every endpoint is a thin caller of
  [`nhsbsa_query()`](https://rmgpanw.github.io/nhsbsa/reference/nhsbsa_query.md)
  (`R/core.R`), which reads the calling function’s arguments into the
  query string, performs the request with retry/backoff, validates the
  CKAN envelope and fails gracefully when the portal is unreachable.
- **Portal quirks** (documented where relevant): the datastore
  identifies a resource by its *name* (e.g. `EPD_201401`), not its UUID;
  and `datastore_search_sql` requires `resource_id` alongside `sql` and
  nests its records one level deeper than standard CKAN.

## Style guidelines

- UK English throughout (e.g. “serialise”, “behaviour”, “parameterise”).
- `snake_case`; all exported functions prefixed `nhsbsa_`.
- Use `cli` via the internal wrappers
  [`nhsbsa_abort()`](https://rmgpanw.github.io/nhsbsa/reference/conditions.md)
  /
  [`nhsbsa_warn()`](https://rmgpanw.github.io/nhsbsa/reference/conditions.md)
  /
  [`nhsbsa_inform()`](https://rmgpanw.github.io/nhsbsa/reference/conditions.md)
  (`R/conditions.R`) — never another package’s error helpers. Give
  conditions specific subclasses so they can be handled
  programmatically.
- HTTP via `httr2`. Prefer tidyverse (`dplyr`, `purrr`, `stringr`,
  `tibble`) where it reads well; use base R where it is genuinely
  simpler.

## Testing and checks

- Tests use `testthat` (edition 3). Network tests replay recorded
  `httptest2` fixtures and run offline; live API tests are gated behind
  `NHSBSA_LIVE_TESTS`.
- `devtools::test()` — run tests (set `NHSBSA_LIVE_TESTS=true` to
  include live).
- `lintr::lint_package()` — lint. `air format .` — format.
- `devtools::document()` — regenerate docs. `devtools::check()` — R CMD
  check.
- [`spelling::spell_check_package()`](https://docs.ropensci.org/spelling//reference/spell_check_package.html)
  — UK English spell check.

When recording new fixtures, keep `with_mock_dir()` directory names
short: the fixed `opendata.nhsbsa.net/api/3/action/` path is deep, so
long names can push tarball paths over the portable 100-byte limit.
