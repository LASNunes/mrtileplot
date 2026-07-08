add_fill_scale <- function(p, 
                           data,
                           scale_name,
                           palette = NULL,
                           na_colour = "grey90") {
  is_continuous <- is.numeric(data$value)
  
  if (is_continuous) {
    if (is.null(palette)) {
      p <- p +
        ggplot2::scale_fill_gradient(
          name = scale_name,
          na.value = na_colour
          )
      } else {
        p <- p +
          ggplot2::scale_fill_gradient(
            name = scale_name,
            low = palette[[1]],
            high = palette[[length(palette)]],
            na.value = na_colour
          )
        }
    } else {
      p <- p +
        ggplot2::scale_fill_manual(
          name = scale_name,
          values = palette,
          na.value = na_colour
        )
    }
  
  p
}

get_annotation_palette <- function(annotation_name,
                                   annotation_palettes = NULL,
                                   palette = NULL) {
  if (!is.null(annotation_palettes) && !is.null(annotation_palettes[[annotation_name]])) {
    return(annotation_palettes[[annotation_name]])
  }
  
  palette
}