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
        nhsbsa_download_resource(
          "ds",
          pattern = "no-such-thing",
          directory = tempdir()
        ),
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
        nhsbsa_download_resource("ds", directory = tempdir()),
        class = "nhsbsa_multiple_resources"
      )
      expect_error(
        nhsbsa_download_resource(
          "ds",
          pattern = "FILE_2024",
          directory = tempdir()
        ),
        class = "nhsbsa_multiple_resources"
      )
    }
  )
})

test_that("nhsbsa_download_resource saves under the resource's own file name", {
  streamed_from <- NULL
  with_mocked_bindings(
    nhsbsa_list_resources = function(...) fake_resources(),
    nhsbsa_download_file = function(url, dest, ...) {
      streamed_from <<- url
      writeLines("col\n1", dest)
      invisible(dest)
    },
    {
      dir <- withr::local_tempdir()
      # With quiet = FALSE the download emits an informational message.
      expect_message(
        out <- nhsbsa_download_resource(
          "ds",
          resource_id = "rid-2",
          directory = dir
        ),
        class = "nhsbsa_message"
      )
      # File name is taken from the resource's download URL.
      expect_identical(out, file.path(dir, "202402.csv"))
      expect_identical(streamed_from, "https://example.test/202402.csv")
      expect_true(file.exists(out))
    }
  )
})

test_that("nhsbsa_download_resource errors when the directory does not exist", {
  with_mocked_bindings(
    nhsbsa_list_resources = function(...) fake_resources(),
    {
      expect_error(
        nhsbsa_download_resource(
          "ds",
          resource_id = "rid-1",
          directory = file.path(tempdir(), "no-such-dir")
        ),
        class = "nhsbsa_error"
      )
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
      dir <- withr::local_tempdir()
      writeLines("already here", file.path(dir, "202401.csv"))
      expect_message(
        out <- nhsbsa_download_resource(
          "ds",
          resource_id = "rid-1",
          directory = dir,
          overwrite = FALSE
        ),
        class = "nhsbsa_message"
      )
      expect_identical(out, file.path(dir, "202401.csv"))
      expect_false(downloaded)
    }
  )
})
