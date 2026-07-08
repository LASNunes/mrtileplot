#' Example multiregional region data
#' 
#' A small synthetic dataset showing one row per patient-region pair.
#' This dataset is used in examples and tests for `mr_tileplot()`.
#' 
#' @format A data frame with 6 rows and 3 columns:
#' \describe{
#'  \item{patient}{Patient or tumor identifier.}
#'  \item{region}{Region or sample identifier, such as `"T1"` or `"T2"`.}
#'  \item{value}{Discrete value to use as tile fill.}
#'}
#'
#' @examples
#' data(example_regions)
#' head(example_regions)
"example_regions"

#' Example patient annotation data
#' 
#' A small synthetic dataset showing one row per patient-annotation pair.
#' This dataset is used to add patient-level annotation tracks to `mr_tileplot()`.
#' 
#' @format A data frame with 9 rows and 3 columns:
#' \describe{
#'  \item{patient}{Patient or tumor identifier.}
#'  \item{annotation}{Annotation track name, such as `"Gender"` or `"Stage"`.}
#'  \item{value}{Discrete annotation value to use as tile fill.}
#' }
#' 
#' @examples
#' data(example_annotations)
#' head(example_annotations)
"example_annotations"