test_that("public API is exported", {
  expected <- c(
    "landis_read",
    "landis_build",
    "landis_from_canonical",
    "landis_write_canonical",
    "landis_run",
    "landis_compare"
  )

  exported <- getNamespaceExports("landisR")
  expect_true(all(expected %in% exported))
})
