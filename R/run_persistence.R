# ==============================================================================
# landisR run persistence utilities
# ==============================================================================

landisR_run_descriptor_filename <- function() {
  "landisR_run.rds"
}

landisR_run_descriptor_path <- function(output_directory) {
  output_directory <- normalizePath(
    output_directory,
    winslash = "/",
    mustWork = FALSE
  )

  file.path(
    output_directory,
    landisR_run_descriptor_filename()
  )
}

landisR_atomic_save_rds <- function(object, path) {
  dir.create(
    dirname(path),
    recursive = TRUE,
    showWarnings = FALSE
  )

  tmp <- tempfile(
    pattern = ".landisR_run_",
    tmpdir = dirname(path),
    fileext = ".rds"
  )

  on.exit({
    if (file.exists(tmp)) {
      unlink(tmp, force = TRUE)
    }
  }, add = TRUE)

  saveRDS(
    object,
    tmp,
    compress = "gzip"
  )

  if (file.exists(path)) {
    unlink(path, force = TRUE)
  }

  moved <- file.rename(tmp, path)

  if (!isTRUE(moved)) {
    copied <- file.copy(
      tmp,
      path,
      overwrite = TRUE,
      copy.mode = TRUE,
      copy.date = TRUE
    )

    if (!isTRUE(copied)) {
      stop(
        "Impossible d'ecrire le descripteur de simulation : ",
        path,
        call. = FALSE
      )
    }

    unlink(tmp, force = TRUE)
  }

  invisible(path)
}

landisR_new_run_descriptor <- function(
    project,
    output_directory,
    duration,
    seed,
    cache_directory = NULL,
    canonical_directory = NULL,
    status = "running",
    result = NULL,
    started_at = Sys.time()) {

  output_directory <- normalizePath(
    output_directory,
    winslash = "/",
    mustWork = FALSE
  )

  if (!is.null(cache_directory)) {
    cache_directory <- normalizePath(
      cache_directory,
      winslash = "/",
      mustWork = FALSE
    )
  }

  if (!is.null(canonical_directory)) {
    canonical_directory <- normalizePath(
      canonical_directory,
      winslash = "/",
      mustWork = FALSE
    )
  }

  out <- list(
    format = "landisR/run-v1",
    project = as.character(project),
    output_directory = output_directory,
    duration = as.integer(duration),
    seed = as.integer(seed),
    result = result,
    status = as.character(status),
    started_at = started_at,
    saved_at = Sys.time(),
    cache_directory = cache_directory,
    canonical_directory = canonical_directory
  )

  class(out) <- "landisR_run"
  out
}

#' Save a landisR run descriptor
#'
#' Saves the lightweight object returned by landis_run() inside its simulation
#' output directory. Snapshots and checkpoints remain in their existing files;
#' the descriptor only stores the information needed to rediscover the run.
#'
#' @param run A landisR_run object.
#' @param output_directory Optional destination directory. By default,
#'   run$output_directory is used.
#' @param filename Descriptor filename. The default is landisR_run.rds.
#'
#' @return The descriptor path, invisibly.
#' @noRd
#' @export
landis_save_run <- function(
    run,
    output_directory = NULL,
    filename = landisR_run_descriptor_filename()) {

  if (!inherits(run, "landisR_run")) {
    stop(
      "run doit etre un landisR_run.",
      call. = FALSE
    )
  }

  if (is.null(output_directory)) {
    output_directory <- run$output_directory
  }

  if (is.null(output_directory) ||
      length(output_directory) != 1L ||
      is.na(output_directory) ||
      !nzchar(output_directory)) {
    stop(
      "output_directory est absent du landisR_run.",
      call. = FALSE
    )
  }

  output_directory <- normalizePath(
    output_directory,
    winslash = "/",
    mustWork = FALSE
  )

  dir.create(
    output_directory,
    recursive = TRUE,
    showWarnings = FALSE
  )

  run$output_directory <- output_directory

  if (is.list(run$result) &&
      !is.null(run$result$output)) {
    run$result$output <- output_directory
  }

  run$saved_at <- Sys.time()

  path <- file.path(
    output_directory,
    filename
  )

  landisR_atomic_save_rds(
    run,
    path
  )

  invisible(
    normalizePath(
      path,
      winslash = "/",
      mustWork = TRUE
    )
  )
}

