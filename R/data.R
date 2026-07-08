#' Synthetic multiregional cancer region data
#' 
#' A fictional cancer-related dataset with multiple sampled regions per patient.
#' Each row represents one tumor region from one patient. The dataset includes
#' one discrete region-level variable, stored in `value`, and additional continuous
#' region-level variable that can be used for sorting or alternative fill value. 
#' 
#' @format A data frame with 45 rows and 4 columns:
#' \describe{
#'  \item{patient}{Patient identifier.}
#'  \item{region}{Original region or sample identifier.}
#'  \item{value}{Discrete region-level immune phenotype.}
#'  \item{tumor_cell_content}{Continuous tumor cell content between 0 and 1.}
#'}
#'
#' @source Synthetic data generated for package examples.
#' 
#' @examples
#' head(example_regions)
"example_regions"

#' Synthetic cancer data
#' 
#' A fictional cancer-related patient annotation dataset. Each row represents
#' one patient-level clinicopathological annotation.
#' 
#' @format A data frame with 75 rows and 3 columns:
#' \describe{
#'  \item{patient}{Patient or tumor identifier.}
#'  \item{annotation}{Annotation track name.}
#'  \item{value}{Annotation value.}
#' }
#' 
#' @source Synthetic data generated for package examples.
#' 
#' @examples
#' head(example_annotations)
"example_annotations"