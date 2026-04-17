# Numeric redaction via within-column random permutation.
#
# NA values remain NA and are excluded from the shuffle. The distribution of
# observed values is fully preserved; only their row assignments change.
# No mapping is stored because the shuffle is one-directional: it cannot be
# meaningfully re-applied to a different dataset.

# ---- Package-internal vectorised function -------------------------------

# Returns list(redacted = numeric_vec, mapping = NULL)
redact_numeric_vec <- function(x) {
  non_na_idx       <- which(!is.na(x))
  perm             <- sample(non_na_idx)
  result           <- x
  result[non_na_idx] <- x[perm]

  list(redacted = result, mapping = NULL)
}
