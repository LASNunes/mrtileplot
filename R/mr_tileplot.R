#' Draw a multiregional tile plot
#' 
#' Creates a tile plot where columns are tumors or patients, rows are regions
#' and optional annotation tracks, and tile fill represents a discrete value.
#' 
#' @importFrom rlang .data
#' 
#' @param region_data A data frame with one row per patient-region pair.
#' @param annotation_data Optional data frame with one row per patient-annotation pair.
#' @param patient Column name identifying the patient or tumor.
#' @param region Column name identifying the region or sample.
#' @param value Column name containing the region value to plot.
#' @param annotation Column name identifying annotation tracks.
#' @param annotation_value Column name containing the annotation values.
#' @param patient_order Optional character vector defining patient order.
#' @param region_order Optional character vector defining region order.
#' @param annotation_order Optional character vector defining annotation row order.
#' @param sort_by Optional character vector of annotation names used to sort patients. 
#' Only used when `annotation_data` is supplied and `patient_order` is `NULL`.
#' @param sort_levels Optional named list giving the desired order of values for
#' each variable in `sort_by`.
#' @param palette Optional named vector of colors.
#' @param tile_colour Border colour for tiles.
#' @param na_colour Colour for missing values.
#' 
#' @return A ggplot object.
#' @export
#' 
#' @examples
#' # Example data
#' region_data <- data.frame(
#'  patient = rep(c("Patient1", "Patient2"), each = 3),
#'  region = rep(c("Region1", "Region2", "Region3"), times = 2),
#'  value = c("A", "A", "B", "B", "B", "C")
#' )
#' 
#' annotation_data <- data.frame(
#' patient = rep(c("Patient1", "Patient2"), each = 2),
#' annotation = rep(c("Annotation1", "Annotation2"), times = 2),
#' annotation_value = c("X", "Y", "Y", "Z")
#' )
#' 
#' mr_tileplot(region_data, annotation_data)
mr_tileplot <- function(region_data,
                        annotation_data = NULL,
                        patient = "patient",
                        region = "region",
                        value = "value",
                        annotation = "annotation",
                        annotation_value = "annotation_value",
                        patient_order = NULL,
                        region_order = NULL,
                        annotation_order = NULL,
                        sort_by = NULL,
                        sort_levels = list(),
                        palette = NULL,
                        tile_colour = "black",
                        na_colour = "grey90") {
  
  check_columns(region_data, c(patient, region, value), "region_data")
  
  if (!is.null(annotation_data)) {
    check_columns(annotation_data, c(patient, annotation, annotation_value), "annotation_data")
  }
  
  region_long <- region_data |>
    dplyr::transmute(
      patient = .data[[patient]],
      row = .data[[region]],
      value = .data[[value]],
      row_type = "region"
    )
  
  if (!is.null(annotation_data)) {
    annotation_long <- annotation_data |>
      dplyr::transmute(
        patient = .data[[patient]],
        row = .data[[annotation]],
        value = .data[[annotation_value]],
        row_type = "annotation"
      )
    
    plot_data <- dplyr::bind_rows(annotation_long, region_long)
  } else {
    annotation_long <- NULL
    plot_data <- region_long
  }
  
  if (is.null(patient_order) && !is.null(sort_by)) {
    if (is.null(annotation_data)) {
      stop("`annotation_data` must be supplied wjen using `sort_by`.", call. = FALSE)
    }
    
    patient_order <- derive_patient_order(
      annotation_data = annotation_data,
      patient = patient, 
      annotation = annotation,
      annotation_value = annotation_value,
      sort_by = sort_by,
      sort_levels = sort_levels
    )
  }
    
  if (is.null(patient_order)) {
    patient_order <- unique(plot_data$patient)
  }
  
  if (is.null(region_order)) {
    region_order <- unique(region_long$row)
  }
  
  if (is.null(annotation_order) && !is.null(annotation_long)) {
    annotation_order <- unique(annotation_long$row)
  }
  
  row_order <- c(annotation_order, region_order)
  
  plot_data$patient <- factor(plot_data$patient, levels = patient_order)
  plot_data$row <- factor(plot_data$row, levels = row_order)
  
  p <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = patient, y = row, fill = value)
  ) +
    ggplot2::geom_tile(colour = tile_colour) +
    ggplot2::coord_fixed() +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_text(
        angle = 90,
        hjust = 1,
        vjust = 0.5
      )
    ) +
    ggplot2::labs(x = NULL, y = NULL, fill = NULL)
  
  if (!is.null(palette)) {
    p <- p + 
      ggplot2::scale_fill_manual(values = palette, na.value = na_colour)
  }
  
  p
}
