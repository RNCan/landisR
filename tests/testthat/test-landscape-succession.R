test_that("a landscape project can run and preserve its shared cohort state", {
  cells <- data.frame(cell_id = c(3L, 1L, 2L), row = 1L,
                      col = c(3L, 1L, 2L), active = c(TRUE, TRUE, FALSE))
  project <- landis_build_landscape(cells, duration = 20L, cell_length = 100,
                                    species = data.frame(species = "PINE"))
  initial <- landis_initialize(project)
  expect_identical(landis_state(initial, "compact")$cell_id, c(1L, 3L))
  expect_equal(nrow(landis_state(initial, "cohorts")), 0)
  expect_error(landis_apply(initial, landis_update(dynamic = data.frame())),
               "Landscape-only projects")
  forest <- landis_apply(initial, landis_update(cohorts = data.frame(
    cell_id = 3L, species = "PINE", age = 20L, biomass = 100)))
  result <- landis_sim(forest)
  expect_identical(result$simulation$year, 20L)
  expect_identical(result$simulation$states, forest$states)
  expect_identical(result$simulation$rng_state, forest$rng_state)
  expect_error(landis_step(result$simulation), "exceeds the project duration")
})

test_that("external succession runs after disturbances and before the clock and output", {
  project <- landis_build_landscape(
    data.frame(cell_id = 1:2, row = 1L, col = 1:2, active = TRUE),
    duration = 20L, cell_length = 100, species = data.frame(species = "PINE"))
  disturb <- landis_extension(function(simulation, state, year) {
    cohorts <- data.frame(cell_id = 1L, species = "PINE", age = year, biomass = 10)
    list(simulation = landis_apply(simulation, landis_update(cohorts = cohorts)),
         state = state)
  })
  succession <- landis_extension(function(simulation, state, year) {
    cohorts <- landis_state(simulation, "cohorts")
    stopifnot(simulation$year < year, nrow(cohorts) == 1L)
    cohorts$biomass <- cohorts$biomass + state
    list(simulation = landis_apply(simulation, landis_update(cohorts = cohorts)),
         state = state + 1L, events = state)
  }, initialize = function(simulation) 1L, type = "succession")
  output <- landis_extension(function(simulation, state, year) {
    stopifnot(identical(simulation$year, year))
    list(simulation = simulation, state = state, events = landis_state(simulation, "cohorts"))
  }, type = "output")
  extensions <- list(output = output, succession = succession, disturb = disturb)
  complete <- landis_sim(project, extensions = extensions)
  checkpoint <- tempfile(fileext = ".rds")
  saveRDS(landis_sim(project, steps = 1L, extensions = extensions), checkpoint)
  resumed <- landis_sim(readRDS(checkpoint))
  expect_identical(complete$events, resumed$events)
  expect_identical(complete$extension_states, resumed$extension_states)
  expect_identical(complete$simulation$states, resumed$simulation$states)
  expect_identical(complete$events$succession, list(`10` = 1L, `20` = 2L))
  expect_identical(complete$events$output[["20"]]$biomass, 12)
  expect_error(landis_sim(project, extensions = list(one = succession, two = succession)),
               "one external succession extension")
  invalid <- landis_extension(function(simulation, state, year) {
    list(simulation = landis_step(simulation), state = state)
  }, type = "succession")
  expect_error(landis_sim(project, extensions = list(invalid = invalid)), "horloge")
})
