test_that("landisR_run descriptors can be saved and reloaded", {
  td <- tempfile("landisR_run_")
  dir.create(td, recursive = TRUE)
  dir.create(file.path(td, "snapshots"))

  x <- list(
    format = "landisR/run-v1",
    project = "demo",
    output_directory = td,
    duration = 30L,
    seed = 4357L,
    result = list(output = td),
    status = "complete"
  )
  class(x) <- "landisR_run"

  path <- landis_save_run(x)
  expect_true(file.exists(path))

  y <- landis_load_run(td)
  expect_s3_class(y, "landisR_run")
  expect_identical(y$project, "demo")
  expect_identical(y$duration, 30L)
  expect_identical(y$seed, 4357L)
  expect_identical(y$output_directory,
                   normalizePath(td, winslash = "/", mustWork = TRUE))
})
