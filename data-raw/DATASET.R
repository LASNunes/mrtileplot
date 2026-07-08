# data-raw/DATASET.R

# Synthetic cancer-related example for mrtileplot package.
# These data are fictional and are only intended for examples and tests.

set.seed(123)

patients <- paste0("Pt", sprintf("%02d", 1:15))

region_counts <- c(3, 4, 2, 3, 4, 2, 3, 4, 3, 2, 4, 3, 2, 4, 3)

example_regions <- data.frame(
  patient = rep(patients, times = region_counts),
  region = unlist(lapply(region_counts, function(n) paste0("Region_", seq_len(n)))),
  stringsAsFactors = FALSE
)

n_regions <- nrow(example_regions)

# Region-level discrete variable shown by default
example_regions$value <- sample(
  c("Immune_hot", "Immune_intermediate", "Immune_cold"),
  size = n_regions,
  replace = TRUE,
  prob = c(0.3, 0.45, 0.25)
)

# Region-level continuous variable useful for examples
example_regions$tumor_cell_content <- round(
  runif(n_regions, min = 0.25, max = 0.95), 
  digits = 2
)

# Patient-level annotations in wide-format
patient_annotations_wide <- data.frame(
  patient = patients,
  Cancer_Type = c(
    "Colorectal", "Colorectal", "Gastric", "Colorectal", "Lung",
    "Gastric", "Colorectal", "Lung", "Colorectal", "Gastric",
    "Lung", "Colorectal", "Gastric", "Colorectal", "Lung"
  ),
  Stage = c(
    "II", "III", "III", "IV", "II",
    "III", "I", "IV", "II", "III",
    "IV", "II", "I", "III", "II"
  ),
  Grade = c(
    "G2", "G3", "G2", "G3", "G2",
    "G3", "G1", "G3", "G2", "G2",
    "G3", "G2", "G1", "G3", "G2"
  ),
  MSI_Status = c(
    "MSS", "MSI", "MSS", "MSS", "MSS",
    "MSI", "MSS", "MSS", "MSI", "MSS",
    "MSS", "MSI", "MSS", "MSS", "MSS"
  ),
  Treatment_Response = c(
    "Responder", "Non_responder", "Stable", "Non_responder", "Responder",
    "Stable", "Responder", "Non_responder", "Responder", "Stable",
    "Non_responder", "Responder", "Stable", "Non_responder", "Responder"
  ),
  stringsAsFactors = FALSE
)

# Convert to long format for mrtileplot
example_annotations <- reshape(
  patient_annotations_wide,
  varying = list(names(patient_annotations_wide)[-1]),
  v.names = "value",
  timevar = "annotation",
  times = names(patient_annotations_wide)[-1],
  idvar = "patient",
  direction = "long"
)

row.names(example_annotations) <- NULL

example_annotations <- example_annotations[
  order(example_annotations$patient, example_annotations$annotation),
  c("patient", "annotation", "value")
]

usethis::use_data(example_regions, example_annotations, overwrite = TRUE)
