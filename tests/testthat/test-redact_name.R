test_that("same length is returned", {
  set.seed(1)
  x      <- c("Alice Brown", "Bob Smith", NA)
  result <- redact_name_vec(x)
  expect_equal(length(result$redacted), 3L)
})

test_that("NA values are preserved", {
  x      <- c("Alice Brown", NA)
  result <- redact_name_vec(x)
  expect_true(is.na(result$redacted[[2]]))
})

test_that("first-last format is preserved", {
  set.seed(2)
  x      <- c("Alice Brown", "Bob Smith")
  result <- redact_name_vec(x)
  expect_true(all(grepl(" ", result$redacted)))
  expect_false(any(grepl(",", result$redacted)))
})

test_that("last-first format is preserved", {
  set.seed(3)
  x      <- c("Brown, Alice", "Smith, Bob")
  result <- redact_name_vec(x)
  expect_true(all(grepl(",", result$redacted)))
})

test_that("consistent mapping: same original -> same redacted", {
  set.seed(4)
  x      <- c("Alice Brown", "Bob Smith", "Alice Brown")
  result <- redact_name_vec(x)
  expect_equal(result$redacted[[1]], result$redacted[[3]])
})

test_that("fake names differ from originals", {
  set.seed(5)
  x      <- c("Alice Brown", "Bob Smith", "Carol Jones")
  result <- redact_name_vec(x)
  expect_false(all(result$redacted == x))
})

test_that("unique fake names are generated", {
  set.seed(6)
  x      <- paste("Person", 1:10, "Smith")
  result <- redact_name_vec(x)
  expect_equal(length(unique(result$redacted)), 10L)
})
