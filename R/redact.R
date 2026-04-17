#' Redact a tibble
#'
#' Anonymizes selected columns in a data frame or tibble. Each target column
#' is replaced in-place under its original name. A mapping table is stored for
#' `"code"`, `"group"`, and `"name"` columns so that the same substitutions can
#' be applied to related files with [apply_redact()].
#'
#' @param .data A data frame or tibble.
#' @param col_types A named list (or named character vector) specifying the
#'   redaction type for each column to anonymize. Names must match column
#'   names in `.data`. Valid types:
#'   - `"code"` / [col_code()]: format-preserving code substitution.
#'   - `"group"` / [col_group()]: thematic word-bank substitution.
#'   - `"name"` / [col_name()]: realistic fake-name substitution.
#'   - `"numeric"` / [col_numeric()]: within-column random permutation.
#'   - `"skip"` / [col_skip()]: leave column unchanged (default for any
#'     column not mentioned).
#'   - [col_formula()]: recompute the column from an R expression evaluated
#'     against the already-redacted data (e.g. `col_formula(~ alloc + selec)`).
#'     Formula columns are processed after all other types and no mapping is
#'     stored for them.
#' @param seed Optional integer seed passed to [set.seed()] for
#'   reproducibility. Applied once before any column is processed.
#'
#' @return An object of class `redactr_result` (a list) with elements:
#'   - `$data`: a tibble with redacted columns replaced in-place under their
#'     original names. Assign the result to a new object to preserve the
#'     original data alongside the redacted copy.
#'   - `$mapping`: a named list with one entry per `"code"`, `"group"`, or
#'     `"name"` column, each a [tibble::tibble()] with `original` and
#'     `redacted` columns. `"numeric"` and `col_formula()` columns are not
#'     present in `$mapping` — numerics because their shuffle is row-specific
#'     and non-transferable, formula columns because they are derived rather
#'     than independently anonymized.
#'   - `$columns`: character vector of all column names that were redacted or
#'     recomputed (i.e. every column listed in `col_types` except `"skip"`).
#'
#' @export
#' @examples
#' set.seed(42)
#' dat <- tibble::tibble(
#'   account_id = c("ACC-001", "ACC-002", "ACC-003"),
#'   sector     = c("Tech", "Finance", "Tech"),
#'   revenue    = c(100, 200, 150),
#'   manager    = c("Alice Brown", "Bob Smith", "Carol Jones")
#' )
#'
#' result <- redact(
#'   dat,
#'   col_types = list(
#'     account_id = "code",
#'     sector     = "group",
#'     revenue    = "numeric",
#'     manager    = "name"
#'   )
#' )
#'
#' result$data
#' result$mapping
#'
#' # Use col_formula() to keep derived columns consistent with their sources.
#' # alloc and selec are shuffled independently; tot_attr is then recomputed
#' # as alloc + selec so the relationship is preserved in the redacted data.
#' set.seed(1)
#' attr_dat <- tibble::tibble(
#'   alloc    = c( 0.10,  0.20, -0.05,  0.15),
#'   selec    = c( 0.05, -0.03,  0.08,  0.02),
#'   tot_attr = c( 0.15,  0.17,  0.03,  0.17)
#' )
#'
#' attr_result <- redact(
#'   attr_dat,
#'   col_types = list(
#'     alloc    = "numeric",
#'     selec    = "numeric",
#'     tot_attr = col_formula(~ alloc + selec)
#'   )
#' )
#'
#' attr_result$data
#' # tot_attr equals alloc + selec in the redacted output
#' all.equal(attr_result$data$tot_attr,
#'           attr_result$data$alloc + attr_result$data$selec)
redact <- function(.data, col_types, seed = NULL) {
  if (!is.data.frame(.data)) {
    rlang::abort(
      "`redact()` requires a data frame or tibble as `.data`.",
      call = rlang::caller_env()
    )
  }

  if (!is.null(seed)) set.seed(seed)

  spec     <- parse_col_spec(col_types, names(.data))
  mapping  <- list()
  columns  <- character(0L)
  out      <- tibble::as_tibble(.data)

  # First pass: independent redaction types (code, group, name, numeric).
  for (col in names(spec)) {
    type_spec <- spec[[col]]
    type      <- type_spec$type

    if (type %in% c("skip", "formula")) next

    col_result <- switch(type,
      code    = redact_code_vec(out[[col]]),
      group   = redact_group_vec(out[[col]], bank = type_spec$bank %||% "auto"),
      name    = redact_name_vec(out[[col]]),
      numeric = redact_numeric_vec(out[[col]])
    )

    out[[col]] <- col_result$redacted
    columns    <- c(columns, col)

    if (!is.null(col_result$mapping)) {
      mapping[[col]] <- col_result$mapping
    }
  }

  # Second pass: formula columns, evaluated against the redacted data.
  for (col in names(spec)) {
    type_spec <- spec[[col]]
    if (type_spec$type != "formula") next

    out[[col]] <- eval(type_spec$expr, envir = as.list(out))
    columns    <- c(columns, col)
  }

  structure(
    list(data = out, mapping = mapping, columns = columns),
    class = "redactr_result"
  )
}

# Null-coalescing operator (rlang exports it but we keep a local fallback)
`%||%` <- function(x, y) if (is.null(x)) y else x
