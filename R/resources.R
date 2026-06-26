# Resource endpoints and file download ----------------------------------------
#
# A CKAN resource is a single file or datastore table belonging to a dataset.
# `nhsbsa_resource_show()` is a pure wrapper around the `resource_show` action.
# `nhsbsa_list_resources()` and `nhsbsa_download_resource()` are convenience
# helpers built on top of the dataset metadata: they trade strict API purity for
# the two operations a caller most often needs.

#' Show a resource's metadata
#'
#' Wraps the CKAN `resource_show` action to return the metadata for a single
#' resource (a file or datastore table).
#'
#' @param id Character scalar. The resource identifier.
#' @inheritParams nhsbsa_package_list
#'
#' @return A list of resource metadata. With `.return_raw = TRUE`, the parsed
#'   response envelope as a list.
#'
#' @export
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' resources <- nhsbsa_list_resources("english-prescribing-data-epd")
#' nhsbsa_resource_show(resources$id[[1]])
nhsbsa_resource_show <- function(id, .return_raw = FALSE) {
  nhsbsa_query("resource_show")
}

#' List a dataset's resources as a tibble
#'
#' A convenience wrapper around [nhsbsa_package_show()] that returns a dataset's
#' resources as a tibble, optionally filtered by a pattern matched against the
#' resource name. This is the most direct way to discover the resources (and
#' their download URLs) available for a dataset.
#'
#' @param dataset_id Character scalar. The dataset identifier, as returned by
#'   [nhsbsa_package_list()].
#' @param pattern Character scalar. An optional regular expression; only
#'   resources whose `name` matches (case-insensitively) are returned.
#'
#' @return A tibble with one row per resource and columns `name`, `id`,
#'   `format`, `created`, `last_modified`, `url` and `size`.
#'
#' @seealso [nhsbsa_download_resource()] to download a resource file.
#'
#' @export
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' nhsbsa_list_resources("english-prescribing-data-epd", pattern = "202401")
nhsbsa_list_resources <- function(dataset_id, pattern = NULL) {
  metadata <- nhsbsa_package_show(dataset_id)
  resources <- metadata$resources %||% list()

  out <- tibble::tibble(
    name = nhsbsa_pluck_chr(resources, "name"),
    id = nhsbsa_pluck_chr(resources, "id"),
    format = nhsbsa_pluck_chr(resources, "format"),
    created = nhsbsa_pluck_chr(resources, "created"),
    last_modified = nhsbsa_pluck_chr(resources, "last_modified"),
    url = nhsbsa_pluck_chr(resources, "url"),
    size = nhsbsa_pluck_chr(resources, "size")
  )

  if (!is.null(pattern)) {
    out <- out[nhsbsa_str_match(out$name, pattern), ]
  }

  out
}

#' Download a resource file
#'
#' Resolves a single resource within a dataset and streams its file to disk.
#' This is the file-download counterpart to the datastore row-query functions
#' ([nhsbsa_datastore_search()] and friends): it fetches the whole resource file
#' (e.g. a CSV) rather than running a query.
#'
#' Exactly one resource must be identified. Supply either `resource_id` or a
#' `pattern` that matches a single resource name; if neither is given and the
#' dataset has more than one resource, an error is raised.
#'
#' @inheritParams nhsbsa_list_resources
#' @param resource_id Character scalar. The identifier of the resource to
#'   download. Takes precedence over `pattern`.
#' @param pattern Character scalar. A regular expression matched
#'   (case-insensitively) against resource names to select a single resource.
#' @param dest Character scalar. The file path to write to. Defaults to a
#'   temporary file with a `.csv` extension.
#' @param overwrite Logical. Overwrite `dest` if it already exists? Defaults to
#'   `FALSE`, in which case an existing `dest` is left untouched.
#' @param quiet Logical. Suppress informational messages? Defaults to `FALSE`.
#'
#' @return The path to the downloaded file (`dest`), invisibly.
#'
#' @seealso [nhsbsa_list_resources()] to discover resources.
#'
#' @export
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' dest <- nhsbsa_download_resource(
#'   "bnf-code-information-current-year",
#'   pattern = "202401"
#' )
#' dest
nhsbsa_download_resource <- function(
  dataset_id,
  resource_id = NULL,
  pattern = NULL,
  dest = tempfile(fileext = ".csv"),
  overwrite = FALSE,
  quiet = FALSE
) {
  resource <- nhsbsa_resolve_resource(
    dataset_id,
    resource_id = resource_id,
    pattern = pattern
  )

  if (file.exists(dest) && !overwrite) {
    if (!quiet) {
      nhsbsa_inform(c(
        "i" = "{.path {dest}} already exists; skipping download.",
        "i" = "Set {.code overwrite = TRUE} to download it again."
      ))
    }
    return(invisible(dest))
  }

  if (!quiet) {
    nhsbsa_inform(c(
      "i" = "Downloading {.val {resource$name}} to {.path {dest}}."
    ))
  }

  nhsbsa_download_file(resource$url, dest)
  invisible(dest)
}

