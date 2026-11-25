add_fill_scale <- function(p, 
                           data,
                           scale_name,
                           palette = NULL,
                           na_colour = "grey90",
                           legend_order = 1,
                           legend_values = NULL) {
  is_continuous <- is.numeric(data$value)
  
  if (is_continuous) {
    if (is.null(palette)) {
      return(
        p +
          ggplot2::scale_fill_gradient(
            name = scale_name,
            na.value = na_colour,
            guide = ggplot2::guide_colourbar(
              direction = "vertical",
              title.position = "top",
              order = legend_order
              )
            )
        )
      
    } 
    
    return(
      p +
        ggplot2::scale_fill_gradient(
          name = scale_name,
          low = palette[[1]],
          high = palette[[length(palette)]],
          na.value = na_colour,
          guide = ggplot2::guide_colourbar(
            direction = "vertical",
            title.position = "top",
            order = legend_order
          )
        )
    )
  }
  
  if (is.null(legend_values)) {
    if (!is.null(palette) && !is.null(names(palette))) {
      legend_values <- names(palette)
    } else {
      legend_values <- unique(as.character(data$value))
    }
  }
  
  if (is.null(palette)) {
    return(
      p +
        ggplot2::scale_fill_discrete(
          name = scale_name,
          limits = legend_values,
          breaks = legend_values,
          na.value = na_colour,
          drop = FALSE,
          guide = ggplot2::guide_legend(
            direction = "vertical",
            ncol = 1,
            byrow = TRUE,
            title.position = "top",
            order = legend_order
          )
        )
    )
  }
  
  p +
    ggplot2::scale_fill_manual(
      name = scale_name,
      values = palette,
      limits = legend_values,
      breaks = legend_values,
      na.value = na_colour,
      drop = FALSE,
      guide = ggplot2::guide_legend(
        direction = "vertical",
        ncol = 1,
        byrow = TRUE,
        title.position = "top",
        order = legend_order
      )
    )
}

get_annotation_palette <- function(annotation_name,
                                   annotation_palettes = NULL,
                                   palette = NULL) {
  if (!is.null(annotation_palettes) && !is.null(annotation_palettes[[annotation_name]])) {
    return(annotation_palettes[[annotation_name]])
  }
  
  palette
}

get_legend_values <- function(data,
                              palette = NULL,
                              levels = NULL) {
  data_values <- unique(as.character(data$value))
  
  if (!is.null(levels)) {
    return(levels[levels %in% data_values])
  }
  
  if (!is.null(palette) && !is.null(names(palette))) {
    return(names(palette)[names(palette) %in% data_values])
  }
  
  data_values
}

draw_key_diagonal <- function(data, params, size) {
  grid::grobTree(
    grid::rectGrob(
      gp = grid::gpar(
        fill = NA,
        col = data$colour,
        lwd = 0.5
      )
    ),
    grid::segmentsGrob(
      x0 = 0,
      y0 = 0,
      x1 = 1,
      y1 = 1,
      gp = grid::gpar(
        col = data$colour,
        lwd = 1.5
      )
    )
  )
}