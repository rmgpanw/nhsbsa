# Error handling and `.return_raw` branches, exercised offline with mocked
# httr2 responses so no fixtures or network are needed.

json_response <- function(body, status = 200L) {
  httr2::response(
    status_code = status,
    headers = list(`Content-Type` = "application/json"),
    body = charToRaw(body)
  )
}

mock_response <- function(response, code) {
  httr2::with_mocked_responses(function(req) response, code)
}

test_that("an HTTP error surfaces with nhsbsa and status subclasses", {
  resp <- json_response(
    '{"success":false,"error":{"__type":"Not Found","message":"nope"}}',
    status = 404L
  )
  mock_response(resp, {
    expect_error(nhsbsa_package_show("x"), class = "nhsbsa_api_error")
    expect_error(nhsbsa_package_show("x"), class = "nhsbsa_http_404")
  })
})

test_that("a 200 envelope with success = false aborts as an API error", {
  resp <- json_response('{"success":false,"error":{"message":"it broke"}}')
  mock_response(resp, {
    expect_error(
      nhsbsa_package_list(),
      class = "nhsbsa_api_error"
    )
    expect_error(nhsbsa_package_list(), "it broke")
  })
})

test_that("nhsbsa_abort_api_error falls back to a generic message", {
  expect_error(
    nhsbsa_abort_api_error(NULL),
    regexp = "Unknown error",
    class = "nhsbsa_api_error"
  )
})

test_that(".return_raw returns the full response envelope", {
  resp <- json_response('{"success":true,"result":["a","b"]}')
  mock_response(resp, {
    raw <- nhsbsa_package_list(.return_raw = TRUE)
    expect_true(raw$success)
    expect_length(raw$result, 2)
    # Without .return_raw the result is processed into a character vector.
    expect_identical(nhsbsa_package_list(), c("a", "b"))
  })
})

test_that("nhsbsa_resource_show returns resource metadata", {
  resp <- json_response(
    '{"success":true,"result":{"id":"abc","name":"R","datastore_active":false}}'
  )
  mock_response(resp, {
    out <- nhsbsa_resource_show("abc")
    expect_type(out, "list")
    expect_identical(out$id, "abc")
  })
})

test_that("datastore_search supports .return_raw", {
  resp <- json_response('{"success":true,"result":{"records":[],"total":0}}')
  mock_response(resp, {
    raw <- nhsbsa_datastore_search("EPD_201401", .return_raw = TRUE)
    expect_true(raw$success)
  })
})

test_that("datastore_search_sql surfaces inner query errors", {
  resp <- json_response(
    '{"success":true,"result":{"success":false,"message":"invalid SQL"}}'
  )
  mock_response(resp, {
    expect_error(
      nhsbsa_datastore_search_sql("EPD_201401", "SELECT bad"),
      class = "nhsbsa_api_error"
    )
  })
})
