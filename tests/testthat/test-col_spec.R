test_that("plain strings are normalized to col_spec objects", {
  spec <- parse_col_spec(
    list(a = "code", b = "group", c = "name", d = "numeric", e = "skip"),
    c("a", "b", "c", "d", "e")
  )
  expect_true(all(vapply(spec, inherits, logical(1), "redactr_col_spec")))
  expect_equal(spec[["a"]]$type, "code")
  expect_equal(spec[["e"]]$type, "skip")
})

test_that("col_*() constructors produce correct objects", {
  expect_equal(col_code()$type,    "code")
  expect_equal(col_group()$type,   "group")
  expect_equal(col_group()$bank,   "auto")
  expect_equal(col_name()$type,    "name")
  expect_equal(col_numeric()$type, "numeric")
  expect_equal(col_skip()$type,    "skip")
})

test_that("col_group() accepts valid bank names", {
  expect_equal(col_group(bank = "animals")$bank, "animals")
  expect_error(col_group(bank = "invalid"), class = "rlang_error")
})

test_that("columns absent from col_types default to skip", {
  spec <- parse_col_spec(list(a = "code"), c("a", "b", "c"))
  expect_equal(spec[["b"]]$type, "skip")
  expect_equal(spec[["c"]]$type, "skip")
})

test_that("unknown column names in col_types raise an error", {
  expect_error(
    parse_col_spec(list(z = "code"), c("a", "b")),
    class = "rlang_error"
  )
})

test_that("NULL col_types means all skip", {
  spec <- parse_col_spec(NULL, c("a", "b"))
  expect_true(all(vapply(spec, function(s) s$type == "skip", logical(1))))
})
