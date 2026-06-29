## R CMD check results

0 errors | 0 warnings | 0 notes

* This is a new release.
* The incoming checks flag NHS, NHSBSA, datastore and tibbles in DESCRIPTION as
  possibly misspelled. These are spelled correctly: NHS and NHSBSA are proper
  nouns, "datastore" is the CKAN API's own term, and "tibbles" is a standard R
  data structure.

## Test environments

* local macOS, R 4.5.3
* GitHub Actions (Windows, macOS, Ubuntu): R release, devel and oldrel-1

## Notes on examples and tests

* Examples and tests do not access the internet during R CMD check; tests
  against the live API run only when `NHSBSA_LIVE_TESTS` is set.
* Exported functions fail gracefully with an informative message when the portal
  is unavailable.
* This package is an API client and implements no published methods, so there
  are no references to cite in the DESCRIPTION.
