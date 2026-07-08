make_sort_value <- function(x, levels = NULL, decreasing = FALSE) {
  if (!is.null(levels)) {
    if (decreasing) {
      levels <- rev(levels)
    }
    
    return(factor(x, levels = levels, ordered = TRUE))
  }
  
  if (is.numeric(x)) {
    if (decreasing) {
      return(-x)
    }
    
    return(x)
  }
  
  x <- as.character(x)
  levels <- sort(unique(x))
  
  if (decreasing) {
    levels <- rev(levels)
  }
  
  factor(x, levels = levels, ordered = TRUE)
}

prepare_region_tiles <- function(region_data,
                                 patient,
                                 region,
                                 value,
                                 region_sort_by = NULL,
                                 region_sort_levels = NULL,
                                 region_sort_decreasing = FALSE,
                                 region_prefix = "T") {
  if (!is.null(region_sort_by)) {
    check_columns(region_data, region_sort_by, "region_data")
  }
  
  region_long <- region_data |>
    dplyr::mutate(
      .patient = .data[[patient]],
      .original_region = .data[[region]],
      .value = .data[[value]]
    )
  
  if (!is.null(region_sort_by)) {
    region_long <- region_long |>
      dplyr::mutate(
        .region_sort_raw = .data[[region_sort_by]],
        .region_sort_value = make_sort_value(
          .region_sort_raw,
          levels = region_sort_levels,
          decreasing = region_sort_decreasing
        )
      ) |>
      dplyr::arrange(
        .data$.patient,
        .data$.region_sort_value,
        .data$.original_region) |>
      dplyr::group_by(.data$.patient) |>
      dplyr::mutate(
        .region_index = dplyr::row_number(),
        .row = paste0(region_prefix, .region_index)
      ) |>
      dplyr::ungroup()
  } else {
    region_order <- unique(region_long$.original_region)
    
    region_long <- region_long |>
      dplyr::mutate(
        .region_sort_raw = .data$.original_region,
        .region_sort_value = .data$.original_region,
        .row = as.character(.data$.original_region),
        .region_index = match(
          as.character(.data$.original_region),
          as.character(region_order)
        )
      )
  }
  
  region_long |>
    dplyr::transmute(
      patient = .data$.patient,
      row = .data$.row,
      value = .data$.value,
      row_type = "region",
      original_region = .data$.original_region,
      region_sort_raw = .data$.region_sort_raw,
      region_sort_value = .data$.region_sort_value,
      region_index = .data$.region_index
    )
}