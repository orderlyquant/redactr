# S3 print methods for redactr result objects.

#' @export
print.redactr_result <- function(x, n = 6L, ...) {
  map_cols <- names(x$mapping)

  cli::cli_h1("redactr result")
  cli::cli_text(
    "Data: {nrow(x$data)} row{?s} \u00d7 {ncol(x$data)} column{?s}"
  )
  if (length(x$columns) > 0L) {
    cli::cli_text("Redacted columns: {.val {x$columns}}")
  }
  if (length(map_cols) > 0L) {
    cli::cli_text("Mapping stored for: {.val {map_cols}}")
  }
  cli::cli_rule()
  print(x$data, n = n, ...)
  invisible(x)
}

#' @export
print.redactr_vec_result <- function(x, ...) {
  type <- attr(x, "type")
  cli::cli_h1("redactr vector result [{type}]")
  cli::cli_text("Length: {length(x$redacted)}")
  if (!is.null(x$mapping)) {
    cli::cli_text("Mapping: {nrow(x$mapping)} unique value{?s}")
  } else {
    cli::cli_text("Mapping: none (numeric shuffle)")
  }
  cli::cli_rule()
  cli::cli_text("{.strong Redacted values:}")
  print(x$redacted)
  invisible(x)
}
