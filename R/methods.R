# Methods for the classed list returns -----------------------------------------
#
# nhsbsa_package_show(), nhsbsa_resource_show() and nhsbsa_package_search()
# return lists with a lightweight class, so they get a tidy print() method and an
# as_tibble() method. They are still plain lists underneath ($, [[, str() all
# work), and `.return_raw = TRUE` (or unclass()) returns the unclassed list.

nhsbsa_new_package <- function(x) {
  class(x) <- c("nhsbsa_package", "list")
  x
}

nhsbsa_new_resource <- function(x) {
  class(x) <- c("nhsbsa_resource", "list")
  x
}

nhsbsa_new_package_search <- function(x) {
  class(x) <- c("nhsbsa_package_search", "list")
  x
}

# Coerce a (possibly missing or multi-element) field to a single display string.
nhsbsa_display <- function(value) {
  value <- unlist(value, use.names = FALSE)
  if (length(value) == 0) {
    return("\u2014")
  }
  paste(as.character(value), collapse = ", ")
}

# Display an ISO date-time field as just its date part.
nhsbsa_display_date <- function(value) {
  shown <- nhsbsa_display(value)
  if (grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}", shown)) {
    substr(shown, 1, 10)
  } else {
    shown
  }
}

# First `n` non-missing elements, with a trailing ellipsis if truncated.
nhsbsa_truncate <- function(x, n) {
  x <- x[!is.na(x)]
  if (length(x) == 0) {
    return(NULL)
  }
  if (length(x) > n) {
    paste0(paste(x[seq_len(n)], collapse = ", "), ", \u2026")
  } else {
    paste(x, collapse = ", ")
  }
}

#' Methods for nhsbsa objects
#'
#' Some `nhsbsa` functions return classed lists with a tailored
#' [print()][base::print] method and a [tibble::as_tibble()] method for turning
#' them into a table:
#'
#' * [nhsbsa_package_show()] returns an `nhsbsa_package`; `as_tibble()` returns
#'   its resources (one row per file).
#' * [nhsbsa_resource_show()] returns an `nhsbsa_resource`.
#' * [nhsbsa_package_search()] returns an `nhsbsa_package_search`; `as_tibble()`
#'   returns one row per matching dataset.
#'
#' These objects are still plain lists, so `$`, `[[` and [utils::str()] work as
#' usual. Pass `.return_raw = TRUE` to the originating function, or use
#' [unclass()], to get the underlying list without a class.
#'
#' @param x An object returned by the relevant `nhsbsa` function.
#' @param ... Ignored, for S3 method consistency.
#'
#' @return The `print()` methods return `x` invisibly. The `as_tibble()` methods
#'   return a [tibble][tibble::tibble].
#'
#' @name nhsbsa-methods
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' pkg <- nhsbsa_package_show("english-prescribing-data-epd")
#' pkg
#' tibble::as_tibble(pkg)
#'
#' hits <- nhsbsa_package_search(q = "prescribing", rows = 5)
#' hits
#' tibble::as_tibble(hits)
NULL

#' @rdname nhsbsa-methods
#' @export
print.nhsbsa_package <- function(x, ...) {
  org <- x$organization$title %||% x$organization$name
  tags <- vapply(
    x$tags %||% list(),
    function(t) t$name %||% NA_character_,
    character(1)
  )
  cli::cli_text("{.strong <nhsbsa dataset>} {.val {x$name %||% NA}}")
  cli::cli_dl(c(
    "Title" = nhsbsa_display(x$title),
    "Organisation" = nhsbsa_display(org),
    "Modified" = nhsbsa_display_date(x$metadata_modified),
    "Resources" = nhsbsa_display(length(x$resources %||% list())),
    "Tags" = nhsbsa_display(nhsbsa_truncate(tags, 5))
  ))
  cli::cli_text(
    "{.emph Use {.code tibble::as_tibble()} for its resources.}"
  )
  invisible(x)
}

#' @rdname nhsbsa-methods
#' @export
print.nhsbsa_resource <- function(x, ...) {
  cli::cli_text("{.strong <nhsbsa resource>} {.val {x$name %||% NA}}")
  cli::cli_dl(c(
    "Format" = nhsbsa_display(x$format),
    "Size" = nhsbsa_display(x$size),
    "Datastore" = nhsbsa_display(isTRUE(x$datastore_active)),
    "Modified" = nhsbsa_display_date(x$last_modified),
    "URL" = nhsbsa_display(x$url)
  ))
  invisible(x)
}

#' @rdname nhsbsa-methods
#' @export
print.nhsbsa_package_search <- function(x, ...) {
  results <- x$results %||% list()
  count <- x$count %||% length(results)
  shown <- length(results)
  cli::cli_text("{.strong <nhsbsa package search>} {count} dataset{?s} found")
  if (shown < count) {
    cli::cli_text(
      "{.emph Showing the first {shown}; increase {.arg rows} for more.}"
    )
  }
  print(tibble::as_tibble(x), ...)
  invisible(x)
}

#' @rdname nhsbsa-methods
#' @exportS3Method tibble::as_tibble
as_tibble.nhsbsa_package <- function(x, ...) {
  nhsbsa_resources_to_tibble(x$resources %||% list())
}

#' @rdname nhsbsa-methods
#' @exportS3Method tibble::as_tibble
as_tibble.nhsbsa_package_search <- function(x, ...) {
  results <- x$results %||% list()
  tibble::tibble(
    name = nhsbsa_pluck_chr(results, "name"),
    title = nhsbsa_pluck_chr(results, "title"),
    organisation = vapply(
      results,
      function(r) (r$organization$name %||% NA_character_)[[1]],
      character(1)
    ),
    num_resources = vapply(
      results,
      function(r) {
        value <- r$num_resources
        if (is.null(value)) NA_integer_ else as.integer(value)
      },
      integer(1)
    ),
    metadata_modified = nhsbsa_pluck_chr(results, "metadata_modified")
  )
}
