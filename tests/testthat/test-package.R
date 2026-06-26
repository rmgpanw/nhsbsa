with_mock_dir("pl", {
  test_that("nhsbsa_package_list returns a character vector of dataset ids", {
    out <- nhsbsa_package_list()
    expect_type(out, "character")
    expect_true("bnf-code-information-current-year" %in% out)
  })
})

with_mock_dir("search", {
  test_that("nhsbsa_package_search returns search results", {
    out <- nhsbsa_package_search(q = "prescribing", rows = 2)
    expect_type(out, "list")
    expect_identical(out$count, 639L)
    expect_length(out$results, 2)
  })
})
