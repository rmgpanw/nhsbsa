test_that("nhsbsa_download_data validates inputs", {
  expect_error(nhsbsa_download_data(NULL), "must be a character string")
  expect_error(nhsbsa_download_data(c("a", "b")), "must be a character string")
  expect_error(nhsbsa_download_data(123), "must be a character string")
})

test_that("nhsbsa_download_multiple validates inputs", {
  expect_error(nhsbsa_download_multiple(NULL), "must be a non-empty character vector")
  expect_error(nhsbsa_download_multiple(character(0)), "must be a non-empty character vector")
  expect_error(nhsbsa_download_multiple(123), "must be a non-empty character vector")
})

test_that("nhsbsa_download_data works with valid resource", {
  skip_if_offline()
  skip_on_cran()
  skip("Requires valid resource and may be slow")
  
  # This test would need a known good resource
  # data <- nhsbsa_download_data(
  #   resource_name = "EPD_202401",
  #   where_conditions = list(pco_code = "13T00"),
  #   limit = 10
  # )
  # expect_s3_class(data, "data.frame")
})

test_that("nhsbsa_download_multiple handles empty results", {
  skip_if_offline()
  skip_on_cran()
  skip("Requires mocking or valid test data")
  
  # This would test error handling when resources don't exist
})
