testthat::test_that("generic coupling constructors are available", {
  caps <- landis_capabilities(landis_growth_biomass52())
  testthat::expect_s3_class(caps, "landisR_capabilities")
  testthat::expect_true(landis_supports(caps, "engine.biomass52"))
  testthat::expect_true(landis_supports(caps, "update.cohorts"))
  testthat::expect_false(landis_supports(caps, "engine.pnet"))

  modifier <- landis_modifier(
    fun = function(context) NULL,
    name = "test_modifier"
  )
  testthat::expect_s3_class(modifier, "landisR_modifier")
  testthat::expect_true(is.function(modifier))
})
