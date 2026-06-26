test_that("nhsbsa_format_query_value encodes values the way CKAN expects", {
  expect_null(nhsbsa_format_query_value(NULL))
  expect_null(nhsbsa_format_query_value(character(0)))
  expect_identical(nhsbsa_format_query_value(TRUE), "true")
  expect_identical(nhsbsa_format_query_value(FALSE), "false")
  expect_identical(nhsbsa_format_query_value(c("a", "b")), "a,b")
  expect_identical(nhsbsa_format_query_value(list(x = "y")), '{"x":"y"}')
  expect_identical(nhsbsa_format_query_value("EPD_201401"), "EPD_201401")
})

test_that("nhsbsa_collect_query_params reads supplied arguments, drops the rest", {
  endpoint <- function(
    resource_id,
    q = NULL,
    limit = NULL,
    .return_raw = FALSE
  ) {
    nhsbsa_collect_query_params(sys.function(), environment())
  }
  params <- endpoint("EPD_201401", limit = 5)

  expect_identical(params, list(resource_id = "EPD_201401", limit = 5))
  # NULL arguments and dot-prefixed control arguments are not sent.
  expect_false("q" %in% names(params))
  expect_false(".return_raw" %in% names(params))
})

test_that("nhsbsa_records_to_tibble builds one row per record", {
  records <- list(
    list(a = 1, b = "x"),
    list(a = 2, b = "y", c = NULL)
  )
  out <- nhsbsa_records_to_tibble(records)

  expect_s3_class(out, "tbl_df")
  expect_identical(nrow(out), 2L)
  expect_identical(nhsbsa_records_to_tibble(list()), tibble::tibble())
})

test_that("nhsbsa_error_message reads message, type and field errors", {
  expect_identical(nhsbsa_error_message(list(message = "boom")), "boom")
  expect_match(
    nhsbsa_error_message(list("__type" = "Validation", q = list("is invalid"))),
    "q: is invalid"
  )
  expect_identical(nhsbsa_error_message(NULL), character(0))
})

test_that("connection failures surface as a graceful nhsbsa_offline error", {
  # Port 1 refuses immediately, exercising the transport-failure path without
  # needing a network connection.
  req <- httr2::request("http://127.0.0.1:1")
  expect_error(nhsbsa_perform(req), class = "nhsbsa_offline")
})
