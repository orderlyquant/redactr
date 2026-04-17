# Column specification constructors and parser.
#
# col_types in redact() / redact_vec() accepts either a plain string
# ("code", "group", "name", "numeric", "skip") or a col_*() object for
# cases where extra options are needed (e.g. col_group(bank = "animals")).

.valid_types <- c("code", "group", "name", "numeric", "skip")

# ---- Constructors -------------------------------------------------------

#' Column type specifications for redact()
#'
#' Use these constructors in the `col_types` argument of [redact()] when you
#' need to pass options beyond the default.  Plain strings `"code"`,
#' `"group"`, `"name"`, `"numeric"`, and `"skip"` are also accepted as
#' shorthand.
#'
#' @param bank For `col_group()`: which thematic word bank to draw
#'   substitutes from.  One of `"auto"` (pool all banks), `"colors"`,
#'   `"animals"`, `"tools"`, `"automobiles"`, or `"mascots"`.  See
#'   [word_bank_names()] for the current list.
#'
#' @return An object of class `redactr_col_spec` (a named list).
#' @name col_types
#' @examples
#' # Plain strings are shorthand for the defaults:
#' # col_types = list(account_id = "code", sector = "group")
#'
#' # Use col_group() to pick a specific word bank:
#' # col_types = list(sector = col_group(bank = "animals"))
NULL

#' @rdname col_types
#' @export
col_code <- function() {
  new_col_spec("code")
}

#' @rdname col_types
#' @export
col_group <- function(bank = "auto") {
  bank <- rlang::arg_match(
    bank,
    c("auto", word_bank_names()),
    error_call = rlang::caller_env()
  )
  new_col_spec("group", bank = bank)
}

#' @rdname col_types
#' @export
col_name <- function() {
  new_col_spec("name")
}

#' @rdname col_types
#' @export
col_numeric <- function() {
  new_col_spec("numeric")
}

#' @rdname col_types
#' @export
col_skip <- function() {
  new_col_spec("skip")
}

new_col_spec <- function(type, ...) {
  structure(list(type = type, ...), class = "redactr_col_spec")
}

# ---- Parser -------------------------------------------------------------

# Returns a named list of redactr_col_spec objects for every column in
# data_cols. Columns absent from col_types default to col_skip().
parse_col_spec <- function(col_types, data_cols, call = rlang::caller_env()) {
  if (is.null(col_types)) {
    return(stats::setNames(
      rep(list(new_col_spec("skip")), length(data_cols)),
      data_cols
    ))
  }

  col_types <- as.list(col_types)

  if (is.null(names(col_types)) || any(names(col_types) == "")) {
    rlang::abort("All entries in `col_types` must be named.", call = call)
  }

  unknown <- setdiff(names(col_types), data_cols)
  if (length(unknown) > 0) {
    rlang::abort(
      c(
        "Unknown column{?s} in `col_types`: {.val {unknown}}.",
        "i" = "Available columns: {.val {data_cols}}"
      ),
      call = call
    )
  }

  normalized <- lapply(col_types, normalize_one_spec, call = call)

  stats::setNames(
    lapply(data_cols, function(col) {
      if (col %in% names(normalized)) normalized[[col]] else new_col_spec("skip")
    }),
    data_cols
  )
}

normalize_one_spec <- function(spec, call = rlang::caller_env()) {
  if (inherits(spec, "redactr_col_spec")) {
    return(spec)
  }
  if (is.character(spec) && length(spec) == 1L) {
    type <- rlang::arg_match(spec, .valid_types, error_call = call)
    return(new_col_spec(type))
  }
  rlang::abort(
    paste0(
      "Each entry in `col_types` must be a string or a `col_*()` object, ",
      "not {.cls {class(spec)}}."
    ),
    call = call
  )
}
