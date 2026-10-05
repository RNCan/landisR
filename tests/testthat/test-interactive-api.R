testthat::test_that("interactive API constructors are available", {
  engine <- landis_growth_biomass52()
  testthat::expect_s3_class(engine, "landisR_growth_engine")
  testthat::expect_identical(engine$id, "biomass52")

  update <- landis_update(metadata = list(source = "test"))
  testthat::expect_s3_class(update, "landisR_update")
  testthat::expect_identical(update$format, "landisR/update-v1")
})
