# Column specification constructors and parser.
#
# col_types in redact() / redact_vec() accepts either a plain string
# ("code", "group", "name", "numeric", "skip") or a col_*() object for
# cases where extra options are needed (e.g. col_group(bank = "animals"),
# col_formula(~ alloc + selec)).

# Valid types for plain-string shorthand (formula requires col_formula())
.valid_types <- c("code", "group", "name", "numeric", "skip")

# ---- Constructors -------------------------------------------------------

#' Column type specifications for redact()
#'
#' Use these constructors in the `col_types` argument of [redact()] when you
#' need to pass options beyond the default.  Plain strings `"code"`,
#' `"group"`, `"name"`, `"numeric"`, and `"skip"` are also accepted as
#' shorthand for the no-option constructors.
#'
#' `col_formula()` is special: it does not anonymize a column independently.
#' Instead, it recomputes the column from an R expression evaluated against
#' the already-redacted data.  This lets you preserve arithmetic relationships
#' between columns — for example, when `tot_attr = alloc + selec`, redacting
#' `alloc` and `selec` independently and then recomputing `tot_attr` keeps the
#' column internally consistent.  Formula columns are always evaluated in a
#' second pass, after all independent redaction types have been applied.
#'
#' @param bank For `col_group()`: which thematic word bank to draw
#'   substitutes from.  One of `"auto"` (pool all banks), `"colors"`,
#'   `"animals"`, `"tools"`, `"automobiles"`, or `"mascots"`.  See
#'   [word_bank_names()] for the current list.
#' @param expr For `col_formula()`: a one-sided R formula whose right-hand
#'   side is an expression referencing other column names, e.g.
#'   `~ alloc + selec`.  A plain string such as `"alloc + selec"` is also
#'   accepted.  The expression is evaluated with the (partially) redacted
#'   tibble as the data environment, so any base-R or imported function is
#'   available (e.g. `~ round(alloc + selec, 6)`).
#'
#' @return An object of class `redactr_col_spec` (a named list).
#' @name col_types
#' @examples
#' # Plain strings are shorthand for the no-option constructors:
#' # col_types = list(account_id = "code", sector = "group")
#'
#' # Use col_group() to pick a specific word bank:
#' # col_types = list(sector = col_group(bank = "animals"))
#'
#' # Use col_formula() to recompute a derived column after redaction:
#' # col_types = list(
#' #   alloc    = "numeric",
#' #   selec    = "numeric",
#' #   tot_attr = col_formula(~ alloc + selec)
#' # )
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

#' @rdname col_types
#' @export
col_formula <- function(expr) {
  if (inherits(expr, "formula")) {
    if (length(expr) != 2L) {
      rlang::abort(
        "`col_formula()` requires a one-sided formula, e.g. `~ alloc + selec`.",
        call = rlang::caller_env()
      )
    }
    call_expr <- rlang::f_rhs(expr)
  } else if (is.character(expr) && length(expr) == 1L) {
    call_expr <- str2lang(expr)
  } else {
    rlang::abort(
      c(
        "`expr` must be a one-sided formula or a string.",
        "i" = 'Examples: `col_formula(~ alloc + selec)` or `col_formula("alloc + selec")`.'
      ),
      call = rlang::caller_env()
    )
  }
  new_col_spec("formula", expr = call_expr)
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
