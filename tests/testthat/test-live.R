# Live smoke tests that hit the real NHSBSA API. These are skipped on CRAN and
# when offline, and only run when NHSBSA_LIVE_TESTS is set (e.g. in CI), so the
# rest of the suite stays fully offline and deterministic.

skip_if_no_live_tests <- function() {
  skip_on_cran()
  skip_if_offline()
  skip_if(
    !nzchar(Sys.getenv("NHSBSA_LIVE_TESTS")),
    "Set NHSBSA_LIVE_TESTS to run live API tests."
  )
}

test_that("live: nhsbsa_package_list reaches the portal", {
  skip_if_no_live_tests()
  out <- nhsbsa_package_list()
  expect_type(out, "character")
  expect_true("bnf-code-information-current-year" %in% out)
})

test_that("live: list and download a resource end to end", {
  skip_if_no_live_tests()
  resources <- nhsbsa_list_resources("bnf-code-information-current-year")
  expect_s3_class(resources, "tbl_df")
  expect_gt(nrow(resources), 0)

  dir <- withr::local_tempdir()
  out <- nhsbsa_download_resource(
    "bnf-code-information-current-year",
    resource_id = resources$id[[1]],
    directory = dir,
    quiet = TRUE
  )
  expect_true(file.exists(out))
  expect_gt(file.size(out), 0)
})

test_that("live: datastore_search_sql returns rows", {
  skip_if_no_live_tests()
  out <- nhsbsa_datastore_search_sql(
    resource_id = "EPD_201401",
    sql = "SELECT YEAR_MONTH FROM `EPD_201401` LIMIT 3"
  )
  expect_s3_class(out, "tbl_df")
  expect_identical(nrow(out), 3L)
})
