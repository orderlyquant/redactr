#' Redact a single vector
#'
#' Anonymizes a character or numeric vector according to the specified
#' redaction type and returns both the redacted values and a mapping table
#' (where applicable).
#'
#' @param x A vector to redact.
#' @param type Redaction type. One of:
#'   - `"code"`: format-preserving substitution (alpha and numeric tokens
#'     replaced independently, separators preserved).
#'   - `"group"`: each unique value is mapped to a word from a thematic word
#'     bank.
#'   - `"name"`: each unique value is replaced with a fake-but-realistic name.
#'   - `"numeric"`: values are randomly permuted within the vector,
#'     preserving the distribution.
#' @param bank For `type = "group"` only: which word bank to draw from.
#'   One of `"auto"` (pool all banks) or a specific bank name from
#'   [word_bank_names()].
#' @param seed Optional integer seed for reproducibility.
#'
#' @return A list of class `redactr_vec_result` with elements:
#'   - `$redacted`: the anonymized vector (same length and type as `x`).
#'   - `$mapping`: a [tibble::tibble()] with columns `original` and `redacted`
#'     for `"code"`, `"group"`, and `"name"` types; `NULL` for `"numeric"`.
#'
#' @export
#' @examples
#' set.seed(1)
#' result <- redact_vec(c("ACC-001", "ACC-002", "ACC-003"), type = "code")
#' result$redacted
#' result$mapping
#'
#' set.seed(2)
#' result <- redact_vec(c("Tech", "Finance", "Energy"), type = "group")
#' result$redacted
#'
#' set.seed(3)
#' result <- redact_vec(c(10, 20, 30, 40, 50), type = "numeric")
#' result$redacted  # same values, different order
redact_vec <- function(x, type, bank = "auto", seed = NULL) {
  type <- rlang::arg_match(
    type,
    c("code", "group", "name", "numeric"),
    error_call = rlang::caller_env()
  )

  if (!is.null(seed)) set.seed(seed)

  result <- switch(type,
    code    = redact_code_vec(x),
    group   = redact_group_vec(x, bank = bank),
    name    = redact_name_vec(x),
    numeric = redact_numeric_vec(x)
  )

  structure(result, type = type, class = "redactr_vec_result")
}
