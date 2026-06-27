test_that("nhsbsa_abort appends the base class and stores the message", {
  cnd <- tryCatch(
    nhsbsa_abort(
      c("x" = "It went wrong: {.val {6 * 7}}."),
      class = "nhsbsa_custom_error"
    ),
    error = function(e) e
  )

  expect_s3_class(cnd, "nhsbsa_custom_error")
  expect_s3_class(cnd, "nhsbsa_error")
  expect_s3_class(cnd, "rlang_error")
  # The structured message is interpolated up front and stored.
  expect_match(cnd$cli_message[["x"]], "It went wrong: 42")
})

test_that("nhsbsa_warn and nhsbsa_inform carry their base classes", {
  expect_warning(nhsbsa_warn("careful"), class = "nhsbsa_warning")
  expect_message(
    nhsbsa_inform("for your information"),
    class = "nhsbsa_message"
  )
})