# Resolve a single resource within a dataset, erroring clearly when the
# selection matches zero or more than one resource.
nhsbsa_resolve_resource <- function(
  dataset_id,
  resource_id = NULL,
  pattern = NULL,
  call = rlang::caller_env()
) {
  resources <- nhsbsa_list_resources(dataset_id)

  if (!is.null(resource_id)) {
    matches <- resources[!is.na(resources$id) & resources$id == resource_id, ]
    criterion <- c("i" = "Looked for resource_id {.val {resource_id}}.")
  } else if (!is.null(pattern)) {
    matches <- resources[nhsbsa_str_match(resources$name, pattern), ]
    criterion <- c(
      "i" = "Looked for resources matching pattern {.val {pattern}}."
    )
  } else {
    matches <- resources
    criterion <- c(
      "i" = "No {.arg resource_id} or {.arg pattern} was supplied."
    )
  }

  if (nrow(matches) == 0) {
    nhsbsa_abort(
      c(
        "x" = "No resource in dataset {.val {dataset_id}} matched.",
        criterion,
        "i" = "List available resources with
               {.code nhsbsa_list_resources(\"{dataset_id}\")}."
      ),
      class = "nhsbsa_resource_not_found",
      call = call
    )
  }

  if (nrow(matches) > 1) {
    nhsbsa_abort(
      c(
        "x" = "{nrow(matches)} resources in dataset {.val {dataset_id}} matched;
               exactly one is required.",
        criterion,
        "i" = "Disambiguate with {.arg resource_id} or a more specific
               {.arg pattern}.",
        "*" = "{matches$name}"
      ),
      class = "nhsbsa_multiple_resources",
      call = call
    )
  }

  as.list(matches[1, ])
}

# Stream a file from `url` to `dest`, reusing the package's retry/offline
# handling. Separated out so the byte-streaming can be tested independently of
# the resource-resolution logic.
nhsbsa_download_file <- function(url, dest, call = rlang::caller_env()) {
  req <- httr2::request(url) |>
    httr2::req_user_agent(nhsbsa_user_agent()) |>
    httr2::req_retry(max_tries = 3, is_transient = nhsbsa_is_transient)

  nhsbsa_perform(req, path = dest, call = call)
  invisible(dest)
}

# Extract a character field from a list of CKAN resources, NA where absent.
nhsbsa_pluck_chr <- function(resources, field) {
  purrr::map_chr(resources, function(resource) {
    value <- resource[[field]]
    if (is.null(value)) NA_character_ else as.character(value)
  })
}

# Case-insensitive regex match returning FALSE (never NA) for missing names, so
# the result is safe to use for row subsetting.
nhsbsa_str_match <- function(x, pattern) {
  matched <- stringr::str_detect(x, stringr::regex(pattern, ignore_case = TRUE))
  matched[is.na(matched)] <- FALSE
  matched
}