landisR_rebase_context_cache <- function(run, output_directory) {
  current <- NULL

  if (is.list(run$result) &&
      is.list(run$result$complete)) {
    current <- run$result$complete$context_cache_file
  }

  if (!is.null(current) &&
      length(current) == 1L &&
      !is.na(current) &&
      file.exists(current)) {
    return(run)
  }

  project_name <- gsub(
    "[^A-Za-z0-9._-]+",
    "_",
    as.character(run$project)[1L]
  )

  cache_basename <- NULL
  if (!is.null(run$cache_directory) &&
      length(run$cache_directory) == 1L &&
      !is.na(run$cache_directory) &&
      nzchar(run$cache_directory)) {
    cache_basename <- basename(run$cache_directory)
  }

  candidates <- c(
    if (!is.null(cache_basename)) {
      file.path(
        dirname(output_directory),
        cache_basename,
        "context.rds"
      )
    },
    file.path(
      dirname(output_directory),
      paste0(".landisR_cache_", project_name),
      "context.rds"
    ),
    file.path(
      output_directory,
      ".landisR_cache",
      "context.rds"
    )
  )

  candidates <- unique(candidates)
  hit <- candidates[file.exists(candidates)]

  if (length(hit)) {
    context_file <- normalizePath(
      hit[1L],
      winslash = "/",
      mustWork = TRUE
    )

    if (is.null(run$result)) {
      run$result <- list()
    }
    if (is.null(run$result$complete)) {
      run$result$complete <- list()
    }

    run$result$complete$context_cache_file <- context_file
    run$cache_directory <- dirname(context_file)
  }

  run
}

#' Load a saved landisR run
#'
#' Loads landisR_run.rds from a simulation output directory. If the directory
#' has been moved, the output path is rebased automatically. A nearby context
#' cache is also rediscovered when possible.
#'
#' @param output_directory Simulation output directory, or a direct path to a
#'   landisR_run.rds file.
#' @param filename Descriptor filename when output_directory is a directory.
#' @param check Whether to check for snapshots/checkpoints and warn when they
#'   are absent.
#'
#' @return A landisR_run object.
#' @noRd
#' @export
landis_load_run <- function(
    output_directory,
    filename = landisR_run_descriptor_filename(),
    check = TRUE) {

  if (length(output_directory) != 1L ||
      is.na(output_directory) ||
      !nzchar(output_directory)) {
    stop(
      "output_directory doit etre un chemin unique.",
      call. = FALSE
    )
  }

  direct_file <-
    file.exists(output_directory) &&
    !dir.exists(output_directory)

  if (direct_file) {
    run_file <- normalizePath(
      output_directory,
      winslash = "/",
      mustWork = TRUE
    )
    actual_output <- dirname(run_file)
  } else {
    actual_output <- normalizePath(
      output_directory,
      winslash = "/",
      mustWork = FALSE
    )
    run_file <- file.path(
      actual_output,
      filename
    )
  }

  if (!file.exists(run_file)) {
    stop(
      "Descripteur de simulation absent : ",
      run_file,
      call. = FALSE
    )
  }

  run <- readRDS(run_file)

  if (!inherits(run, "landisR_run")) {
    stop(
      "Le fichier n'est pas un landisR_run valide : ",
      run_file,
      call. = FALSE
    )
  }

  old_output <- run$output_directory
  run$output_directory <- actual_output

  if (is.list(run$result) &&
      !is.null(run$result$output)) {
    run$result$output <- actual_output
  }

  run <- landisR_rebase_context_cache(
    run,
    actual_output
  )

  run$loaded_from <- run_file

  if (!is.null(old_output) &&
      !identical(
        normalizePath(old_output, winslash = "/", mustWork = FALSE),
        actual_output
      )) {
    run$previous_output_directory <- old_output
  }

  if (isTRUE(check)) {
    snapshots <- file.path(
      actual_output,
      "snapshots"
    )
    checkpoints <- file.path(
      actual_output,
      "checkpoints"
    )

    if (!dir.exists(snapshots) &&
        !dir.exists(checkpoints)) {
      warning(
        "Aucun repertoire snapshots/ ou checkpoints/ n'a ete trouve dans : ",
        actual_output,
        call. = FALSE
      )
    }

    if (!is.null(run$status) &&
        identical(run$status, "running")) {
      warning(
        "Le descripteur indique que le run etait encore en cours lors de sa derniere sauvegarde. ",
        "Les snapshots/checkpoints deja ecrits restent accessibles.",
        call. = FALSE
      )
    }

    if (!is.null(run$status) &&
        identical(run$status, "failed")) {
      warning(
        "Le descripteur indique que le run precedent s'est termine par une erreur.",
        call. = FALSE
      )
    }
  }

  run
}
