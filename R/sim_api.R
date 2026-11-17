# Orchestration of external extensions on the interactive forest state.
landis_extension <- function(step, initialize = function(simulation) NULL,
                             phase = c("before_succession", "after_succession", "succession"),
                             type = c("disturbance", "output", "succession")) {
  if (!is.function(step) || !is.function(initialize))
    stop("step et initialize doivent \xeatre des fonctions.", call. = FALSE)
  type <- match.arg(type)
  phase <- if (missing(phase)) landisR_extension_phase(type) else match.arg(phase)
  landisR_check_extension_phase(phase, type)
  structure(list(step = step, initialize = initialize, phase = phase, type = type),
            class = "landisR_extension")
}

landisR_extension_phase <- function(type) {
  if (!is.character(type) || length(type) != 1L) return(NULL)
  switch(type, disturbance = "before_succession", output = "after_succession",
         succession = "succession")
}

landisR_check_extension_phase <- function(phase, type) {
  expected <- landisR_extension_phase(type)
  if (is.null(expected) || !identical(phase, expected))
    stop("Disturbances must run before succession. Output extensions use type = 'output' after succession. Succession extensions use phase = 'succession'.",
         call. = FALSE)
}

landisR_extension_phases <- function(extensions, simulation) {
  phases <- vapply(extensions, function(extension) {
    landisR_check_extension_phase(extension$phase, extension$type)
    extension$phase
  }, character(1L))
  succession <- sum(phases == "succession")
  if (succession > 1L ||
      (succession == 1L && !inherits(simulation$project, "landisR_landscape_project")))
    stop("Use one external succession extension with a project built by landis_build_landscape().",
         call. = FALSE)
  phases
}

landis_sim <- function(x, steps = NULL, extensions = NULL, seed = 4357L, ...) {
  resuming <- inherits(x, "landisR_coupled_run")
  if (resuming) {
    if (!is.null(extensions) || !missing(seed) || ...length())
      stop("Pour reprendre un run, fournir uniquement x et steps.", call. = FALSE)
    run <- x
  } else {
    simulation <- if (inherits(x, "landisR_project")) {
      landis_initialize(x, seed = seed, ...)
    } else {
      if (!missing(seed) || ...length())
        stop("seed et ... servent uniquement \xe0 initialiser un projet.", call. = FALSE)
      landisR_validate_simulation(x)
    }
    if (is.null(extensions)) extensions <- list()
    ids <- names(extensions)
    if (!is.list(extensions) || (length(extensions) &&
        (is.null(ids) || anyNA(ids) || any(!nzchar(ids)) || anyDuplicated(ids) ||
         !all(vapply(extensions, inherits, logical(1L), "landisR_extension")))))
      stop("extensions doit \xeatre une liste nomm\xe9e d'objets landis_extension().", call. = FALSE)
    phases <- landisR_extension_phases(extensions, simulation)
    run <- structure(list(simulation = simulation, extensions = extensions,
                          extension_states = lapply(extensions, function(e) e$initialize(simulation)),
                          events = lapply(extensions, function(e) list())),
                     class = "landisR_coupled_run")
  }

  simulation <- landisR_validate_simulation(run$simulation)
  canonical <- simulation$project$canonical
  remaining <- floor((canonical$duration - simulation$year) / canonical$timestep)
  if (is.null(steps)) steps <- remaining
  if (!is.numeric(steps) || length(steps) != 1L || !is.finite(steps) ||
      steps != trunc(steps) || steps < 0 || steps > remaining)
    stop("steps doit \xeatre un entier dans la dur\xe9e restante du projet.", call. = FALSE)

  if (resuming) phases <- landisR_extension_phases(run$extensions, simulation)
  phase_order <- c("before_succession", "succession", "after_succession")
  ids_by_phase <- split(as.character(names(phases)), factor(phases, levels = phase_order))
  succession <- ids_by_phase[["succession"]]
  for (i in seq_len(steps)) {
    year <- as.integer(simulation$year + canonical$timestep)
    for (phase in phase_order) {
      for (id in ids_by_phase[[phase]]) {
        result <- run$extensions[[id]]$step(simulation, run$extension_states[[id]], year)
        if (!is.list(result) || !all(c("simulation", "state") %in% names(result)))
          stop("L'extension ", id, " doit retourner simulation et state.", call. = FALSE)
        updated <- landisR_validate_simulation(result$simulation)
        if (phase == "after_succession" && !identical(updated, simulation))
          stop("Output extension ", id, " changed the simulation.", call. = FALSE)
        if (!identical(updated$year, simulation$year) ||
            !identical(updated$ctx$ids, simulation$ctx$ids) ||
            !identical(updated$ctx$nrow, simulation$ctx$nrow) ||
            !identical(updated$ctx$ncol, simulation$ctx$ncol) ||
            !identical(updated$project$canonical$cell_length, canonical$cell_length) ||
            !identical(updated$project$canonical$timestep, canonical$timestep) ||
            !identical(updated$project$canonical$duration, canonical$duration))
          stop("L'extension ", id, " a modifi\u00e9 l'horloge ou la grille active.", call. = FALSE)
        simulation <- updated
        run$extension_states[id] <- list(result$state)
        if (!is.null(result$events)) run$events[[id]][as.character(year)] <- list(result$events)
      }
      if (phase == "succession") {
        simulation <- if (length(succession)) landisR_advance_landscape(simulation, succession)
                      else landis_step(simulation)
      }
    }
  }
  run$simulation <- simulation
  run
}
