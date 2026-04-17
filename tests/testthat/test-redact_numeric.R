test_that("same length is returned", {
  x      <- c(10, 20, 30, 40, 50)
  result <- redact_numeric_vec(x)
  expect_equal(length(result$redacted), 5L)
})

test_that("the same set of values is returned (just permuted)", {
  set.seed(1)
  x      <- c(10, 20, 30, 40, 50)
  result <- redact_numeric_vec(x)
  expect_equal(sort(result$redacted), sort(x))
})

test_that("NA positions are preserved as NA", {
  x      <- c(1, NA, 3, NA, 5)
  result <- redact_numeric_vec(x)
  expect_true(is.na(result$redacted[[2]]))
  expect_true(is.na(result$redacted[[4]]))
})

test_that("non-NA values are permuted among non-NA positions", {
  set.seed(2)
  x      <- c(1, NA, 3, NA, 5)
  result <- redact_numeric_vec(x)
  non_na_result <- result$redacted[!is.na(result$redacted)]
  expect_equal(sort(non_na_result), c(1, 3, 5))
})

test_that("mapping is NULL for numeric", {
  result <- redact_numeric_vec(c(1, 2, 3))
  expect_null(result$mapping)
})

test_that("values are actually shuffled (not just returned as-is)", {
  # With 100 values the probability of a perfect identity permutation is ~0
  set.seed(42)
  x      <- 1:100
  result <- redact_numeric_vec(x)
  expect_false(identical(result$redacted, x))
})
