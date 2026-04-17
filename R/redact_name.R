# Name redaction.
#
# Each unique non-NA value is replaced with a fake-but-realistic name drawn
# from the bundled first/last name banks. Three name formats are detected
# per-value:
#   "First Last"   -> fake "First Last"
#   "Last, First"  -> fake "Last, First"
#   single token   -> fake first name only

# ---- Internal helpers ---------------------------------------------------

detect_name_format <- function(x) {
  dplyr::case_when(
    grepl(",", x, fixed = TRUE)  ~ "last_first",
    grepl(" ", x, fixed = TRUE)  ~ "first_last",
    TRUE                          ~ "single"
  )
}

generate_fake_name <- function(fmt) {
  first <- sample(.first_names, 1L)
  last  <- sample(.last_names,  1L)

  switch(fmt,
    first_last = paste(first, last),
    last_first = paste0(last, ", ", first),
    single     = first
  )
}

# Ensure generated names are unique by regenerating on collisions.
generate_fake_names_unique <- function(formats) {
  n <- length(formats)
  result <- character(n)
  used   <- character(0L)

  for (i in seq_len(n)) {
    candidate <- generate_fake_name(formats[[i]])
    attempts  <- 0L
    while (candidate %in% used) {
      candidate <- generate_fake_name(formats[[i]])
      attempts  <- attempts + 1L
      if (attempts > 500L) {
        rlang::abort(
          "Could not generate enough unique fake names. The name banks may be exhausted.",
          call = NULL
        )
      }
    }
    result[[i]] <- candidate
    used <- c(used, candidate)
  }

  result
}

# ---- Package-internal vectorised function -------------------------------

# Returns list(redacted = chr_vec, mapping = tibble(original, redacted))
redact_name_vec <- function(x) {
  unique_vals <- unique(x[!is.na(x)])
  formats     <- detect_name_format(unique_vals)
  fake_names  <- generate_fake_names_unique(formats)

  mapping <- tibble::tibble(
    original = unique_vals,
    redacted = fake_names
  )

  list(
    redacted = apply_lookup(x, mapping),
    mapping  = mapping
  )
}
