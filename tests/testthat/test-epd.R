test_that("nhsbsa_get_epd validates inputs", {
  expect_error(nhsbsa_get_epd(), "`year` is required")
})

test_that("nhsbsa_get_epd generates correct resource names", {
  skip_if_offline()
  skip_on_cran()
  skip("Requires mocking or integration test setup")
  
  # Would test that correct EPD_YYYYMM resource names are generated
})

test_that("nhsbsa_search_epd_chemical validates inputs", {
  expect_error(
    nhsbsa_search_epd_chemical(),
    "`chemical_pattern` is required"
  )
  
  # Test that it requires chemical_pattern
  expect_error(
    nhsbsa_search_epd_chemical(year = 2024),
    "`chemical_pattern` is required"
  )
})
