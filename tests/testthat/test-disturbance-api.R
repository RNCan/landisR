test_that("cohort batches preserve disjoint edits, the clock and the journal", {
  cells <- data.frame(cell_id = 1:4, row = 1L, col = 1:4, active = c(TRUE, FALSE, TRUE, TRUE))
  project <- landis_build_landscape(cells, duration = 20L, cell_length = 100,
                                   species = data.frame(species = c("PINE", "SPRUCE")))
  base <- landis_initialize(project)
  cohort <- data.frame(cell_id = c(1L, 3L, 4L), species = "PINE", age = 20L, biomass = 100)
  sim <- landis_apply(base, landis_update(cohorts = cohort))
  forest <- landis_csr(sim)
  expect_identical(forest$cell_id, c(1L, 3L, 4L))
  expect_identical(forest$states, sim$states)
  expect_identical(forest$cell_state, sim$cell_state)
  expect_identical(forest$species, c("PINE", "SPRUCE"))

  replacement <- data.frame(cell_id = 3L, species = "SPRUCE", age = 10L, biomass = 20)
  journal <- list(list(source = "remove"), list(source = "replace"))
  separate <- landis_apply(sim, landis_update(clear_cells = 1L, metadata = journal[[1L]],
                                              preserve_cohort_order = TRUE))
  separate <- landis_apply(separate, landis_update(cohorts = replacement, metadata = journal[[2L]],
                                                   preserve_cohort_order = TRUE))
  batch <- landis_apply_cohort_batch(sim, cohorts = replacement, clear_cells = 1L,
                                     event_metadata = journal, preserve_cohort_order = TRUE)
  expect_identical(landis_csr(batch), landis_csr(separate))
  expect_identical(landis_state(batch, "cohorts"), landis_state(separate, "cohorts"))
  entries <- lapply(tail(batch$history, 2L), function(evt) evt[c("year", "type", "metadata")])
  expect_identical(lapply(entries, `[[`, "metadata"), journal)
  expect_identical(lapply(entries, `[[`, "year"), rep(list(sim$year), 2L))
  expect_identical(batch$rng_state, sim$rng_state)
  expect_identical(batch$year, sim$year)
  expect_identical(landis_csr(sim), forest)
  expect_error(landis_apply_cohort_batch(sim, event_metadata = list("bad")), "list of metadata lists")
})
