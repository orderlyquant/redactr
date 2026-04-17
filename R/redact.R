#' Redact a tibble
#'
#' Anonymizes selected columns in a data frame or tibble. Each target column
#' is replaced in-place by a redacted version whose name carries the `_rdct`
#' suffix. A mapping table is stored for every non-numeric column so that the
#' same substitutions can be applied to related files with [apply_redact()].
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
#' @param seed Optional integer seed passed to [set.seed()] for
#'   reproducibility. Applied once before any column is processed.
#'
#' @return An object of class `redactr_result` (a list) with elements:
#'   - `$data`: a tibble with redacted columns replaced in-place under their
#'     original names. Assign the result to a new object to preserve the
#'     original data alongside the redacted copy.
#'   - `$mapping`: a named list, one entry per redacted non-numeric column,
#'     each a [tibble::tibble()] with `original` and `redacted` columns.
#'   - `$columns`: character vector of all column names that were redacted.
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

  for (col in names(spec)) {
    type_spec <- spec[[col]]
    type      <- type_spec$type

    if (type == "skip") next

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

  structure(
    list(data = out, mapping = mapping, columns = columns),
    class = "redactr_result"
  )
}

# Null-coalescing operator (rlang exports it but we keep a local fallback)
`%||%` <- function(x, y) if (is.null(x)) y else x
