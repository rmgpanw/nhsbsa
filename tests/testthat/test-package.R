with_mock_dir("fixtures/package_list", {
  test_that("nhsbsa_package_list returns a character vector of dataset ids", {
    out <- nhsbsa_package_list()
    expect_type(out, "character")
    expect_true("bnf-code-information-current-year" %in% out)
  })
})
