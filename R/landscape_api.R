# A landscape project uses the same cell and cohort storage as an interactive
# Biomass project, with only the attributes needed by the core.
landis_build_landscape <- function(landscape, duration, cell_length, timestep = 10L,
                                   species = data.frame(species = character()),
                                   name = "landscape") {
  cells <- landisR_require_columns(landscape, c("cell_id", "row", "col", "active"),
                                   "landscape")
  duration <- landisR_scalar_integer(duration, "duration", 1L)
  timestep <- landisR_scalar_integer(timestep, "timestep", 1L)
  cell_length <- landisR_scalar_numeric(cell_length, "cell_length")
  if (cell_length <= 0 || duration %% timestep != 0L)
    landisR_stop("cell_length must be positive and duration must be a multiple of timestep.")
  if (!is.character(name) || length(name) != 1L || is.na(name) || !nzchar(name))
    landisR_stop("name must be one non-empty string.")

  positions <- cells[c("cell_id", "row", "col")]
  valid_positions <- vapply(positions, function(x) {
    is.numeric(x) && all(is.finite(x) & x >= 1 & x <= .Machine$integer.max & x == trunc(x))
  }, logical(1L))
  if (!nrow(cells) || !all(valid_positions) || !is.logical(cells$active) ||
      anyNA(cells$active) || !any(cells$active))
    landisR_stop("Supply positive integer cell positions and a logical active column with active cells.")
  nrow_grid <- as.integer(max(cells$row))
  ncol_grid <- as.integer(max(cells$col))
  cells <- cells[order(cells$cell_id), , drop = FALSE]
  rownames(cells) <- NULL
  ids <- seq_len(nrow(cells))
  if (as.double(nrow_grid) * ncol_grid != length(ids) ||
      !all(cells$cell_id == ids & cells$cell_id == cells$row + (cells$col - 1) * nrow_grid))
    landisR_stop("Supply the full rectangular grid with column-major cell IDs.")
  cells$cell_id <- ids
  cells$row <- as.integer(cells$row)
  cells$col <- as.integer(cells$col)

  if (is.null(cells$ecoregion)) cells$ecoregion <- "default"
  cells$ecoregion <- as.character(cells$ecoregion)
  labels <- unique(cells$ecoregion[cells$active])
  if (anyNA(labels) || any(!nzchar(labels)))
    landisR_stop("Active cells must have non-empty ecoregion labels.")
  species <- landisR_require_columns(species, "species", "species")
  codes <- as.character(species$species)
  if (anyNA(codes) || any(!nzchar(codes)) || anyDuplicated(codes))
    landisR_stop("The species catalog must contain unique non-empty species codes.")
  species$species <- codes

  grid <- list(cells = cells, ids = ids[cells$active], active = cells$active,
               nrow = nrow_grid, ncol = ncol_grid)
  canonical <- list(landscape = grid, species = species, duration = duration,
                    cell_length = cell_length, timestep = timestep)
  structure(list(format = "landisR/project-v1", name = name, source_type = "landscape",
                 canonical = canonical),
            class = c("landisR_landscape_project", "landisR_project"))
}

landisR_initialize_landscape <- function(project, seed) {
  seed <- landisR_scalar_integer(seed, "seed", 0L)
  canonical <- project$canonical
  grid <- canonical$landscape
  labels <- grid$cells$ecoregion[grid$ids]
  ecoregions <- unique(labels)
  state_eco <- seq_along(ecoregions)
  cell_state <- match(labels, ecoregions)
  states <- list(format = "landisR52/state-csr-v3",
                 offset = integer(length(state_eco) + 1L),
                 species_id = integer(), age = numeric(), biomass = numeric())
  ctx <- list(ids = grid$ids, nrow = grid$nrow, ncol = grid$ncol, active_eco = cell_state,
              config = canonical[c("species", "cell_length", "timestep")],
              states = states, state_eco = state_eco, cell_state = cell_state)
  structure(list(format = "landisR/simulation-v1", project = project, year = 0L, seed = seed,
                 growth_engine = list(id = "none"), ctx = ctx, states = states,
                 state_eco = state_eco, cell_state = cell_state,
                 rng_state = landisR_capture_seed_state(seed), profile = data.frame(),
                 history = list(landisR_event(0L, "initialize", list(project = project$name)))),
            class = "landisR_simulation")
}

landisR_advance_landscape <- function(simulation, succession = character()) {
  canonical <- simulation$project$canonical
  year <- as.double(simulation$year) + canonical$timestep
  if (year > canonical$duration)
    landisR_stop("The next timestep exceeds the project duration.")
  simulation$year <- as.integer(year)
  metadata <- if (length(succession)) list(succession = succession) else list()
  simulation$history[[length(simulation$history) + 1L]] <- landisR_event(year, "step", metadata)
  simulation
}
