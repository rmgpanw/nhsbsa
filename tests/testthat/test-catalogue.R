with_mock_dir("org", {
  test_that("nhsbsa_organization_list returns organisation names", {
    out <- nhsbsa_organization_list()
    expect_type(out, "character")
    expect_gt(length(out), 0)
  })
})

with_mock_dir("tag", {
  test_that("nhsbsa_tag_list returns tags, filtered by query", {
    out <- nhsbsa_tag_list(query = "prescribing")
    expect_type(out, "character")
    expect_gt(length(out), 0)
    expect_true(any(grepl("prescrib", out, ignore.case = TRUE)))
  })
})

test_that("nhsbsa_group_list returns an empty character vector when there are no groups", {
  resp <- httr2::response(
    status_code = 200L,
    headers = list(`Content-Type` = "application/json"),
    body = charToRaw('{"success":true,"result":[]}')
  )
  httr2::with_mocked_responses(function(req) resp, {
    expect_identical(nhsbsa_group_list(), character(0))
  })
})

test_that("nhsbsa_simplify_catalogue keeps records when all_fields-style data is returned", {
  records <- list(
    list(name = "a", title = "Org A"),
    list(name = "b", title = "Org B")
  )
  expect_identical(nhsbsa_simplify_catalogue(records), records)
  expect_identical(nhsbsa_simplify_catalogue(list("a", "b")), c("a", "b"))
  expect_identical(nhsbsa_simplify_catalogue(list()), character(0))
})
