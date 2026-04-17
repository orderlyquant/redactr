# Format-preserving code redaction.
#
# Strategy: tokenize each value into alternating alpha / numeric / separator
# runs, then replace alpha runs with random letters (preserving case pattern)
# and numeric runs with random digits (preserving length and leading-zero
# behaviour). Separators are kept intact. The mapping from original → redacted
# is stored so the same substitution can be applied across files.

# ---- Internal helpers ---------------------------------------------------

# Split a string into a character vector of tokens, where each token is
# either a run of letters, a run of digits, or a run of non-alphanumeric
# characters (separators).
tokenize_code <- function(x) {
  stringr::str_extract_all(x, "[A-Za-z]+|[0-9]+|[^A-Za-z0-9]+")[[1]]
}

redact_alpha_token <- function(tok) {
  chars <- strsplit(tok, "")[[1]]
  new_chars <- vapply(chars, function(ch) {
    if (ch == toupper(ch)) sample(LETTERS, 1L) else sample(letters, 1L)
  }, character(1L))
  paste(new_chars, collapse = "")
}

redact_numeric_token <- function(tok) {
  n <- nchar(tok)
  if (n == 1L) {
    return(as.character(sample(0:9, 1L)))
  }
  # Preserve whether the original starts with a non-zero digit
  if (substr(tok, 1L, 1L) != "0") {
    first <- sample(1:9, 1L)
    rest  <- sample(0:9, n - 1L, replace = TRUE)
    paste0(first, paste(rest, collapse = ""))
  } else {
    # Original has a leading zero; keep the same digit count freely
    paste(sample(0:9, n, replace = TRUE), collapse = "")
  }
}

redact_single_code <- function(code) {
  if (is.na(code)) return(NA_character_)
  tokens <- tokenize_code(code)
  new_tokens <- vapply(tokens, function(tok) {
    if (grepl("^[0-9]+$", tok)) {
      redact_numeric_token(tok)
    } else if (grepl("^[A-Za-z]+$", tok)) {
      redact_alpha_token(tok)
    } else {
      tok  # separator: preserve exactly
    }
  }, character(1L))
  paste(new_tokens, collapse = "")
}

# ---- Package-internal vectorised function -------------------------------

# Returns list(redacted = chr_vec, mapping = tibble(original, redacted))
redact_code_vec <- function(x) {
  unique_vals <- unique(x[!is.na(x)])

  subs <- stats::setNames(
    vapply(unique_vals, redact_single_code, character(1L)),
    unique_vals
  )

  mapping <- tibble::tibble(
    original = names(subs),
    redacted = unname(subs)
  )

  list(
    redacted = apply_lookup(x, mapping),
    mapping  = mapping
  )
}
