test_that("redact_vec() returns a redactr_vec_result", {
  result <- redact_vec(c("A-1", "B-2"), type = "code", seed = 1)
  expect_s3_class(result, "redactr_vec_result")
  expect_named(result, c("redacted", "mapping"))
})

test_that("type attribute is set correctly", {
  result <- redact_vec(c("X", "Y"), type = "group", seed = 1)
  expect_equal(attr(result, "type"), "group")
})

test_that("invalid type raises an error", {
  expect_error(redact_vec(c("A"), type = "unknown"), class = "rlang_error")
})

test_that("seed produces reproducible results", {
  r1 <- redact_vec(c("ACC-1", "ACC-2"), type = "code", seed = 42)
  r2 <- redact_vec(c("ACC-1", "ACC-2"), type = "code", seed = 42)
  expect_equal(r1$redacted, r2$redacted)
})

test_that("bank argument is forwarded for group type", {
  set.seed(1)
  result <- redact_vec(c("X", "Y"), type = "group", bank = "colors")
  expect_true(all(result$mapping$redacted %in% .word_banks$colors))
})
