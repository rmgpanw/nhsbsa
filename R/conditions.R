#' nhsbsa condition constructors *(internal helpers)*
#'
#' Internal helpers for constructing structured nhsbsa error, warning and
#' informational conditions.
#'
#' These wrap the corresponding `cli` signalling functions
#' ([cli::cli_abort()], [cli::cli_warn()], [cli::cli_inform()]) and always
#' append an nhsbsa-specific base class (`nhsbsa_error`, `nhsbsa_warning`,
#' `nhsbsa_message`).
#'
#' Additional custom classes may be optionally prepended via the `class`
#' argument, allowing callers to test for and handle specific conditions
#' programmatically.
#'
#' The original named `cli` message vector is stored in `cli_message` so a
#' condition can be re-thrown to reproduce an identical message (see examples).
#'
#' @inheritParams cli::cli_abort
#' @param class Optional character vector of additional classes to prepend
#'   before the nhsbsa base class.
#' @param ... Passed through to the underlying `cli` signalling function.
#' @param call Call environment (only used by [nhsbsa_abort()]).
#'
#' @keywords internal
#' @name conditions
#' @examples
#' # These are internal helpers, so the example is not run.
#' \dontrun{
#' # Capture an nhsbsa error condition and inspect it
#' dataset_id <- "does-not-exist"
#'
#' named_cli_message_vector <- c(
#'   x = "Dataset {.val {dataset_id}} was not found.",
#'   i = "List available datasets with `nhsbsa_package_list()`."
#' )
#'
#' e <- tryCatch(
#'   nhsbsa_abort(
#'     named_cli_message_vector,
#'     class = "nhsbsa_dataset_not_found"
#'   ),
#'   error = function(cnd) cnd
#' )
#'
#' # Inspect the condition class hierarchy
#' class(e)
#'
#' # Inspect the stored structured `cli` message
#' e$cli_message
#'
#' # Inspect the default formatted condition message
#' conditionMessage(e)
#' }
NULL

#' @rdname conditions
nhsbsa_abort <- function(
  message,
  class = NULL,
  ...,
  call = rlang::caller_env(),
  .envir = rlang::caller_env()
) {
  message_interpolated <- nhsbsa_interpolate_message(message, .envir)
  cli::cli_abort(
    message_interpolated,
    class = c(class, "nhsbsa_error"),
    call = call,
    cli_message = message_interpolated,
    ...,
    .envir = .envir
  )
}

#' @rdname conditions
nhsbsa_warn <- function(
  message,
  class = NULL,
  ...,
  .envir = rlang::caller_env()
) {
  message_interpolated <- nhsbsa_interpolate_message(message, .envir)
  cli::cli_warn(
    message_interpolated,
    class = c(class, "nhsbsa_warning"),
    cli_message = message_interpolated,
    ...,
    .envir = .envir
  )
}

#' @rdname conditions
nhsbsa_inform <- function(
  message,
  class = NULL,
  ...,
  .envir = rlang::caller_env()
) {
  message_interpolated <- nhsbsa_interpolate_message(message, .envir)
  cli::cli_inform(
    message_interpolated,
    class = c(class, "nhsbsa_message"),
    cli_message = message_interpolated,
    ...,
    .envir = .envir
  )
}

# Interpolate a named `cli` message vector up front, so the resulting strings
# can be stored on the condition and reused.
nhsbsa_interpolate_message <- function(
  message,
  .envir = rlang::caller_env()
) {
  vapply(
    message,
    cli::format_inline,
    character(1),
    .envir = .envir
  )
}
