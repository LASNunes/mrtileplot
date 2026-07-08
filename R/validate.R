check_columns <- function(data, cols, data_name) {
  missing_cols <- setdiff(cols, names(data))
  
  if (length(missing_cols) > 0) {
    stop(
      data_name,
      "is missing required column(s): ",
      paste(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }
  
  invisible(TRUE)
}