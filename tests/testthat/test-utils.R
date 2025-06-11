test_that("validate_dataset_id works correctly", {
  expect_true(validate_dataset_id("english-prescribing-data-epd"))
  expect_true(validate_dataset_id("test-dataset"))
  expect_false(validate_dataset_id(""))
  expect_false(validate_dataset_id(NULL))
  expect_false(validate_dataset_id(c("a", "b")))
  expect_false(validate_dataset_id(123))
})

test_that("build_sql_query creates correct SQL", {
  # Test basic query
  query <- build_sql_query("test_resource")
  expect_equal(query, "SELECT * FROM `test_resource`")
  
  # Test with where conditions
  query_with_where <- build_sql_query(
    "test_resource", 
    where_conditions = list(field1 = "value1", field2 = "value2")
  )
  expected <- "SELECT * FROM `test_resource` WHERE field1 = 'value1' AND field2 = 'value2'"
  expect_equal(query_with_where, expected)
  
  # Test with custom select fields
  query_custom_select <- build_sql_query(
    "test_resource",
    select_fields = c("field1", "field2")
  )
  expect_equal(query_custom_select, "SELECT field1, field2 FROM `test_resource`")
})

test_that("check_api_availability handles errors gracefully", {
  # This test requires mocking or may fail if API is down
  # In a real scenario, you'd mock the HTTP request
  skip_if_offline()
  result <- check_api_availability()
  expect_type(result, "logical")
})
