with_mock_dir("bnf", {
  test_that("nhsbsa_package_show returns the dataset metadata", {
    meta <- nhsbsa_package_show("bnf-code-information-current-year")
    expect_type(meta, "list")
    expect_false(is.null(meta$resources))
  })

  test_that("nhsbsa_list_resources returns a tibble with the expected columns", {
    out <- nhsbsa_list_resources("bnf-code-information-current-year")
    expect_s3_class(out, "tbl_df")
    expect_setequal(
      names(out),
      c("name", "id", "format", "created", "last_modified", "url", "size")
    )
    expect_gt(nrow(out), 0)
  })

  test_that("nhsbsa_list_resources filters by pattern", {
    out <- nhsbsa_list_resources(
      "bnf-code-information-current-year",
      pattern = "202505"
    )
    expect_true(nrow(out) >= 1)
    expect_true(all(grepl("202505", out$name)))
  })
})

# Resource resolution and download are tested without the network by stubbing
# the metadata lookup and the byte-streaming helper.

fake_resources <- function() {
  tibble::tibble(
    name = c("FILE_202401", "FILE_202402"),
    id = c("rid-1", "rid-2"),
    format = "CSV",
    created = NA_character_,
    last_modified = NA_character_,
    url = c(
      "https://example.test/202401.csv",
      "https://example.test/202402.csv"
    ),
    size = NA_character_
  )
}

test_that("nhsbsa_download_resource errors clearly on no match", {
  with_mocked_bindings(
    nhsbsa_list_resources = function(...) fake_resources(),
    {
      expect_error(
        nhsbsa_download_resource("ds", pattern = "no-such-thing"),
        class = "nhsbsa_resource_not_found"
      )
    }
  )
})

test_that("nhsbsa_download_resource errors when more than one resource matches", {
  with_mocked_bindings(
    nhsbsa_list_resources = function(...) fake_resources(),
    {
      # No selector and two resources -> ambiguous.
      expect_error(
        nhsbsa_download_resource("ds"),
        class = "nhsbsa_multiple_resources"
      )
      expect_error(
        nhsbsa_download_resource("ds", pattern = "FILE_2024"),
        class = "nhsbsa_multiple_resources"
      )
    }
  )
})

test_that("nhsbsa_download_resource resolves a resource and streams it", {
  streamed_from <- NULL
  with_mocked_bindings(
    nhsbsa_list_resources = function(...) fake_resources(),
    nhsbsa_download_file = function(url, dest, ...) {
      streamed_from <<- url
      writeLines("col\n1", dest)
      invisible(dest)
    },
    {
      dest <- withr::local_tempfile(fileext = ".csv")
      # With quiet = FALSE the download emits an informational message.
      expect_message(
        out <- nhsbsa_download_resource(
          "ds",
          resource_id = "rid-2",
          dest = dest
        ),
        class = "nhsbsa_message"
      )
      expect_identical(out, dest)
      expect_identical(streamed_from, "https://example.test/202402.csv")
      expect_true(file.exists(dest))
    }
  )
})

test_that("nhsbsa_download_resource short-circuits an existing file", {
  downloaded <- FALSE
  with_mocked_bindings(
    nhsbsa_list_resources = function(...) fake_resources(),
    nhsbsa_download_file = function(url, dest, ...) {
      downloaded <<- TRUE
      invisible(dest)
    },
    {
      dest <- withr::local_tempfile(fileext = ".csv")
      writeLines("already here", dest)
      expect_message(
        out <- nhsbsa_download_resource(
          "ds",
          resource_id = "rid-1",
          dest = dest,
          overwrite = FALSE
        ),
        class = "nhsbsa_message"
      )
      expect_identical(out, dest)
      expect_false(downloaded)
    }
  )
})
