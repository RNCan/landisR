# --- permanent public state/update/apply round-trip regression (209B) ---

# This fixture is copied automatically from the frozen beta.3 tarball
# (landisR 0.1.0.9003) by scripts/209B_add_standalone_roundtrip_regression_test.R.
# It is intentionally local to this test file so the regression does not
# depend on the presence or name of another test file.

make_serotiny_project <- function(type = "strict", dispersal = "local", source_age = 30L, ncol = 5L, include_traits = TRUE) {
  skip_if_not_installed("landisR.succession.biomass")
    species <- data.frame(species = "PINU.BAN", longevity = 120L, maturity = 15L, shade_tolerance = 1L, fire_tolerance = 3L, 
        effective_seed_distance = 100, max_seed_distance = 250, vegetative_probability = 0, min_sprout_age = 0L, max_sprout_age = 0L, 
        post_fire_regeneration = "serotiny", stringsAsFactors = FALSE)
    if (isTRUE(include_traits)) {
        species$serotiny_type <- type
        species$serotiny_dispersal <- dispersal
    }
    species_parameters <- data.frame(species = "PINU.BAN", leaf_longevity = 3, woody_decay = 0.05, mortality_shape = 15, 
        growth_shape = 0.5, leaf_lignin = 0.2, stringsAsFactors = FALSE)
    ecoregions <- data.frame(map_code = 1L, ecoregion = "eco1", active = TRUE, description = "test", stringsAsFactors = FALSE)
    ecoregion_parameters <- data.frame(ecoregion = "eco1", aet = 600, stringsAsFactors = FALSE)
    dynamic <- data.frame(year = 0L, ecoregion = "eco1", species = "PINU.BAN", sep = 1, max_anpp = 100, max_biomass = 5000, 
        stringsAsFactors = FALSE)
    initial_cohorts <- data.frame(map_code = 1L, species = "PINU.BAN", age = source_age, biomass = 100, stringsAsFactors = FALSE)
    shade <- data.frame(shade = 1:5, eco1 = c(0, 0.2, 0.4, 0.6, 0.8))
    light <- data.frame(shade_tolerance = 1:5, shade_0 = 1, shade_1 = 1, shade_2 = 1, shade_3 = 1, shade_4 = 1, shade_5 = 1)
    fire_reductions <- data.frame(severity = 1L, wood_reduction = 0, litter_reduction = 0.5)
    landscape <- data.frame(cell_id = seq_len(ncol), row = rep(1L, ncol), col = seq_len(ncol), ecoregion_map_code = rep(1L, 
        ncol), ecoregion = rep("eco1", ncol), active = rep(TRUE, ncol), community = c(1L, rep(2L, ncol - 1L)), stringsAsFactors = FALSE)
    landis_build(landscape = landscape, species = species, species_parameters = species_parameters, ecoregions = ecoregions, 
        ecoregion_parameters = ecoregion_parameters, dynamic = dynamic, initial_cohorts = initial_cohorts, shade = shade, 
        light = light, fire_reductions = fire_reductions, duration = 10L, cell_length = 100, timestep = 10L, seeding_algorithm = "WardSeedDispersal", 
        spinup_cohorts = FALSE, spinup_mortality_fraction = 0, initial_mode = "explicit_biomass", community_codes = c(1L, 
            2L), name = "serotiny-test")
}

