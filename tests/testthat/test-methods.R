with_mock_dir("bnf", {
  test_that("nhsbsa_package_show returns a classed object with print + as_tibble", {
    pkg <- nhsbsa_package_show("bnf-code-information-current-year")
    expect_s3_class(pkg, "nhsbsa_package")
    expect_type(pkg, "list")
    out <- cli::cli_fmt(print(pkg))
    expect_true(any(grepl("nhsbsa dataset", out)))
    expect_true(any(grepl("Resources", out)))

    resources <- tibble::as_tibble(pkg)
    expect_s3_class(resources, "tbl_df")
    expect_true(all(c("name", "id", "url") %in% names(resources)))
    expect_gt(nrow(resources), 0)
  })

  test_that(".return_raw returns an unclassed list", {
    raw <- nhsbsa_package_show(
      "bnf-code-information-current-year",
      .return_raw = TRUE
    )
    expect_false(inherits(raw, "nhsbsa_package"))
    expect_true(isTRUE(raw$success))
  })
})

with_mock_dir("search", {
  test_that("nhsbsa_package_search returns a classed object with print + as_tibble", {
    hits <- nhsbsa_package_search(q = "prescribing", rows = 2)
    expect_s3_class(hits, "nhsbsa_package_search")
    expect_true(any(grepl("datasets found", cli::cli_fmt(print(hits)))))

    tib <- tibble::as_tibble(hits)
    expect_s3_class(tib, "tbl_df")
    expect_identical(
      names(tib),
      c("name", "title", "organisation", "num_resources", "metadata_modified")
    )
    expect_identical(nrow(tib), length(hits$results))
  })
})

test_that("nhsbsa_resource_show returns a classed nhsbsa_resource", {
  result <- '{"name":"R1","format":"CSV","datastore_active":false,"url":"https://example.test/r.csv"}'
  resp <- httr2::response(
    200L,
    headers = list(`Content-Type` = "application/json"),
    body = charToRaw(paste0('{"success":true,"result":', result, "}"))
  )
  httr2::with_mocked_responses(function(req) resp, {
    resource <- nhsbsa_resource_show("abc")
    expect_s3_class(resource, "nhsbsa_resource")
    out <- cli::cli_fmt(print(resource))
    expect_true(any(grepl("nhsbsa resource", out)))
    expect_true(any(grepl("Format", out)))
  })
})

test_that("display helpers behave", {
  expect_identical(nhsbsa_display(NULL), "\u2014")
  expect_identical(nhsbsa_display("x"), "x")
  expect_identical(nhsbsa_display(c("a", "b")), "a, b")
  expect_identical(nhsbsa_display_date("2026-06-02T10:02:48"), "2026-06-02")
  expect_identical(nhsbsa_display_date(NULL), "\u2014")
  expect_null(nhsbsa_truncate(NA_character_, 5))
  expect_match(nhsbsa_truncate(as.character(1:10), 3), "1, 2, 3")
})
