#' Apply a saved redaction mapping to a new dataset
#'
#' Re-uses the substitution tables produced by a previous [redact()] call to
#' anonymize the same columns in a different data frame. This ensures that the
#' same original value always maps to the same redacted value across files.
#'
#' Only columns present in `mapping` are processed; any other columns are
#' returned unchanged. Numeric columns are not covered by `mapping` (their
#' permutation is row-specific) — pass those columns through a fresh
#' [redact()] call if needed.
#'
#' Values in `.data` that were not seen during the original [redact()] call
#' are left unchanged and a warning is issued.
#'
#' @param .data A data frame or tibble containing at least the columns named
#'   in `mapping`.
#' @param mapping A named list of tibbles as returned in `$mapping` by
#'   [redact()]. Each element must have `original` and `redacted` columns.
#'
#' @return A tibble with the mapped columns replaced in-place under their
#'   original names, analogous to the output of [redact()].
#'
#' @export
#' @examples
#' set.seed(1)
#' train <- tibble::tibble(
#'   sector  = c("Tech", "Finance", "Energy"),
#'   revenue = c(100, 200, 300)
#' )
#' result <- redact(train, col_types = list(sector = "group", revenue = "numeric"))
#'
#' test <- tibble::tibble(
#'   sector  = c("Finance", "Tech"),
#'   revenue = c(150, 250)
#' )
#' apply_redact(test, result$mapping)
apply_redact <- function(.data, mapping) {
  if (!is.data.frame(.data)) {
    rlang::abort(
      "`apply_redact()` requires a data frame or tibble as `.data`.",
      call = rlang::caller_env()
    )
  }
  if (!is.list(mapping)) {
    rlang::abort(
      "`mapping` must be a list as returned by `redact()$mapping`.",
      call = rlang::caller_env()
    )
  }

  out <- tibble::as_tibble(.data)

  for (col in names(mapping)) {
    if (!col %in% names(out)) {
      cli::cli_warn(
        "Column {.val {col}} is in `mapping` but not in `.data`; skipping."
      )
      next
    }

    m            <- mapping[[col]]
    unseen_mask  <- !is.na(out[[col]]) & !(out[[col]] %in% m$original)

    if (any(unseen_mask)) {
      unseen <- unique(out[[col]][unseen_mask])
      cli::cli_warn(
        c(
          "{length(unseen)} value{?s} in column {.val {col}} were not in the original mapping.",
          "i" = "Unseen value{?s}: {.val {unseen}}. These rows are left unchanged."
        )
      )
    }

    out[[col]] <- apply_lookup(out[[col]], m)
  }

  out
}