test_that("public cohort state round-trips through update/apply and preserves continuation", {
  p <- make_serotiny_project(
    type = "facultative",
    dispersal = "local",
    ncol = 5L
  )

  canon <- function(x) {
    required <- c(
      "cell_id", "row", "col", "ecoregion",
      "species", "age", "biomass"
    )

    expect_true(all(required %in% names(x)))
    x <- x[required]

    if (!nrow(x)) {
      rownames(x) <- NULL
      return(x)
    }

    ord <- order(
      as.integer(x$cell_id),
      as.character(x$species),
      as.numeric(x$age),
      as.numeric(x$biomass)
    )

    x <- x[ord, , drop = FALSE]
    rownames(x) <- NULL
    x
  }

  without_cells <- function(x, ids) {
    if (!nrow(x)) {
      return(x)
    }

    canon(
      x[
        !as.integer(x$cell_id) %in% as.integer(ids),
        ,
        drop = FALSE
      ]
    )
  }

  state_cohorts <- function(sim, cells = NULL) {
    if (is.null(cells)) {
      return(
        landis_state(
          sim,
          representation = "cohorts"
        )
      )
    }

    landis_state(
      sim,
      representation = "cohorts",
      cells = as.integer(cells)
    )
  }

  sim_seed <- landis_initialize(
    p,
    seed = 4357L
  )

  seed_state <- canon(
    state_cohorts(sim_seed)
  )

  cells_table <- p$canonical$landscape$cells
  active_ids <- as.integer(
    cells_table$cell_id[
      as.logical(cells_table$active)
    ]
  )

  nonempty_ids <- unique(
    as.integer(seed_state$cell_id)
  )

  expect_gt(length(active_ids), 1L)
  expect_gt(length(nonempty_ids), 0L)

  target_cell <- nonempty_ids[1L]
  empty_candidates <- setdiff(
    active_ids,
    nonempty_ids
  )

  sim0 <- sim_seed

  if (length(empty_candidates)) {
    empty_cell <- empty_candidates[1L]
  } else {
    empty_cell <- setdiff(
      active_ids,
      target_cell
    )[1L]

    sim0 <- landis_apply(
      sim0,
      landis_update(
        clear_cells = empty_cell,
        metadata = list(
          test = "prepare-empty-roundtrip-cell"
        )
      )
    )
  }

  before_all <- canon(
    state_cohorts(sim0)
  )

  target_cells <- as.integer(
    c(
      target_cell,
      empty_cell
    )
  )

  before_target <- canon(
    state_cohorts(
      sim0,
      cells = target_cells
    )
  )

  # Empty active cells intentionally have no cohort row.
  expect_false(
    empty_cell %in% before_target$cell_id
  )

  roundtrip_clear <- setdiff(
    target_cells,
    unique(
      as.integer(before_target$cell_id)
    )
  )

  sim_roundtrip <- landis_apply(
    sim0,
    landis_update(
      cohorts = before_target,
      clear_cells = roundtrip_clear,
      metadata = list(
        test = "public-cohort-roundtrip"
      )
    )
  )

  # Exact no-op round-trip.
  expect_identical(
    canon(state_cohorts(sim_roundtrip)),
    before_all
  )

  expect_identical(
    as.integer(sim_roundtrip$year),
    as.integer(sim0$year)
  )

  expect_identical(
    sim_roundtrip$rng_state,
    sim0$rng_state
  )

  # No-op round-trip must preserve the next succession trajectory.
  control_next <- landis_step(sim0)
  roundtrip_next <- landis_step(sim_roundtrip)

  expect_identical(
    canon(state_cohorts(roundtrip_next)),
    canon(state_cohorts(control_next))
  )

  expect_identical(
    roundtrip_next$rng_state,
    control_next$rng_state
  )

  # Modify one target cell only.
  original_target <- canon(
    state_cohorts(
      sim0,
      cells = target_cell
    )
  )

  expect_gt(nrow(original_target), 0L)

  modified_target <- original_target
  modified_target$biomass[1L] <-
    as.numeric(modified_target$biomass[1L]) + 7

  sim_modified <- landis_apply(
    sim0,
    landis_update(
      cohorts = modified_target,
      metadata = list(
        test = "public-one-cell-update"
      )
    )
  )

  expect_identical(
    canon(
      state_cohorts(
        sim_modified,
        cells = target_cell
      )
    ),
    canon(modified_target)
  )

  expect_identical(
    without_cells(
      canon(state_cohorts(sim_modified)),
      target_cell
    ),
    without_cells(
      before_all,
      target_cell
    )
  )

  expect_identical(
    sim_modified$rng_state,
    sim0$rng_state
  )

  # Clear a cell and restore it exactly from the public cohort state.
  sim_cleared <- landis_apply(
    sim0,
    landis_update(
      clear_cells = target_cell,
      metadata = list(
        test = "public-clear-cell"
      )
    )
  )

  expect_equal(
    nrow(
      state_cohorts(
        sim_cleared,
        cells = target_cell
      )
    ),
    0L
  )

  expect_identical(
    without_cells(
      canon(state_cohorts(sim_cleared)),
      target_cell
    ),
    without_cells(
      before_all,
      target_cell
    )
  )

  sim_restored <- landis_apply(
    sim_cleared,
    landis_update(
      cohorts = original_target,
      metadata = list(
        test = "public-restore-cell"
      )
    )
  )

  expect_identical(
    canon(state_cohorts(sim_restored)),
    before_all
  )

  # Succession must continue normally after an external state update.
  modified_next <- landis_step(sim_modified)

  expect_identical(
    as.integer(modified_next$year),
    as.integer(sim_modified$year) +
      as.integer(sim_modified$project$canonical$timestep)
  )

  expect_s3_class(
    state_cohorts(modified_next),
    "data.frame"
  )
})

