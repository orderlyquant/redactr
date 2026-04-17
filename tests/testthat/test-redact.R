test_that("redact() returns a redactr_result", {
  result <- redact(sample_tibble(), col_types = list(account_id = "code"), seed = 1)
  expect_s3_class(result, "redactr_result")
  expect_named(result, c("data", "mapping", "columns"))
})

test_that("redacted column retains its original name", {
  result <- redact(sample_tibble(), col_types = list(account_id = "code"), seed = 1)
  expect_true("account_id" %in% names(result$data))
})

test_that("result$columns lists all redacted column names", {
  set.seed(7)
  result <- redact(
    sample_tibble(),
    col_types = list(
      account_id = "code",
      sector     = "group",
      revenue    = "numeric",
      manager    = "name"
    )
  )
  expect_setequal(result$columns, c("account_id", "sector", "revenue", "manager"))
})

test_that("skip columns are left intact", {
  result <- redact(
    sample_tibble(),
    col_types = list(account_id = "code"),
    seed = 1
  )
  expect_true("revenue" %in% names(result$data))
  expect_equal(result$data$revenue, sample_tibble()$revenue)
})

test_that("all four types can be processed together", {
  set.seed(7)
  result <- redact(
    sample_tibble(),
    col_types = list(
      account_id = "code",
      sector     = "group",
      revenue    = "numeric",
      manager    = "name"
    )
  )
  expect_true(all(c("account_id", "sector", "revenue", "manager") %in% names(result$data)))
})

test_that("mapping is stored for code, group, name but not numeric", {
  set.seed(8)
  result <- redact(
    sample_tibble(),
    col_types = list(
      account_id = "code",
      sector     = "group",
      revenue    = "numeric",
      manager    = "name"
    )
  )
  expect_named(result$mapping, c("account_id", "sector", "manager"), ignore.order = TRUE)
  expect_false("revenue" %in% names(result$mapping))
})

test_that("column order is preserved", {
  result <- redact(sample_tibble(), col_types = list(sector = "group"), seed = 3)
  expect_equal(names(result$data), names(sample_tibble()))
})

test_that("seed produces reproducible output", {
  r1 <- redact(sample_tibble(), col_types = list(sector = "group"), seed = 99)
  r2 <- redact(sample_tibble(), col_types = list(sector = "group"), seed = 99)
  expect_equal(r1$data, r2$data)
})

test_that("non-data-frame input raises an error", {
  expect_error(redact(list(a = 1), col_types = list(a = "code")), class = "rlang_error")
})

test_that("unknown column in col_types raises an error", {
  expect_error(
    redact(sample_tibble(), col_types = list(nonexistent = "code")),
    class = "rlang_error"
  )
})
