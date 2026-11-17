#' Apply a structured fire event and fire-triggered serotinous recruitment
#'
#' A fire event captures mature serotinous seed sources from the PRE-FIRE
#' forest, applies an optional post-fire landisR update, and then evaluates
#' fire-triggered serotinous establishment. Species with
#' serotiny_type="strict" cannot recruit through ordinary sexual reproduction;
#' species with serotiny_type="facultative" retain ordinary recruitment and
#' additionally recruit after fire.
landis_fire <- function(simulation,
                        cells,
                        update = NULL,
                        stochastic = TRUE,
                        severity = NULL,
                        metadata = list(),
                        year = simulation$year) {
  simulation <- landisR_validate_simulation(simulation)

  if (!is.numeric(year) || length(year) != 1L || is.na(year) ||
      !year %in% c(simulation$year, simulation$year + simulation$project$canonical$timestep))
    stop("Fire year must be the current or next succession year.", call. = FALSE)
  year <- as.integer(year)

  cells <- unique(as.integer(cells))
  if (!length(cells) || anyNA(cells)) {
    stop("cells doit contenir au moins une cellule valide.", call. = FALSE)
  }

  active_ids <- as.integer(simulation$ctx$ids)
  if (any(!cells %in% active_ids)) {
    stop("cells contient une cellule absente ou inactive.", call. = FALSE)
  }

  if (!is.logical(stochastic) || length(stochastic) != 1L || is.na(stochastic)) {
    stop("stochastic doit etre TRUE ou FALSE.", call. = FALSE)
  }

  if (!is.list(metadata)) {
    stop("metadata doit etre une liste.", call. = FALSE)
  }

  if (!is.null(severity)) {
    severity <- as.numeric(severity)
    if (length(severity) == 1L) severity <- rep(severity, length(cells))
    if (length(severity) != length(cells) || anyNA(severity) ||
        any(!is.finite(severity))) {
      stop("severity doit etre NULL, scalaire, ou de longueur length(cells).",
           call. = FALSE)
    }
  }

  # The engine observes the forest before mortality but recruits into the
  # forest after mortality, at the original position of the relevant RNG.
  hooks <- if (identical(simulation$growth_engine$id, "biomass52"))
    landisR_biomass_backend()$fire
  sources <- if (!is.null(hooks)) hooks$capture_sources(simulation, cells)

  if (!is.null(update)) {
    simulation <- landis_apply(simulation, update)
    simulation$history[[length(simulation$history)]]$year <- year
  }

  recruited <- if (is.null(hooks)) {
    list(simulation = simulation, source_count = integer(),
         recruited_cells = 0L, recruited_cohorts = 0L)
  } else {
    hooks$recruit(simulation, sources, stochastic = stochastic, year = year)
  }
  simulation <- recruited$simulation

  event_metadata <- c(
    list(
      cells = as.integer(cells),
      n_cells = length(cells),
      severity = severity,
      serotiny_sources = recruited$source_count,
      serotiny_recruited_cells = recruited$recruited_cells,
      serotiny_recruited_cohorts = recruited$recruited_cohorts
    ),
    metadata
  )

  simulation$history[[length(simulation$history) + 1L]] <- landisR_event(
    year,
    "fire",
    event_metadata
  )

  burned <- if (is.null(severity)) cells else cells[severity > 0]
  if (year > 0L && length(burned)) {
    previous <- simulation$fire_damage_history
    if (!is.null(previous))
      previous <- previous[!previous$cell_id %in% burned | previous$year > year, , drop = FALSE]
    new <- setdiff(burned, previous$cell_id)
    simulation$fire_damage_history <- rbind(previous,
                                            data.frame(cell_id = new, year = rep.int(year, length(new))))
    rownames(simulation$fire_damage_history) <- NULL
  }
  simulation
}

landis_fire_history <- function(simulation) {
  landisR_validate_simulation(simulation)$fire_damage_history
}
