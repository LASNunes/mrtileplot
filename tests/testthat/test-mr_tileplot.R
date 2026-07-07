test_that("mr_tileplot returns a ggplot object", {
  region_data <- data.frame(
    patient = rep(c("Patient1", "Patient2"), each = 3),
    region = rep(c("Region1", "Region2", "Region3"), times = 2),
    value = c("A", "A", "B", "B", "B", "C")
  )
  
  p <- mr_tileplot(region_data)
  
  expect_s3_class(p, "ggplot")
})
