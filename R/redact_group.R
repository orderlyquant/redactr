# Grouping-variable redaction.
#
# Each unique non-NA value is mapped to a distinct word drawn from a thematic
# word bank. The mapping is stored for cross-file consistency.

# ---- Internal helpers ---------------------------------------------------

draw_bank_words <- function(n, bank = "auto", call = rlang::caller_env()) {
  pool <- if (bank == "auto") {
    unlist(.word_banks, use.names = FALSE)
  } else {
    bank <- rlang::arg_match(bank, word_bank_names(), error_call = call)
    .word_banks[[bank]]
  }

  if (n > length(pool)) {
    rlang::abort(
      c(
        "Need {n} unique word{?s} but bank {.val {bank}} only has {length(pool)}.",
        "i" = 'Use bank = "auto" to pool all {sum(lengths(.word_banks))} words.'
      ),
      call = call
    )
  }

  sample(pool, n, replace = FALSE)
}

# ---- Package-internal vectorised function -------------------------------

# Returns list(redacted = chr_vec, mapping = tibble(original, redacted))
redact_group_vec <- function(x, bank = "auto") {
  unique_vals <- unique(x[!is.na(x)])
  words       <- draw_bank_words(length(unique_vals), bank = bank)

  mapping <- tibble::tibble(
    original = unique_vals,
    redacted = words
  )

  list(
    redacted = apply_lookup(x, mapping),
    mapping  = mapping
  )
}
