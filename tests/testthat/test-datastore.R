test_that("nhsbsa_warn_incomplete_results warns only when rows remain", {
  expect_warning(
    nhsbsa_warn_incomplete_results(
      list(total = 100),
      n_returned = 10,
      offset = 0
    ),
    class = "nhsbsa_incomplete_results"
  )
  # Accounts for the offset already paged through.
  expect_warning(
    nhsbsa_warn_incomplete_results(
      list(total = 100),
      n_returned = 10,
      offset = 80
    ),
    class = "nhsbsa_incomplete_results"
  )
  expect_no_warning(
    nhsbsa_warn_incomplete_results(
      list(total = 10),
      n_returned = 10,
      offset = 0
    )
  )
  # No total (include_total = FALSE) -> cannot tell, so no warning.
  expect_no_warning(
    nhsbsa_warn_incomplete_results(
      list(total = NULL),
      n_returned = 10,
      offset = 0
    )
  )
})

with_mock_dir("fixtures/datastore_search", {
  test_that("nhsbsa_datastore_search returns a tibble of rows", {
    out <- suppressWarnings(
      nhsbsa_datastore_search(resource_id = "EPD_201401", limit = 5)
    )
    expect_s3_class(out, "tbl_df")
    expect_identical(nrow(out), 5L)
  })

  test_that("nhsbsa_datastore_search warns when more rows are available", {
    expect_warning(
      nhsbsa_datastore_search(resource_id = "EPD_201401", limit = 5),
      class = "nhsbsa_incomplete_results"
    )
  })
})

with_mock_dir("fixtures/datastore_search_sql", {
  test_that("nhsbsa_datastore_search_sql returns a tibble of rows", {
    out <- nhsbsa_datastore_search_sql(
      resource_id = "EPD_201401",
      sql = "SELECT YEAR_MONTH, PCO_CODE FROM `EPD_201401` LIMIT 3"
    )
    expect_s3_class(out, "tbl_df")
    expect_identical(nrow(out), 3L)
  })
})
