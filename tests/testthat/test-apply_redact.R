test_that("apply_redact() applies mapping correctly", {
  set.seed(1)
  train   <- sample_tibble()
  result  <- redact(train, col_types = list(sector = "group"))
  mapping <- result$mapping

  test <- tibble::tibble(sector = c("Finance", "Tech"))
  out  <- apply_redact(test, mapping)

  train_map <- mapping$sector
  expect_equal(
    out$sector[[1]],
    train_map$redacted[train_map$original == "Finance"]
  )
  expect_equal(
    out$sector[[2]],
    train_map$redacted[train_map$original == "Tech"]
  )
})

test_that("column retains its original name after apply_redact()", {
  set.seed(2)
  result <- redact(sample_tibble(), col_types = list(sector = "group"))
  out    <- apply_redact(tibble::tibble(sector = "Tech"), result$mapping)
  expect_true("sector" %in% names(out))
})

test_that("columns not in mapping are returned unchanged", {
  set.seed(3)
  result <- redact(sample_tibble(), col_types = list(sector = "group"))
  test   <- tibble::tibble(sector = "Tech", revenue = 500)
  out    <- apply_redact(test, result$mapping)
  expect_true("revenue" %in% names(out))
  expect_equal(out$revenue, 500)
})

test_that("mapping column absent from .data emits a warning", {
  mapping <- list(nonexistent = tibble::tibble(original = "A", redacted = "B"))
  test    <- tibble::tibble(other = "X")
  expect_warning(apply_redact(test, mapping))
})

test_that("unseen values emit a warning and are left unchanged", {
  set.seed(4)
  result <- redact(sample_tibble(), col_types = list(sector = "group"))
  test   <- tibble::tibble(sector = c("Tech", "NewSector"))
  expect_warning(
    out <- apply_redact(test, result$mapping)
  )
  expect_equal(out$sector[[2]], "NewSector")
})
