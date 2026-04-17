# ---- col_formula() constructor ------------------------------------------

test_that("col_formula() accepts a one-sided formula", {
  spec <- col_formula(~ alloc + selec)
  expect_s3_class(spec, "redactr_col_spec")
  expect_equal(spec$type, "formula")
  expect_true(!is.null(spec$expr))
})

test_that("col_formula() accepts a string", {
  spec <- col_formula("alloc + selec")
  expect_s3_class(spec, "redactr_col_spec")
  expect_equal(spec$type, "formula")
})

test_that("col_formula() rejects a two-sided formula", {
  expect_error(col_formula(y ~ alloc + selec), class = "rlang_error")
})

test_that("col_formula() rejects unsupported input types", {
  expect_error(col_formula(42), class = "rlang_error")
})

# ---- Integration with redact() ------------------------------------------

test_that("formula column is recomputed from redacted values", {
  set.seed(42)
  dat <- tibble::tibble(
    alloc    = c(0.10, 0.20, -0.05, 0.15),
    selec    = c(0.05, -0.03, 0.08, 0.02),
    tot_attr = c(0.15, 0.17,  0.03, 0.17)   # alloc + selec
  )

  result <- redact(
    dat,
    col_types = list(
      alloc    = "numeric",
      selec    = "numeric",
      tot_attr = col_formula(~ alloc + selec)
    )
  )

  expect_equal(
    result$data$tot_attr,
    result$data$alloc + result$data$selec
  )
})

test_that("formula column works with a string expression", {
  set.seed(1)
  dat <- tibble::tibble(
    alloc    = c(0.10, 0.20, -0.05),
    selec    = c(0.05, -0.03, 0.08),
    tot_attr = alloc + selec
  )

  result <- redact(
    dat,
    col_types = list(
      alloc    = "numeric",
      selec    = "numeric",
      tot_attr = col_formula("alloc + selec")
    )
  )

  expect_equal(result$data$tot_attr, result$data$alloc + result$data$selec)
})

test_that("formula column supports more complex expressions", {
  set.seed(7)
  dat <- tibble::tibble(
    wgt  = c(0.3, 0.5, 0.2),
    ret  = c(5.0, -2.0, 3.0),
    contrib = wgt * ret
  )

  result <- redact(
    dat,
    col_types = list(
      wgt    = "numeric",
      ret    = "numeric",
      contrib = col_formula(~ wgt * ret)
    )
  )

  expect_equal(result$data$contrib, result$data$wgt * result$data$ret)
})

test_that("formula column appears in result$columns", {
  set.seed(2)
  dat <- tibble::tibble(
    alloc    = c(0.1, 0.2),
    selec    = c(0.05, -0.03),
    tot_attr = alloc + selec
  )

  result <- redact(
    dat,
    col_types = list(
      alloc    = "numeric",
      selec    = "numeric",
      tot_attr = col_formula(~ alloc + selec)
    )
  )

  expect_true("tot_attr" %in% result$columns)
})

test_that("formula column is NOT stored in result$mapping", {
  set.seed(3)
  dat <- tibble::tibble(
    alloc    = c(0.1, 0.2),
    selec    = c(0.05, -0.03),
    tot_attr = alloc + selec
  )

  result <- redact(
    dat,
    col_types = list(
      alloc    = "numeric",
      selec    = "numeric",
      tot_attr = col_formula(~ alloc + selec)
    )
  )

  expect_false("tot_attr" %in% names(result$mapping))
})

test_that("formula column can reference an un-redacted (skip) column", {
  set.seed(4)
  dat <- tibble::tibble(
    wgt      = c(0.3, 0.5, 0.2),   # skip — not redacted
    act_ret  = c(5.0, -2.0, 3.0),
    contrib  = wgt * act_ret
  )

  result <- redact(
    dat,
    col_types = list(
      act_ret = "numeric",
      contrib = col_formula(~ wgt * act_ret)
    )
  )

  # wgt is original; act_ret is shuffled; contrib = original_wgt * shuffled_ret
  expect_equal(result$data$contrib, dat$wgt * result$data$act_ret)
})

test_that("formula preserves column names (original names kept)", {
  set.seed(5)
  dat <- tibble::tibble(
    a = c(1, 2, 3),
    b = c(4, 5, 6),
    c = a + b
  )

  result <- redact(
    dat,
    col_types = list(
      a = "numeric",
      b = "numeric",
      c = col_formula(~ a + b)
    )
  )

  expect_named(result$data, c("a", "b", "c"))
})
