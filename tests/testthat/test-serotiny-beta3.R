make_serotiny_project <- function(type = "strict", dispersal = "local",
                                  source_age = 30L, ncol = 5L,
                                  include_traits = TRUE) {
  species <- data.frame(
    species = "PINU.BAN",
    longevity = 120L,
    maturity = 15L,
    shade_tolerance = 1L,
    fire_tolerance = 3L,
    effective_seed_distance = 100,
    max_seed_distance = 250,
    vegetative_probability = 0,
    min_sprout_age = 0L,
    max_sprout_age = 0L,
    post_fire_regeneration = "serotiny",
    stringsAsFactors = FALSE
  )

  if (isTRUE(include_traits)) {
    species$serotiny_type <- type
    species$serotiny_dispersal <- dispersal
  }

  species_parameters <- data.frame(
    species = "PINU.BAN",
    leaf_longevity = 3,
    woody_decay = 0.05,
    mortality_shape = 15,
    growth_shape = 0.5,
    leaf_lignin = 0.2,
    stringsAsFactors = FALSE
  )

  ecoregions <- data.frame(
    map_code = 1L,
    ecoregion = "eco1",
    active = TRUE,
    description = "test",
    stringsAsFactors = FALSE
  )

  ecoregion_parameters <- data.frame(
    ecoregion = "eco1",
    aet = 600,
    stringsAsFactors = FALSE
  )

  dynamic <- data.frame(
    year = 0L,
    ecoregion = "eco1",
    species = "PINU.BAN",
    sep = 1,
    max_anpp = 100,
    max_biomass = 5000,
    stringsAsFactors = FALSE
  )

  initial_cohorts <- data.frame(
    map_code = 1L,
    species = "PINU.BAN",
    age = source_age,
    biomass = 100,
    stringsAsFactors = FALSE
  )

  shade <- data.frame(
    shade = 1:5,
    eco1 = c(0, 0.2, 0.4, 0.6, 0.8)
  )

  light <- data.frame(
    shade_tolerance = 1:5,
    shade_0 = 1,
    shade_1 = 1,
    shade_2 = 1,
    shade_3 = 1,
    shade_4 = 1,
    shade_5 = 1
  )

  fire_reductions <- data.frame(
    severity = 1L,
    wood_reduction = 0,
    litter_reduction = 0.5
  )

  landscape <- data.frame(
    cell_id = seq_len(ncol),
    row = rep(1L, ncol),
    col = seq_len(ncol),
    ecoregion_map_code = rep(1L, ncol),
    ecoregion = rep("eco1", ncol),
    active = rep(TRUE, ncol),
    community = c(1L, rep(2L, ncol - 1L)),
    stringsAsFactors = FALSE
  )

  landis_build(
    landscape = landscape,
    species = species,
    species_parameters = species_parameters,
    ecoregions = ecoregions,
    ecoregion_parameters = ecoregion_parameters,
    dynamic = dynamic,
    initial_cohorts = initial_cohorts,
    shade = shade,
    light = light,
    fire_reductions = fire_reductions,
    duration = 10L,
    cell_length = 100,
    timestep = 10L,
    seeding_algorithm = "WardSeedDispersal",
    spinup_cohorts = FALSE,
    spinup_mortality_fraction = 0,
    initial_mode = "explicit_biomass",
    community_codes = c(1L, 2L),
    name = "serotiny-test"
  )
}

has_age1 <- function(sim, cell = NULL) {
  x <- landis_state(sim, representation = "cohorts", cells = cell)
  any(x$species == "PINU.BAN" & x$age == 1)
}

test_that("LANDIS serotiny defaults to facultative local", {
  p <- make_serotiny_project(include_traits = FALSE)
  expect_identical(p$canonical$species$serotiny_type, "facultative")
  expect_identical(p$canonical$species$serotiny_dispersal, "local")
})

test_that("strict serotiny blocks ordinary recruitment", {
  p <- make_serotiny_project(type = "strict", dispersal = "local")
  sim <- landis_initialize(p, seed = 17L, dispersal = "local")
  sim <- landis_step(sim)
  expect_false(has_age1(sim))
})

test_that("facultative serotiny retains ordinary recruitment", {
  p <- make_serotiny_project(type = "facultative", dispersal = "local")
  sim <- landis_initialize(p, seed = 17L, dispersal = "local")
  sim <- landis_step(sim)
  expect_true(has_age1(sim, 1L))
})

test_that("strict local serotiny recruits only from burned mature source cell", {
  p <- make_serotiny_project(type = "strict", dispersal = "local")
  sim <- landis_initialize(p, seed = 17L)
  sim <- landis_fire(
    sim,
    cells = 1L,
    update = landis_update(clear_cells = 1L),
    stochastic = FALSE
  )
  x <- landis_state(sim, representation = "cohorts")
  recruited_cells <- unique(x$cell_id[x$species == "PINU.BAN" & x$age == 1])
  expect_identical(as.integer(recruited_cells), 1L)
})

test_that("strict kernel serotiny can disperse to an unburned neighboring cell", {
  p <- make_serotiny_project(type = "strict", dispersal = "kernel", ncol = 5L)
  sim <- landis_initialize(p, seed = 17L)
  sim <- landis_fire(
    sim,
    cells = 1L,
    update = landis_update(clear_cells = 1L),
    stochastic = FALSE
  )
  x <- landis_state(sim, representation = "cohorts")
  recruited_cells <- unique(x$cell_id[x$species == "PINU.BAN" & x$age == 1])
  expect_true(1L %in% recruited_cells)
  expect_true(2L %in% recruited_cells)
  expect_false(5L %in% recruited_cells)
})

test_that("immature serotinous cohorts do not release viable fire seed", {
  p <- make_serotiny_project(
    type = "strict",
    dispersal = "kernel",
    source_age = 10L
  )
  sim <- landis_initialize(p, seed = 17L)
  sim <- landis_fire(
    sim,
    cells = 1L,
    update = landis_update(clear_cells = 1L),
    stochastic = FALSE
  )
  expect_false(has_age1(sim))
})

test_that("stochastic fire recruitment is reproducible from RNG state", {
  p <- make_serotiny_project(type = "strict", dispersal = "kernel")
  a <- landis_initialize(p, seed = 4357L)
  b <- landis_initialize(p, seed = 4357L)

  a <- landis_fire(
    a,
    cells = 1L,
    update = landis_update(clear_cells = 1L),
    stochastic = TRUE
  )
  b <- landis_fire(
    b,
    cells = 1L,
    update = landis_update(clear_cells = 1L),
    stochastic = TRUE
  )

  expect_identical(
    landis_state(a, representation = "cohorts"),
    landis_state(b, representation = "cohorts")
  )
  expect_identical(a$rng_state, b$rng_state)
})
