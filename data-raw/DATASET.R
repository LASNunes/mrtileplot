example_regions <- data.frame(
  patient = c("P1", "P1", "P1", "P2", "P2", "P3", "P4", "P4"),
  region = c("T1", "T2", "T3", "T1", "T2", "T1", "T1", "T2"),
  value = c("Pos", "Neg", "Neg", "Pos", "Neg", "Neg", "Pos", "Pos")
)

example_annotations <- data.frame(
  patient = c("P1", "P1", "P1", "P2", "P2", "P2", "P3", "P3", "P3", "P4", "P4", "P4"),
  annotation = c(
    "Gender", "Stage", "Location",
    "Gender", "Stage", "Location",
    "Gender", "Stage", "Location",
    "Gender", "Stage", "Location"
  ),
  annotation_value = c(
    "Female", "Stage II", "Right colon",
    "Male", "Stage III", "Left colon",
    "Male", "Stage I", "Rectum",
    "Female", "Stage III", "Right colon"
  )
)

usethis::use_data(example_regions, example_annotations, overwrite = TRUE)
