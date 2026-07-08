derive_patient_order <- function(annotation_data,
                                 patient,
                                 annotation,
                                 annotation_value,
                                 sort_by,
                                 sort_levels = list()){
  
  sort_data <- annotation_data |>
    dplyr::select(
      patient = .data[[patient]],
      annotation = .data[[annotation]],
      value = .data[[annotation_value]]
    ) |>
    tidyr::pivot_wider(
      names_from = "annotation",
      values_from = "value"
    )
  
  for (var in sort_by) {
    if(!var %in% names(sort_data)) {
      stop("Sorting variable not found in annotation_data: ", var, call. = FALSE)
    }
    
    if (!is.null(sort_levels[[var]])) {
      sort_data[[var]] <- factor(sort_data[[var]], levels = sort_levels[[var]], ordered = TRUE)
    }
  }
  
  sort_data |>
    dplyr::arrange(dplyr::across(dplyr::all_of(sort_by))) |>
    dplyr::pull(patient)
}