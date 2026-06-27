# Core request layer ----------------------------------------------------------
#
# Every exported endpoint function is a thin wrapper around `nhsbsa_query()`,
# which builds and performs the HTTP request, validates the CKAN response
# envelope and returns the `result` element. Endpoint functions deliberately
# carry one argument per documented API parameter; `nhsbsa_query()` reads those
# arguments back from the calling function so the argument names map directly
# onto the query string, with no per-endpoint plumbing.

# Base URL for the NHSBSA Open Data Portal CKAN action API.
nhsbsa_base_url <- function() {
  "https://opendata.nhsbsa.net/api/3/action/"
}

nhsbsa_user_agent <- function() {
  "nhsbsa (https://github.com/rmgpanw/nhsbsa)"
}

# HTTP status codes worth retrying with backoff.
nhsbsa_is_transient <- function(resp) {
  httr2::resp_status(resp) %in% c(429L, 500L, 502L, 503L, 504L)
}

#' Perform a request against a CKAN action endpoint *(internal)*
#'
#' Builds the request for `action`, collecting query parameters from the calling
#' endpoint function's arguments, performs it with retry/backoff and returns the
#' parsed `result` element of the CKAN response envelope.
#'
#' @param action Character scalar. The CKAN action to call (e.g.
#'   `"package_show"`), appended to the base API path.
#' @param call Environment to report in error messages.
#'
#' @return The `result` element of the CKAN response, or — when the calling
#'   function was invoked with `.return_raw = TRUE` — the full parsed response
#'   envelope.
#'
#' @keywords internal
nhsbsa_query <- function(action, call = rlang::caller_env()) {
  caller_fn <- rlang::caller_fn()
  caller_env <- rlang::caller_env()

  return_raw <- isTRUE(rlang::env_get(
    caller_env,
    ".return_raw",
    default = FALSE
  ))
  query_params <- nhsbsa_collect_query_params(caller_fn, caller_env)

  req <- nhsbsa_base_request() |>
    httr2::req_url_path_append(action)

  if (length(query_params) > 0) {
    req <- httr2::req_url_query(req, !!!query_params)
  }

  resp <- nhsbsa_perform(req, call = call)
  body <- httr2::resp_body_json(resp)

  if (!isTRUE(body$success)) {
    nhsbsa_abort_api_error(body$error, call = call)
  }

  if (return_raw) {
    body
  } else {
    body$result
  }
}

# Assemble the base request shared by every endpoint.
nhsbsa_base_request <- function() {
  httr2::request(nhsbsa_base_url()) |>
    httr2::req_user_agent(nhsbsa_user_agent()) |>
    httr2::req_retry(max_tries = 3, is_transient = nhsbsa_is_transient) |>
    httr2::req_error(body = nhsbsa_http_error_body)
}

# Perform the request, translating transport and HTTP failures into structured
# nhsbsa conditions so the package fails gracefully (e.g. with no internet).
# Extra arguments (e.g. `path` to stream a download to disk) pass through to
# [httr2::req_perform()].
nhsbsa_perform <- function(req, ..., call = rlang::caller_env()) {
  rlang::try_fetch(
    httr2::req_perform(req, ...),
    httr2_failure = function(cnd) {
      nhsbsa_abort(
        c(
          "x" = "Could not connect to the NHSBSA Open Data Portal.",
          "i" = "Check your internet connection and that
                 {.url https://opendata.nhsbsa.net} is reachable."
        ),
        class = "nhsbsa_offline",
        call = call,
        parent = cnd
      )
    },
    httr2_http = function(cnd) {
      status <- httr2::resp_status(cnd$resp)
      nhsbsa_abort(
        c(
          "x" = "The NHSBSA Open Data Portal returned an error (HTTP {status}).",
          "i" = conditionMessage(cnd)
        ),
        class = c("nhsbsa_api_error", paste0("nhsbsa_http_", status)),
        call = call,
        parent = cnd
      )
    }
  )
}

# Enrich httr2's default HTTP error with the CKAN error payload, when present.
nhsbsa_http_error_body <- function(resp) {
  body <- tryCatch(httr2::resp_body_json(resp), error = function(e) NULL)
  error <- body$error
  if (is.null(error)) {
    return(NULL)
  }
  message <- nhsbsa_error_message(error)
  if (length(message) == 0) NULL else message
}

# Abort on a CKAN envelope reporting `success = FALSE` with an HTTP 200 status.
nhsbsa_abort_api_error <- function(error, call = rlang::caller_env()) {
  message <- nhsbsa_error_message(error)
  if (length(message) == 0) {
    message <- "Unknown error."
  }
  nhsbsa_abort(
    c(
      "x" = "The NHSBSA Open Data Portal reported an error.",
      "i" = message
    ),
    class = "nhsbsa_api_error",
    call = call
  )
}

# Extract a human-readable message from a CKAN `error` object, which may report
# a top-level `message`, a `__type`, or a set of field-specific messages.
nhsbsa_error_message <- function(error) {
  if (is.null(error)) {
    return(character(0))
  }
  if (!is.null(error$message)) {
    return(as.character(error$message))
  }
  type <- error[["__type"]]
  fields <- error[setdiff(names(error), "__type")]
  fields <- purrr::compact(fields)
  if (length(fields) > 0) {
    detail <- purrr::imap_chr(fields, function(value, name) {
      paste0(name, ": ", paste(unlist(value), collapse = "; "))
    })
    detail <- paste(detail, collapse = " ")
    return(stringr::str_trim(paste(type, detail)))
  }
  if (!is.null(type)) as.character(type) else character(0)
}

# Read the calling endpoint's arguments and turn them into CKAN query
# parameters. Arguments prefixed with "." (e.g. `.return_raw`) are reserved for
# client behaviour and never sent to the API.
nhsbsa_collect_query_params <- function(caller_fn, caller_env) {
  if (is.null(caller_fn)) {
    return(list())
  }
  arg_names <- rlang::fn_fmls_names(caller_fn)
  arg_names <- arg_names[!startsWith(arg_names, ".") & arg_names != "..."]
  if (length(arg_names) == 0) {
    return(list())
  }
  values <- rlang::env_get_list(caller_env, arg_names, default = NULL)
  values <- purrr::map(values, nhsbsa_format_query_value)
  purrr::compact(values)
}

# Coerce a single argument value into the scalar string CKAN expects: drop empty
# values, encode lists (e.g. `filters`) as JSON, lower-case logicals and collapse
# multi-element vectors (e.g. `fields`, `sort`) into a comma-separated string.
nhsbsa_format_query_value <- function(value) {
  if (is.null(value) || length(value) == 0) {
    return(NULL)
  }
  if (is.list(value)) {
    return(as.character(jsonlite::toJSON(value, auto_unbox = TRUE)))
  }
  if (is.logical(value)) {
    return(tolower(as.character(value)))
  }
  if (length(value) > 1) {
    return(paste(value, collapse = ","))
  }
  value
}

# Convert a list of CKAN records into a tibble, one row per record.
nhsbsa_records_to_tibble <- function(records) {
  if (length(records) == 0) {
    return(tibble::tibble())
  }
  records |>
    purrr::map(function(record) tibble::as_tibble(purrr::compact(record))) |>
    dplyr::bind_rows()
}
