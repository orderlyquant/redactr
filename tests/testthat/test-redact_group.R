test_that("unique count is preserved", {
  set.seed(1)
  x      <- c("Tech", "Finance", "Energy", "Tech", NA)
  result <- redact_group_vec(x)
  expect_equal(
    length(unique(result$redacted[!is.na(result$redacted)])),
    3L
  )
})

test_that("NA values are preserved", {
  x      <- c("A", NA, "B")
  result <- redact_group_vec(x)
  expect_true(is.na(result$redacted[[2]]))
})

test_that("mapping has correct columns", {
  set.seed(2)
  x      <- c("X", "Y", "Z")
  result <- redact_group_vec(x)
  expect_named(result$mapping, c("original", "redacted"))
  expect_equal(nrow(result$mapping), 3L)
})

test_that("consistent mapping: same original -> same redacted", {
  set.seed(3)
  x      <- c("A", "B", "A", "C", "B")
  result <- redact_group_vec(x)
  expect_equal(result$redacted[[1]], result$redacted[[3]])
  expect_equal(result$redacted[[2]], result$redacted[[5]])
})

test_that("specific bank argument is respected", {
  set.seed(4)
  x      <- c("X", "Y", "Z")
  result <- redact_group_vec(x, bank = "colors")
  expect_true(all(result$mapping$redacted %in% .word_banks$colors))
})

test_that("too many unique values raises an error", {
  # colors bank has ~40 words; request more unique values
  x <- paste0("val_", seq_len(50))
  expect_error(redact_group_vec(x, bank = "colors"), class = "rlang_error")
})
