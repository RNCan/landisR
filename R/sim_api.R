# Orchestration of external extensions on the interactive forest state.
landis_extension <- function(step, initialize = function(simulation) NULL,
                             phase = c("before_succession", "after_succession"),
                             type = c("disturbance", "output")) {
  if (!is.function(step) || !is.function(initialize))
    stop("step et initialize doivent \xeatre des fonctions.", call. = FALSE)
  type <- match.arg(type)
  phase <- if (missing(phase) && type == "output") "after_succession" else match.arg(phase)
  landisR_check_extension_phase(phase, type)
  structure(list(step = step, initialize = initialize, phase = phase, type = type),
            class = "landisR_extension")
}

landisR_check_extension_phase <- function(phase, type) {
  expected <- if (identical(type, "output")) "after_succession" else "before_succession"
  if (!identical(phase, expected))
    stop("Disturbances must run before succession. Output extensions use type = 'output' after succession.",
         call. = FALSE)
}

landis_sim <- function(x, steps = NULL, extensions = NULL, seed = 4357L, ...) {
  if (inherits(x, "landisR_coupled_run")) {
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
    for (extension in extensions)
      landisR_check_extension_phase(extension$phase, extension$type)
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

  phases <- vapply(run$extensions, function(e) {
    landisR_check_extension_phase(e$phase, e$type)
    e$phase
  }, character(1L))
  before <- names(phases)[phases == "before_succession"]
  after <- names(phases)[phases == "after_succession"]
  for (i in seq_len(steps)) {
    year <- as.integer(simulation$year + canonical$timestep)
    for (phase in c("before", "after")) {
      if (phase == "after") simulation <- landis_step(simulation)
      for (id in if (phase == "before") before else after) {
        result <- run$extensions[[id]]$step(simulation, run$extension_states[[id]], year)
        if (!is.list(result) || !all(c("simulation", "state") %in% names(result)))
          stop("L'extension ", id, " doit retourner simulation et state.", call. = FALSE)
        updated <- landisR_validate_simulation(result$simulation)
        if (phase == "after" && !identical(updated, simulation))
          stop("Output extension ", id, " changed the simulation.", call. = FALSE)
        if (!identical(updated$year, simulation$year) ||
            !identical(updated$ctx$ids, simulation$ctx$ids) ||
            !identical(updated$ctx$nrow, simulation$ctx$nrow) ||
            !identical(updated$ctx$ncol, simulation$ctx$ncol) ||
            !identical(updated$project$canonical$cell_length, canonical$cell_length) ||
            !identical(updated$project$canonical$timestep, canonical$timestep) ||
            !identical(updated$project$canonical$duration, canonical$duration))
          stop("L'extension ", id, " a modifi\xe9 l'horloge ou la grille active.", call. = FALSE)
        simulation <- updated
        run$extension_states[id] <- list(result$state)
        if (!is.null(result$events)) run$events[[id]][as.character(year)] <- list(result$events)
      }
    }
  }
  run$simulation <- simulation
  run
}
