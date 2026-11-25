#' Draws a tile plot of regions and annotations for multiple patients or tumors.
#' 
#' Creates a tile plot where each patient or tumor is represented by a column, 
#' and each region or annotation is represented by a row. The function allows 
#' for sorting of patients and regions based on specified criteria, and supports 
#' custom color palettes for both regions and annotations.
#' 
#' @importFrom rlang .data
#' 
#' @param region_data A data frame with one row per patient-region pair.
#' @param annotation_data Optional data frame with one row per patient-annotation pair.
#' @param patient Column name identifying the patient or tumor.
#' @param region Column name identifying the region or sample.
#' @param region_value Column name containing the region value to plot.
#' @param annotation Column name identifying annotation tracks.
#' @param annotation_value Column name containing the annotation values.
#' @param patient_order Optional character vector defining patient order.
#' @param region_order Optional character vector defining region order.
#' @param annotation_order Optional character vector defining annotation row order.
#' @param region_sort_by Optional column name in `region_data` used to sort regions 
#' within each patient. When supplied, plotted region names are rewritten as 
#' consecutive names such as `"T1"`, `"T2"`, etc.
#' @param region_sort_levels Optional character vector defining the order of a
#' categorical `region_sort_by` variable.
#' @param region_sort_decreasing Logical indicating whether regions should be 
#' sorted in decreasing order.
#' @param region_count_sort Character string indicating how to sort patients when
#' @param sort_patients_by_regions Logical. If `TRUE`, region sorting also contributes
#' to patient sorting. If `FALSE`, regions are sorted within each patient, but patient
#' order is determined only by `patient_order`, annotation string, or the original data order.
#' `region_sort_by` is supplied. `"last"` to sort by region count only after 
#' region and annotation sorting, or `"none"` to ignore region count. 
#' @param region_prefix Prefix for region names when `region_sort_by` is supplied.
#' @param region_diagonal Optional column containing TRUE/FALSE values indicating which
#' regional should receive a diagonal.
#' @param region_diagonal_label Label for the diagonal legend.
#' @param region_diagonal_colour Colour for the diagonal legend.
#' @param sort_by Optional character vector of annotation names used to sort 
#' patients after region sorting. 
#' @param sort_levels Optional named list giving the desired order of values for
#' each variable in `sort_by`.
#' @param gap Numeric size of the visual gap between region rows and annotation rows.
#' @param region_palette Optional named vector for region values, or two colours
#' for a continuous region scale.
#' @param annotation_palettes Optional named list of palettes, one per annotation.
#' @param palette Optional named vector of colors.
#' @param tile_colour Border colour for tiles.
#' @param na_colour Colour for missing values.
#' 
#' @return A ggplot object.
#' @export
#' 
#' @examples
#' mr_tileplot(region_data = example_regions, 
#'             annotation_data = example_annotations)
mr_tileplot <- function(region_data,
                        annotation_data = NULL,
                        patient = "patient",
                        region = "region",
                        region_value = "value",
                        annotation = "annotation",
                        annotation_value = "value",
                        patient_order = NULL,
                        region_order = NULL,
                        annotation_order = NULL,
                        region_sort_by = NULL,
                        region_sort_levels = NULL,
                        region_sort_decreasing = FALSE,
                        region_count_sort = c("last", "after_region", "none"),
                        sort_patients_by_regions = TRUE,
                        region_prefix = "T",
                        region_diagonal = NULL,
                        region_diagonal_label = "High expression",
                        region_diagonal_colour = "black",
                        sort_by = NULL,
                        sort_levels = list(),
                        gap = 0.35,
                        region_palette = NULL,
                        annotation_palettes = NULL,
                        palette = NULL,
                        tile_colour = "black",
                        na_colour = "grey90") {
  
  check_columns(region_data, c(patient, region, region_value), "region_data")
  
  if (!is.null(annotation_data)) {
    check_columns(annotation_data, c(patient, annotation, annotation_value), "annotation_data")
  }
  
  region_count_sort <- match.arg(region_count_sort)
  
  region_long <- prepare_region_tiles(
    region_data = region_data,
    patient = patient,
    region = region,
    value = region_value,
    region_sort_by = region_sort_by,
    region_sort_levels = region_sort_levels,
    region_sort_decreasing = region_sort_decreasing,
    region_prefix = region_prefix,
    region_diagonal = region_diagonal
  )
  
  if (!is.null(annotation_data)) {
    annotation_long <- annotation_data |>
      dplyr::transmute(
        patient = .data[[patient]],
        row = .data[[annotation]],
        value = .data[[annotation_value]],
        row_type = "annotation"
      )
  } else {
    annotation_long <- NULL
  }
  
  use_region_patient_sort <- !is.null(region_sort_by) && isTRUE(sort_patients_by_regions)
  
  use_annotation_patient_sort <- !is.null(sort_by) && length(sort_by) > 0
  
  if (is.null(patient_order) && (use_region_patient_sort || use_annotation_patient_sort)) {
    patient_order <- derive_patient_order(
      annotation_data = annotation_data,
      patient = patient, 
      annotation = annotation,
      annotation_value = annotation_value,
      sort_by = sort_by,
      sort_levels = sort_levels,
      region_long = if (use_region_patient_sort) region_long else NULL,
      region_count_sort = region_count_sort
    )
  }
    
  if (is.null(patient_order)) {
    patient_order <- unique(region_data[[patient]])
    
    if (!is.null(annotation_data)) {
      patient_order <- unique(c(patient_order, annotation_data[[patient]]))
    }
  }
  
  if (is.null(region_order)) {
    if (!is.null(region_sort_by)) {
      max_region <- max(region_long$region_index, na.rm = TRUE)
      region_order <- paste0(region_prefix, seq_len(max_region))
    } else {
      region_order <- unique(region_long$row)
    }
  }
  
  if (is.null(annotation_order) && !is.null(annotation_long)) {
    annotation_order <- unique(annotation_long$row)
  }
  
  if (is.null(annotation_order)) {
    annotation_order <- character()
  }
  
  n_annotations <- length(annotation_order)
  
  region_positions <- data.frame(
    row = region_order,
    y = seq_along(region_order) + n_annotations + gap
  )
  
  annotation_positions <- data.frame(
    row = annotation_order,
    y = n_annotations - seq_along(annotation_order) + 1
  )
  
  patient_positions <- data.frame(
    patient = patient_order,
    x = seq_along(patient_order)
  )
  
  region_plot <- region_long |>
    dplyr::left_join(patient_positions, by = "patient") |>
    dplyr::left_join(region_positions, by = "row")
  
  if (!is.null(annotation_long)) {
    annotation_plot <- annotation_long |>
      dplyr::left_join(patient_positions, by = "patient") |>
      dplyr::left_join(annotation_positions, by = "row")
  } else {
    annotation_plot <- NULL
  }
  
  y_breaks <- dplyr::bind_rows(region_positions, annotation_positions) |>
    dplyr::arrange(.data$y)
  
  if (is.null(region_palette)){
    region_palette <- palette
  }
  
  p <- ggplot2::ggplot()
  
  p <- p +
    ggplot2::geom_tile(
      data = region_plot,
      ggplot2::aes(x = .data$x, 
                   y = .data$y, 
                   fill = .data$value),
      colour = tile_colour, 
      width = 1, 
      height = 1
      )
  
  region_legend_values <- get_legend_values(
    data = region_plot,
    palette = region_palette,
    levels = region_sort_levels
  )
  
  p <- add_fill_scale(p,
                      data = region_plot,
                      scale_name = region_value,
                      palette = region_palette,
                      na_colour = na_colour,
                      legend_order = 1,
                      legend_values = region_legend_values
                      )
  
  if (!is.null(region_diagonal)) {
    diagonal_data <- region_plot |>
      dplyr::filter(.data$diagonal == TRUE)
    
    p <- p +
      ggplot2::geom_segment(
        data = diagonal_data,
        ggplot2::aes(
          x = .data$x -0.5,
          xend = .data$x + 0.5,
          y = .data$y - 0.5,
          yend = .data$y + 0.5,
          linetype = region_diagonal_label
        ),
        colour = region_diagonal_colour,
        linewidth = 1,
        key_glyph = draw_key_diagonal,
        show.legend = TRUE
      ) +
      ggplot2::scale_linetype_manual(
        name = NULL,
        values = stats::setNames("solid", region_diagonal_label),
        guide = ggplot2::guide_legend(order = 99)
      )
  }
    
  if (!is.null(annotation_plot)) {
    for (ann in annotation_order) {
      ann_data <- annotation_plot |>
        dplyr::filter(.data$row == ann)
        
      ann_palette <- get_annotation_palette(
        annotation_name = ann,
        annotation_palettes = annotation_palettes,
        palette = palette
      )
        
      p <- p +
        ggnewscale::new_scale_fill() +
        ggplot2::geom_tile(
          data = ann_data,
          ggplot2::aes(x = .data$x, 
                       y = .data$y, 
                       fill = .data$value),
          colour = tile_colour, 
          width = 1, 
          height = 1
          )
      
      ann_legend_values <- get_legend_values(
        data = ann_data,
        palette = ann_palette,
        levels = sort_levels[[ann]]
      )
      
      p <- add_fill_scale(p,
                          data = ann_data,
                          scale_name = ann,
                          palette = ann_palette,
                          na_colour = na_colour,
                          legend_order = match(ann, annotation_order) + 1,
                          legend_values = ann_legend_values
      )
    }
  }
  
  p +
    ggplot2::scale_x_continuous(
      breaks = patient_positions$x,
      labels = patient_positions$patient,
      expand = ggplot2::expansion(add = 0.6)
    ) +
    ggplot2::scale_y_continuous(
      breaks = y_breaks$y,
      labels = y_breaks$row,
      expand = ggplot2::expansion(add = 0.6)
    ) +
    ggplot2::coord_fixed() +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      axis.title.x = ggplot2::element_blank(),
      
      legend.position = "bottom",
      legend.box = "horizontal",
      legend.direction = "vertical",
      legend.box.just = "left",
      legend.title = ggplot2::element_text(size = 10, face = "bold"),
      legend.text = ggplot2::element_text(size = 10),
      legend.spacing.x = ggplot2::unit(0.4, "cm"),
      legend.key.size = ggplot2::unit(0.35, "cm")
    )
}
