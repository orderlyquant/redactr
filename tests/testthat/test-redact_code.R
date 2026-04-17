test_that("redact_code_vec returns same length", {
  x      <- c("ACC-001", "ACC-002", NA, "XYZ-999")
  result <- redact_code_vec(x)
  expect_equal(length(result$redacted), length(x))
})

test_that("NA values are preserved", {
  x      <- c("ACC-001", NA, "ACC-002")
  result <- redact_code_vec(x)
  expect_true(is.na(result$redacted[[2]]))
})

test_that("format is preserved (same token structure)", {
  set.seed(1)
  x      <- c("ACC-1234", "XYZ-5678")
  result <- redact_code_vec(x)
  # Each result should match the pattern: 3 uppercase letters, dash, 4 digits
  expect_true(all(grepl("^[A-Z]{3}-[0-9]{4}$", result$redacted)))
})

test_that("redacted values differ from originals", {
  set.seed(99)
  x <- paste0("CODE-", 1:20)
  result <- redact_code_vec(x)
  # With 20 codes it's astronomically unlikely all are unchanged
  expect_false(all(result$redacted == x))
})

test_that("mapping has correct columns and same unique count", {
  x      <- c("A1", "B2", "A1", NA)
  result <- redact_code_vec(x)
  expect_named(result$mapping, c("original", "redacted"))
  expect_equal(nrow(result$mapping), 2L)  # two unique non-NA values
})

test_that("consistent mapping: same original -> same redacted", {
  x      <- c("ACC-001", "ACC-002", "ACC-001")
  result <- redact_code_vec(x)
  expect_equal(result$redacted[[1]], result$redacted[[3]])
  expect_false(result$redacted[[1]] == result$redacted[[2]])
})

test_that("purely numeric codes preserve length", {
  set.seed(5)
  x      <- c("12345", "99999")
  result <- redact_code_vec(x)
  expect_true(all(nchar(result$redacted) == 5L))
})

test_that("separators are preserved", {
  set.seed(7)
  x      <- "AB/12/CD"
  result <- redact_code_vec(x)
  # Slashes should stay; alpha and numeric tokens change
  parts <- strsplit(result$redacted, "/")[[1]]
  expect_equal(length(parts), 3L)
  expect_equal(nchar(parts[[1]]), 2L)
  expect_equal(nchar(parts[[2]]), 2L)
  expect_equal(nchar(parts[[3]]), 2L)
})
