## R CMD check results

0 errors | 0 warnings | 0 notes

* This is a new release.

## Test environments

* local macOS, R 4.5.3
* GitHub Actions (Windows, macOS, Ubuntu): R release, devel and oldrel-1

## Notes on examples and tests

* All examples that contact the NHSBSA Open Data Portal are guarded so they do
  not run on CRAN.
* Unit tests replay recorded HTTP fixtures and run offline. Tests that contact
  the live API are skipped on CRAN and unless `NHSBSA_LIVE_TESTS` is set.
* Per CRAN policy, functions fail gracefully with an informative message when
  the API is unavailable (e.g. with no internet connection).
