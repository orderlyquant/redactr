# Shared internal utilities.

# Apply a lookup table (tibble with `original` and `redacted` columns) to
# a vector x. Values not found in the mapping are returned unchanged.
# NA inputs produce NA outputs.
apply_lookup <- function(x, mapping) {
  idx    <- match(x, mapping$original)
  result <- mapping$redacted[idx]

  # Preserve NAs from x; keep unmatched values as-is
  is_na_x      <- is.na(x)
  is_unmatched <- is.na(idx) & !is_na_x

  result[is_na_x]      <- NA
  result[is_unmatched] <- x[is_unmatched]

  result
}
