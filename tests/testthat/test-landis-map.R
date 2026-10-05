test_that("landis_map maps a generic cell-level data.frame", {
  x <- data.frame(
    cell_id = 1:4,
    row = c(1L, 2L, 1L, 2L),
    col = c(1L, 1L, 2L, 2L),
    value = c(10, 20, 30, 40)
  )

  m <- landis_map(
    x,
    variable = "value",
    grid_nrow = 2L,
    grid_ncol = 2L,
    output = "matrix",
    plot = FALSE
  )

  expect_true(is.matrix(m))
  expect_identical(dim(m), c(2L, 2L))
  expect_equal(as.numeric(m), c(10, 20, 30, 40), tolerance = 0)
})
