derive_patient_order <- function(annotation_data,
                                 patient,
                                 annotation,
                                 annotation_value,
                                 sort_by,
                                 sort_levels = list(),
                                 region_long = NULL,
                                 region_count_sort = c("last", "after_region", "none")) {
  region_count_sort <- match.arg(region_count_sort)
  
  sort_pieces = list()
  sort_cols = character()
  
  if (!is.null(region_long)){
    region_keys <- region_long |>
      dplyr::arrange(.data$patient, .data$region_index) |>
      dplyr::group_by(.data$patient) |>
      dplyr::summarise(
        .region_primary_sort = dplyr::first(.data$region_sort_value),
        .n_regions = dplyr::n(),
        .groups = "drop"
        )
    
    sort_cols <- c(sort_cols, ".region_primary_sort")
    
    if (region_count_sort == "after_region") {
      region_keys <- region_keys |>
        dplyr::mutate(.n_regions_desc = -1 * .data$.n_regions)
      
      sort_cols <- c(sort_cols, ".n_regions_desc")
    }
    
    sort_pieces[[length(sort_pieces) + 1]] <- region_keys
  }
  
  if (!is.null(sort_by) && length(sort_by) > 0) {
    if(is.null(annotation_data)) {
      stop("`annotation_data` must be supplied when using `sort_by`.", call. = FALSE)
    }
    
    annotation_keys <- annotation_data |>
      dplyr::select(
        patient = .data[[patient]],
        annotation = .data[[annotation]],
        value = .data[[annotation_value]]) |>
      tidyr::pivot_wider(
        names_from = "annotation",
        values_from = "value",
        values_fn = list(value = function(x) x[1]))
    
    for (var in sort_by) {
      if (!var %in% names(annotation_keys)) {
        stop("sorting variable not found in annotation_data: ", var, call. = FALSE)
        }
      
      if (!is.null(sort_levels[[var]])) {
        annotation_keys[[var]] <- factor(
          annotation_keys[[var]],
          levels = sort_levels[[var]],
          ordered = TRUE)
      }
    }
    
    sort_pieces[[length(sort_pieces) + 1]] <- annotation_keys
    sort_cols <- c(sort_cols, sort_by)
  }  
  
  if (length(sort_pieces) == 0) {
    stop("No sorting variables were supplied.", call. = FALSE)
  }
  
  sort_data <- sort_pieces[[1]]
  
  if (length(sort_pieces) > 1) {
    for (i in seq(2, length(sort_pieces))) {
      sort_data <- dplyr::left_join(sort_data, sort_pieces[[i]], by = "patient")
    }
  }
  
  if (region_count_sort == "last" && ".n_regions" %in% names(sort_data)) {
    sort_cols <- c(sort_cols, ".n_regions")
  }
  
  sort_cols <- sort_cols[sort_cols %in% names(sort_data)]
  
  sort_data <- sort_data |>
    dplyr::arrange(dplyr::across(dplyr::all_of(sort_cols)))
  
  dplyr::pull(sort_data, "patient")
}