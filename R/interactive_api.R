# ==============================================================================
# interactive_api.R
#
# Public interactive/model-coupling API for landisR.
#
# Design principle:
#   - the validated Biomass Succession 5.2 scientific engine is NOT modified;
#   - a simulation can advance one succession timestep at a time;
#   - the forest state and compatible project inputs can be modified between
#     timesteps;
#   - external models never need to manipulate the internal CSR representation;
#   - Biomass Succession 5.2 is represented as the first growth engine, leaving
#     room for future engines without changing the public orchestration model.
# ==============================================================================

landis_growth_biomass52 <- function() {

  out <-
    list(
      format =
        "landisR/growth-engine-v1",
      id =
        "biomass52",
      label =
        "LANDIS-II Biomass Succession 5.2",
      version =
        "5.2",
      validated =
        TRUE,
      timestep_mode =
        "project",
      public_forest_state =
        c(
          "cell_id",
          "species",
          "age",
          "biomass"
        ),
      engine_state =
        "CSR living-cohort state"
    )

  class(
    out
  ) <-
    "landisR_growth_engine"

  out
}

print.landisR_growth_engine <- function(
    x,
    ...) {

  cat(
    "<landisR_growth_engine>\n",
    sep = ""
  )

  cat(
    "  id       : ",
    x$id,
    "\n",
    sep = ""
  )

  cat(
    "  label    : ",
    x$label,
    "\n",
    sep = ""
  )

  cat(
    "  version  : ",
    x$version,
    "\n",
    sep = ""
  )

  cat(
    "  validated: ",
    if (isTRUE(
          x$validated
        )) {
      "yes"
    } else {
      "no"
    },
    "\n",
    sep = ""
  )

  invisible(
    x
  )
}

landisR_validate_growth_engine <- function(
    engine) {

  if (!inherits(
        engine,
        "landisR_growth_engine"
      ) ||
      !is.list(
        engine
      ) ||
      !identical(
        engine$format,
        "landisR/growth-engine-v1"
      )) {

    landisR_stop(
      "growth_engine doit etre un objet landisR_growth_engine."
    )
  }

  if (!identical(
        engine$id,
        "biomass52"
      )) {

    landisR_stop(
      "Le seul moteur de croissance implemente dans cette beta est biomass52."
    )
  }

  engine
}

landisR_capture_seed_state <- function(
    seed) {

  seed <-
    landisR_scalar_integer(
      seed,
      "seed",
      0L
    )

  old_kind <-
    RNGkind()

  had_seed <-
    exists(
      ".Random.seed",
      .GlobalEnv,
      inherits = FALSE
    )

  if (had_seed) {
    old_seed <-
      get(
        ".Random.seed",
        .GlobalEnv,
        inherits = FALSE
      )
  }

  on.exit(
    {
      do.call(
        RNGkind,
        as.list(
          old_kind
        )
      )

      if (had_seed) {
        assign(
          ".Random.seed",
          old_seed,
          .GlobalEnv
        )
      } else if (exists(
                   ".Random.seed",
                   .GlobalEnv,
                   inherits = FALSE
                 )) {
        rm(
          ".Random.seed",
          envir = .GlobalEnv
        )
      }
    },
    add = TRUE
  )

  RNGkind(
    "Mersenne-Twister",
    "Inversion",
    "Rejection"
  )

  set.seed(
    seed
  )

  get(
    ".Random.seed",
    .GlobalEnv,
    inherits = FALSE
  )
}

landisR_event <- function(
    year,
    type,
    metadata = list()) {

  list(
    year =
      as.integer(
        year
      ),
    type =
      as.character(
        type
      ),
    metadata =
      metadata,
    timestamp =
      Sys.time()
  )
}

landis_initialize <- function(
    project,
    seed = 4357L,
    growth_engine = landis_growth_biomass52(),
    dispersal = "ward",
    ward_variant = "ward2019",
    rng_chunk_cells = 100000L,
    recruitment_rng = c("analytical", "landis_v7"),
    regeneration_mode = c("immediate", "landis_v7")) {

  if (inherits(project, "landisR_landscape_project")) {
    if (!missing(growth_engine) || !missing(dispersal) || !missing(ward_variant) ||
        !missing(rng_chunk_cells) || !missing(recruitment_rng) || !missing(regeneration_mode))
      landisR_stop("Biomass Succession settings require a project built with landis_build().")
    return(landisR_initialize_landscape(project, seed))
  }

  recruitment_rng <- match.arg(recruitment_rng)
  regeneration_mode <- match.arg(regeneration_mode)
  if (regeneration_mode == "landis_v7" && recruitment_rng != "landis_v7")
    landisR_stop("regeneration_mode = 'landis_v7' requires recruitment_rng = 'landis_v7'.")
  if (recruitment_rng == "landis_v7" && !identical(dispersal, "ward"))
    landisR_stop("recruitment_rng = 'landis_v7' requires Ward dispersal.")

  if (!inherits(
        project,
        "landisR_project"
      )) {
    landisR_stop(
      "project doit etre un landisR_project."
    )
  }

  biomass <- landisR_biomass_backend()
  if (regeneration_mode == "landis_v7" && !isTRUE(biomass$deferred_regeneration))
    landisR_stop("Deferred regeneration requires a compatible Biomass Succession provider.")

  growth_engine <-
    landisR_validate_growth_engine(
      growth_engine
    )

  canonical <-
    landisR_validate_canonical(
      project$canonical
    )

  seed <-
    landisR_scalar_integer(
      seed,
      "seed",
      0L
    )

  rng_chunk_cells <-
    landisR_scalar_integer(
      rng_chunk_cells,
      "rng_chunk_cells",
      1L
    )

  if (!identical(
        dispersal,
        "ward"
      ) &&
      !identical(
        dispersal,
        "local"
      )) {
    landisR_stop(
      "dispersal doit etre 'ward' ou 'local'."
    )
  }

  if (!identical(
        ward_variant,
        "ward2019"
      ) &&
      !identical(
        ward_variant,
        "ward2022"
      )) {
    landisR_stop(
      "ward_variant doit etre 'ward2019' ou 'ward2022'."
    )
  }

  ctx <-
    biomass$context(canonical, v7 = recruitment_rng == "landis_v7")

  out <-
    list(
      format =
        "landisR/simulation-v1",
      project =
        project,
      year =
        0L,
      seed =
        seed,
      growth_engine =
        growth_engine,
      dispersal =
        dispersal,
      ward_variant =
        ward_variant,
      rng_chunk_cells =
        rng_chunk_cells,
      ctx =
        ctx,
      states =
        ctx$states,
      state_eco =
        as.integer(
          ctx$state_eco
        ),
      cell_state =
        as.integer(
          ctx$cell_state
        ),
      rng_state =
        landisR_capture_seed_state(
          seed
        ),
      session_signature =
        list(
          format =
            "landisR/interactive-session-v1",
          growth_engine =
            growth_engine$id,
          seed =
            seed
        ),
      profile =
        data.frame(),
      history =
        list(
          landisR_event(
            0L,
            "initialize",
            list(
              project =
                project$name,
              growth_engine =
                growth_engine$id
            )
          )
        )
    )

  if (recruitment_rng == "landis_v7") {
    out$landis_rng <- list(state = landis_mt19937_init_cpp(seed), offset = 0)
  }

  if (regeneration_mode == "landis_v7") out$regeneration_mode <- regeneration_mode

  class(
    out
  ) <-
    "landisR_simulation"

  out
}

print.landisR_simulation <- function(
    x,
    ...) {

  cat(
    "<landisR_simulation>\n",
    sep = ""
  )

  cat(
    "  project      : ",
    x$project$name,
    "\n",
    sep = ""
  )

  cat(
    "  year         : ",
    x$year,
    "\n",
    sep = ""
  )

  cat(
    "  timestep     : ",
    x$project$canonical$timestep,
    " years\n",
    sep = ""
  )

  cat(
    "  growth engine: ",
    x$growth_engine$id,
    "\n",
    sep = ""
  )

  cat(
    "  active cells : ",
    format(
      length(
        x$ctx$ids
      ),
      big.mark = " "
    ),
    "\n",
    sep = ""
  )

  cat(
    "  states       : ",
    format(
      bs52_large_n_states52(
        x$states
      ),
      big.mark = " "
    ),
    "\n",
    sep = ""
  )

  cat(
    "  events       : ",
    length(
      x$history
    ),
    "\n",
    sep = ""
  )

  invisible(
    x
  )
}

landisR_validate_simulation <- function(
    simulation) {

  if (!inherits(
        simulation,
        "landisR_simulation"
      ) ||
      !is.list(
        simulation
      ) ||
      !identical(
        simulation$format,
        "landisR/simulation-v1"
      )) {

    landisR_stop(
      "simulation doit etre un landisR_simulation."
    )
  }

  if (!inherits(
        simulation$project,
        "landisR_project"
      )) {
    landisR_stop(
      "Le projet associe a la simulation est invalide."
    )
  }

  simulation
}

landisR_step_biomass52 <- function(
    simulation) {

  timestep <-
    as.integer(
      simulation$project$canonical$timestep
    )

  end_year <-
    as.integer(
      simulation$year +
        timestep
    )

  if (end_year >
      simulation$project$canonical$duration) {

    landisR_stop(
      "Le prochain pas de temps depasse la duree disponible dans le projet."
    )
  }

  simulation <- landisR_biomass_backend()$step(simulation, end_year)
  simulation$year <- end_year

  simulation$history[[length(simulation$history) + 1L]] <-
    landisR_event(
      end_year,
      "step",
      list(
        growth_engine =
          simulation$growth_engine$id,
        dispersal =
          simulation$dispersal,
        ward_variant =
          simulation$ward_variant
      )
    )

  simulation
}

landis_step <- function(
    simulation,
    steps = 1L) {

  simulation <-
    landisR_validate_simulation(
      simulation
    )

  steps <-
    landisR_scalar_integer(
      steps,
      "steps",
      1L
    )

  for (i in seq_len(
         steps
       )) {

    if (identical(
          simulation$growth_engine$id,
          "biomass52"
        )) {

      simulation <-
        landisR_step_biomass52(
          simulation
        )

    } else if (inherits(simulation$project, "landisR_landscape_project")) {

      simulation <- landisR_advance_landscape(simulation)

    } else {

      landisR_stop(
        "Moteur de croissance non implemente : ",
        simulation$growth_engine$id
      )
    }
  }

  simulation
}

.landisR_legacy_state_list_270F <- function(
    simulation) {

  bs52_csr_to_states_cpp(
    simulation$states,
    as.character(
      simulation$ctx$config$species$species
    )
  )
}

landisR_run_state_index <- function(
    run,
    type = c(
      "snapshot",
      "checkpoint"
    )) {

  type <-
    match.arg(
      type
    )

  if (!inherits(
        run,
        "landisR_run"
      ) ||
      !is.list(
        run
      ) ||
      !identical(
        run$format,
        "landisR/run-v1"
      )) {
    landisR_stop(
      "run doit etre un landisR_run."
    )
  }

  directory <-
    file.path(
      run$output_directory,
      if (identical(
            type,
            "snapshot"
          )) {
        "snapshots"
      } else {
        "checkpoints"
      }
    )

  prefix <-
    if (identical(
          type,
          "snapshot"
        )) {
      "snapshot"
    } else {
      "checkpoint"
    }

  if (!dir.exists(
        directory
      )) {
    return(
      data.frame(
        year = integer(),
        path = character(),
        stringsAsFactors = FALSE
      )
    )
  }

  files <-
    list.files(
      directory,
      pattern = paste0(
        "^",
        prefix,
        "_[0-9]+\\.rds$"
      ),
      full.names = TRUE
    )

  if (!length(
        files
      )) {
    return(
      data.frame(
        year = integer(),
        path = character(),
        stringsAsFactors = FALSE
      )
    )
  }

  years <-
    suppressWarnings(
      as.integer(
        sub(
          paste0(
            "^",
            prefix,
            "_([0-9]+)\\.rds$"
          ),
          "\\1",
          basename(
            files
          )
        )
      )
    )

  keep <-
    !is.na(
      years
    )

  out <-
    data.frame(
      year = years[keep],
      path = files[keep],
      stringsAsFactors = FALSE
    )

  out <-
    out[
      order(
        out$year
      ),
      ,
      drop = FALSE
    ]

  rownames(
    out
  ) <-
    NULL

  out
}

landisR_run_pick_state_file <- function(
    run,
    type = c(
      "snapshot",
      "checkpoint"
    ),
    year = NULL) {

  type <-
    match.arg(
      type
    )

  index <-
    landisR_run_state_index(
      run,
      type = type
    )

  if (!nrow(
        index
      )) {
    landisR_stop(
      "Aucun ",
      type,
      " disponible dans le dossier de simulation : ",
      run$output_directory
    )
  }

  if (is.null(
        year
      )) {
    year <-
      max(
        index$year
      )
  } else {
    year <-
      landisR_scalar_integer(
        year,
        "year",
        0L
      )
  }

  where <-
    match(
      year,
      index$year
    )

  if (is.na(
        where
      )) {

    shown <-
      tail(
        index$year,
        20L
      )

    landisR_stop(
      "Aucun ",
      type,
      " disponible pour l'annee ",
      year,
      ". Annees disponibles : ",
      paste(
        shown,
        collapse = ", "
      ),
      if (nrow(
            index
          ) >
          length(
            shown
          )) {
        " (20 dernieres affichees)."
      } else {
        "."
      }
    )
  }

  list(
    year =
      as.integer(
        year
      ),
    path =
      index$path[
        where
      ]
  )
}

landisR_run_context_candidates <- function(
    run) {

  candidates <-
    character()

  if (!is.null(
        run$context_cache_file
      )) {
    candidates <-
      c(
        candidates,
        as.character(
          run$context_cache_file
        )
      )
  }

  if (!is.null(
        run$result
      ) &&
      is.list(
        run$result
      ) &&
      !is.null(
        run$result$complete
      ) &&
      is.list(
        run$result$complete
      ) &&
      !is.null(
        run$result$complete$context_cache_file
      )) {
    candidates <-
      c(
        candidates,
        as.character(
          run$result$complete$context_cache_file
        )
      )
  }

  if (!is.null(
        run$cache_directory
      )) {
    candidates <-
      c(
        candidates,
        file.path(
          as.character(
            run$cache_directory
          ),
          "context.rds"
        )
      )
  }

  if (!is.null(
        run$output_directory
      ) &&
      !is.null(
        run$project
      ) &&
      length(
        run$project
      ) ==
        1L) {

    safe_project <-
      gsub(
        "[^A-Za-z0-9._-]+",
        "_",
        as.character(
          run$project
        )
      )

    candidates <-
      c(
        candidates,
        file.path(
          dirname(
            run$output_directory
          ),
          paste0(
            ".landisR_cache_",
            safe_project
          ),
          "context.rds"
        )
      )
  }

  unique(
    normalizePath(
      candidates[
        nzchar(
          candidates
        )
      ],
      winslash = "/",
      mustWork = FALSE
    )
  )
}

landisR_run_canonical_candidates <- function(
    run,
    context_candidates = character()) {

  candidates <-
    character()

  if (!is.null(
        run$canonical_directory
      )) {
    candidates <-
      c(
        candidates,
        as.character(
          run$canonical_directory
        )
      )
  }

  if (!is.null(
        run$cache_directory
      )) {
    candidates <-
      c(
        candidates,
        file.path(
          as.character(
            run$cache_directory
          ),
          "canonical_inputs"
        )
      )
  }

  if (length(
        context_candidates
      )) {
    candidates <-
      c(
        candidates,
        file.path(
          dirname(
            context_candidates
          ),
          "canonical_inputs"
        )
      )
  }

  unique(
    normalizePath(
      candidates[
        nzchar(
          candidates
        )
      ],
      winslash = "/",
      mustWork = FALSE
    )
  )
}

landisR_load_run_context <- function(
    run) {

  context_candidates <-
    landisR_run_context_candidates(
      run
    )

  existing_context <-
    context_candidates[
      file.exists(
        context_candidates
      )
    ]

  if (length(
        existing_context
      )) {

    ctx <-
      readRDS(
        existing_context[1L]
      )

    if (!is.list(
          ctx
        ) ||
        is.null(
          ctx$ids
        ) ||
        is.null(
          ctx$config
        )) {
      landisR_stop(
        "Le cache de contexte landisR est invalide : ",
        existing_context[1L]
      )
    }

    return(
      ctx
    )
  }

  canonical_candidates <-
    landisR_run_canonical_candidates(
      run,
      context_candidates
    )

  existing_canonical <-
    canonical_candidates[
      dir.exists(
        canonical_candidates
      )
    ]

  if (length(
        existing_canonical
      )) {

    biomass <- landisR_biomass_backend()

    canonical <-
      biomass$read_canonical(
        existing_canonical[1L]
      )

    return(
      biomass$context(
        canonical
      )
    )
  }

  landisR_stop(
    "Impossible de retrouver le contexte de la simulation. ",
    "Le cache context.rds et les entrees canoniques sont absents."
  )
}

landisR_context_cell_metadata <- function(
    ctx,
    cell_ids) {

  cell_ids <-
    as.integer(
      cell_ids
    )

  active_ids <-
    as.integer(
      ctx$ids
    )

  position <-
    match(
      cell_ids,
      active_ids
    )

  if (anyNA(
        position
      )) {
    landisR_stop(
      "Une cellule demandee est absente du contexte actif."
    )
  }

  if (!is.null(
        ctx$targets
      ) &&
      is.matrix(
        ctx$targets
      ) &&
      nrow(
        ctx$targets
      ) ==
        length(
          active_ids
        ) &&
      ncol(
        ctx$targets
      ) >=
        2L) {

    row <-
      as.integer(
        ctx$targets[
          position,
          1L
        ]
      )

    col <-
      as.integer(
        ctx$targets[
          position,
          2L
        ]
      )

  } else if (!is.null(
               ctx$nrow
             )) {

    nr <-
      as.integer(
        ctx$nrow
      )

    row <-
      as.integer(
        ((cell_ids - 1L) %% nr) + 1L
      )

    col <-
      as.integer(
        ((cell_ids - 1L) %/% nr) + 1L
      )

  } else {
    landisR_stop(
      "Le contexte ne contient pas les coordonnees de grille necessaires."
    )
  }

  if (!is.null(
        ctx$active_eco
      ) &&
      length(
        ctx$active_eco
      ) ==
        length(
          active_ids
        )) {

    eco_internal <-
      as.integer(
        ctx$active_eco[
          position
        ]
      )

  } else if (!is.null(
               ctx$eco
             )) {

    eco_internal <-
      as.integer(
        ctx$eco[
          cell_ids
        ]
      )

  } else {

    eco_internal <-
      rep(
        NA_integer_,
        length(
          cell_ids
        )
      )
  }

  ecoregion <-
    as.character(
      eco_internal
    )

  if (!is.null(
        ctx$ecoregion_code
      ) &&
      length(
        ctx$ecoregion_code
      ) &&
      !is.null(
        names(
          ctx$ecoregion_code
        )
      )) {

    labels <-
      names(
        ctx$ecoregion_code
      )

    values <-
      as.integer(
        unname(
          ctx$ecoregion_code
        )
      )

    translated <-
      labels[
        match(
          eco_internal,
          values
        )
      ]

    good <-
      !is.na(
        translated
      )

    ecoregion[good] <-
      translated[good]
  }

  data.frame(
    cell_id = cell_ids,
    row = row,
    col = col,
    ecoregion = ecoregion,
    stringsAsFactors = FALSE
  )
}

landisR_validate_snapshot_object <- function(
    snapshot,
    path) {

  if (!is.list(
        snapshot
      ) ||
      is.null(
        snapshot$format
      ) ||
      !grepl(
        "^landisR52/state-snapshot-v",
        snapshot$format
      ) ||
      is.null(
        snapshot$cell_id
      ) ||
      is.null(
        snapshot$state_id
      ) ||
      is.null(
        snapshot$state_biomass
      )) {
    landisR_stop(
      "Snapshot landisR invalide : ",
      path
    )
  }

  snapshot
}

landisR_state_run <- function(
    run,
    representation = c(
      "compact",
      "cohorts",
      "biomass"
    ),
    cells = NULL,
    year = NULL) {

  representation <-
    match.arg(
      representation
    )

  if (identical(
        representation,
        "compact"
      ) ||
      identical(
        representation,
        "biomass"
      )) {

    selected <-
      landisR_run_pick_state_file(
        run,
        type = "snapshot",
        year = year
      )

    snapshot <-
      landisR_validate_snapshot_object(
        readRDS(
          selected$path
        ),
        selected$path
      )

    if (identical(
          representation,
          "compact"
        )) {

      if (!is.null(
            cells
          )) {
        landisR_stop(
          "cells n'est pas utilise avec representation='compact'."
        )
      }

      return(
        snapshot
      )
    }

    active_ids <-
      as.integer(
        snapshot$cell_id
      )

    if (is.null(
          cells
        )) {
      selected_ids <-
        active_ids
    } else {
      selected_ids <-
        unique(
          as.integer(
            cells
          )
        )

      if (anyNA(
            selected_ids
          ) ||
          any(
            !selected_ids %in%
              active_ids
          )) {
        landisR_stop(
          "cells contient une cellule absente ou inactive."
        )
      }
    }

    position <-
      match(
        selected_ids,
        active_ids
      )

    state_id <-
      as.integer(
        snapshot$state_id[
          position
        ]
      )

    biomass <-
      snapshot$state_biomass[
        state_id,
        ,
        drop = FALSE
      ]

    if (is.null(
          colnames(
            biomass
          )
        ) &&
        !is.null(
          snapshot$species
        )) {
      colnames(
        biomass
      ) <-
        as.character(
          snapshot$species
        )
    }

    ctx <-
      landisR_load_run_context(
        run
      )

    metadata <-
      landisR_context_cell_metadata(
        ctx,
        selected_ids
      )

    out <-
      data.frame(
        metadata,
        biomass,
        TotalBiomass =
          snapshot$state_total_biomass[
            state_id
          ],
        AGE_MAX =
          snapshot$state_max_age[
            state_id
          ],
        check.names = FALSE,
        stringsAsFactors = FALSE
      )

    rownames(
      out
    ) <-
      NULL

    attr(
      out,
      "year"
    ) <-
      selected$year

    attr(
      out,
      "source_file"
    ) <-
      selected$path

    return(
      out
    )
  }

  selected <-
    landisR_run_pick_state_file(
      run,
      type = "checkpoint",
      year = year
    )

  checkpoint <-
    readRDS(
      selected$path
    )

  if (!is.list(
        checkpoint
      ) ||
      is.null(
        checkpoint$format
      ) ||
      !grepl(
        "^landisR52/state-checkpoint-v",
        checkpoint$format
      ) ||
      is.null(
        checkpoint$states
      ) ||
      is.null(
        checkpoint$cell_state
      )) {
    landisR_stop(
      "Checkpoint landisR invalide : ",
      selected$path
    )
  }

  ctx <-
    landisR_load_run_context(
      run
    )

  active_ids <-
    as.integer(
      ctx$ids
    )

  if (is.null(
        cells
      )) {
    selected_ids <-
      active_ids
  } else {
    selected_ids <-
      unique(
        as.integer(
          cells
        )
      )

    if (anyNA(
          selected_ids
        ) ||
        any(
          !selected_ids %in%
            active_ids
        )) {
      landisR_stop(
        "cells contient une cellule absente ou inactive."
      )
    }
  }

  if (length(
        selected_ids
      ) >
      100000L) {
    warning(
      "Expansion de plus de 100 000 cellules en cohortes. ",
      "Cette representation peut etre volumineuse.",
      call. = FALSE
    )
  }

  position <-
    match(
      selected_ids,
      active_ids
    )

  states <-
    bs52_csr_to_states_cpp(
      checkpoint$states,
      as.character(
        ctx$config$species$species
      )
    )

  metadata <-
    landisR_context_cell_metadata(
      ctx,
      selected_ids
    )

  pieces <-
    lapply(
      seq_along(
        selected_ids
      ),
      function(i) {

        state_id <-
          as.integer(
            checkpoint$cell_state[
              position[i]]
          )

        x <-
          states[[state_id]]

        if (!nrow(
              x
            )) {
          return(
            NULL
          )
        }

        data.frame(
          cell_id =
            rep(
              metadata$cell_id[i],
              nrow(
                x
              )
            ),
          row =
            rep(
              metadata$row[i],
              nrow(
                x
              )
            ),
          col =
            rep(
              metadata$col[i],
              nrow(
                x
              )
            ),
          ecoregion =
            rep(
              metadata$ecoregion[i],
              nrow(
                x
              )
            ),
          species =
            as.character(
              x$species
            ),
          age =
            as.numeric(
              x$age
            ),
          biomass =
            as.numeric(
              x$biomass
            ),
          stringsAsFactors = FALSE
        )
      }
    )

  pieces <-
    pieces[
      !vapply(
        pieces,
        is.null,
        logical(
          1
        )
      )
    ]

  if (!length(
        pieces
      )) {
    out <-
      data.frame(
        cell_id = integer(),
        row = integer(),
        col = integer(),
        ecoregion = character(),
        species = character(),
        age = numeric(),
        biomass = numeric(),
        stringsAsFactors = FALSE
      )
  } else {
    out <-
      do.call(
        rbind,
        pieces
      )

    rownames(
      out
    ) <-
      NULL
  }

  attr(
    out,
    "year"
  ) <-
    selected$year

  attr(
    out,
    "source_file"
  ) <-
    selected$path

  out
}

.landisR_legacy_state_270F <- function(
    simulation,
    representation = c(
      "compact",
      "cohorts",
      "biomass"
    ),
    cells = NULL,
    year = NULL) {

  representation <-
    match.arg(
      representation
    )

  if (inherits(
        simulation,
        "landisR_run"
      )) {
    return(
      landisR_state_run(
        simulation,
        representation = representation,
        cells = cells,
        year = year
      )
    )
  }

  simulation <-
    landisR_validate_simulation(
      simulation
    )

  if (!is.null(
        year
      )) {
    year <-
      landisR_scalar_integer(
        year,
        "year",
        0L
      )

    if (!identical(
          as.integer(
            year
          ),
          as.integer(
            simulation$year
          )
        )) {
      landisR_stop(
        "Pour un landisR_simulation en memoire, year doit etre NULL ou egal a l'annee courante (",
        simulation$year,
        ")."
      )
    }
  }

  if (identical(
        representation,
        "compact"
      )) {

    if (!is.null(
          cells
        )) {
      landisR_stop(
        "cells n'est pas utilise avec representation='compact'."
      )
    }

    return(
      bs52_large_compact_snapshot52(
        simulation$states,
        simulation$state_eco,
        simulation$cell_state,
        simulation$ctx,
        simulation$year
      )
    )
  }

  active_ids <-
    as.integer(
      simulation$ctx$ids
    )

  if (is.null(
        cells
      )) {

    selected_ids <-
      active_ids

  } else {

    selected_ids <-
      unique(
        as.integer(
          cells
        )
      )

    if (anyNA(
          selected_ids
        ) ||
        any(
          !selected_ids %in%
            active_ids
        )) {

      landisR_stop(
        "cells contient une cellule absente ou inactive."
      )
    }
  }

  position <-
    match(
      selected_ids,
      active_ids
    )

  if (identical(
        representation,
        "biomass"
      )) {

    snapshot <-
      bs52_large_compact_snapshot52(
        simulation$states,
        simulation$state_eco,
        simulation$cell_state,
        simulation$ctx,
        simulation$year
      )

    state_id <-
      snapshot$state_id[
        position
      ]

    biomass <-
      snapshot$state_biomass[
        state_id,
        ,
        drop = FALSE
      ]

    cells_table <-
      simulation$project$canonical$landscape$cells[
        selected_ids,
        ,
        drop = FALSE
      ]

    out <-
      data.frame(
        cell_id =
          selected_ids,
        row =
          as.integer(
            cells_table$row
          ),
        col =
          as.integer(
            cells_table$col
          ),
        ecoregion =
          as.character(
            cells_table$ecoregion
          ),
        biomass,
        TotalBiomass =
          snapshot$state_total_biomass[
            state_id
          ],
        AGE_MAX =
          snapshot$state_max_age[
            state_id
          ],
        check.names = FALSE,
        stringsAsFactors = FALSE
      )

    rownames(
      out
    ) <-
      NULL

    return(
      out
    )
  }

  if (length(
        selected_ids
      ) >
      100000L) {

    warning(
      "Expansion de plus de 100 000 cellules en cohortes. ",
      "Cette representation peut etre volumineuse.",
      call. = FALSE
    )
  }

  states <-
    landisR_state_list(
      simulation
    )

  cells_table <-
    simulation$project$canonical$landscape$cells

  pieces <-
    lapply(
      seq_along(
        selected_ids
      ),
      function(i) {

        cell_id <-
          selected_ids[i]

        active_position <-
          position[i]

        state_id <-
          simulation$cell_state[
            active_position
          ]

        x <-
          states[[state_id]]

        if (!nrow(
              x
            )) {

          return(
            NULL
          )
        }

        data.frame(
          cell_id =
            rep(
              cell_id,
              nrow(
                x
              )
            ),
          row =
            rep(
              as.integer(
                cells_table$row[
                  cell_id
                ]
              ),
              nrow(
                x
              )
            ),
          col =
            rep(
              as.integer(
                cells_table$col[
                  cell_id
                ]
              ),
              nrow(
                x
              )
            ),
          ecoregion =
            rep(
              as.character(
                cells_table$ecoregion[
                  cell_id
                ]
              ),
              nrow(
                x
              )
            ),
          species =
            as.character(
              x$species
            ),
          age =
            as.numeric(
              x$age
            ),
          biomass =
            as.numeric(
              x$biomass
            ),
          stringsAsFactors = FALSE
        )
      }
    )

  pieces <-
    pieces[
      !vapply(
        pieces,
        is.null,
        logical(
          1
        )
      )
    ]

  if (!length(
        pieces
      )) {

    return(
      data.frame(
        cell_id = integer(),
        row = integer(),
        col = integer(),
        ecoregion = character(),
        species = character(),
        age = numeric(),
        biomass = numeric(),
        stringsAsFactors = FALSE
      )
    )
  }

  out <-
    do.call(
      rbind,
      pieces
    )

  rownames(
    out
  ) <-
    NULL

  out
}

landis_update <- function(
    project = NULL,
    canonical = NULL,
    landscape = NULL,
    species = NULL,
    species_parameters = NULL,
    ecoregions = NULL,
    ecoregion_parameters = NULL,
    dynamic = NULL,
    dynamic_mode = c(
      "merge",
      "replace"
    ),
    shade = NULL,
    light = NULL,
    fire_reductions = NULL,
    cohorts = NULL,
    clear_cells = integer(),
    settings = list(),
    metadata = list(),
    preserve_cohort_order = FALSE) {

  if (!is.logical(preserve_cohort_order) || length(preserve_cohort_order) != 1L ||
      is.na(preserve_cohort_order))
    landisR_stop("preserve_cohort_order must be TRUE or FALSE.")

  dynamic_mode <-
    match.arg(
      dynamic_mode
    )

  if (!is.null(
        project
      ) &&
      !inherits(
        project,
        "landisR_project"
      )) {
    landisR_stop(
      "project doit etre NULL ou un landisR_project."
    )
  }

  if (!is.null(
        canonical
      ) &&
      !is.list(
        canonical
      ) &&
      !is.function(
        canonical
      )) {
    landisR_stop(
      "canonical doit etre NULL, une liste canonique ou une fonction."
    )
  }

  if (!is.null(
        cohorts
      )) {

    cohorts <-
      landisR_require_columns(
        cohorts,
        c(
          "cell_id",
          "species",
          "age",
          "biomass"
        ),
        "cohorts",
        exact = FALSE
      )

    cohorts <-
      cohorts[
        c(
          "cell_id",
          "species",
          "age",
          "biomass"
        )
      ]
  }

  clear_cells <-
    unique(
      as.integer(
        clear_cells
      )
    )

  if (anyNA(
        clear_cells
      )) {
    landisR_stop(
      "clear_cells contient NA."
    )
  }

  if (!is.list(
        settings
      ) ||
      !is.list(
        metadata
      )) {
    landisR_stop(
      "settings et metadata doivent etre des listes."
    )
  }

  out <-
    list(
      format =
        "landisR/update-v1",
      project =
        project,
      canonical =
        canonical,
      landscape =
        landscape,
      species =
        species,
      species_parameters =
        species_parameters,
      ecoregions =
        ecoregions,
      ecoregion_parameters =
        ecoregion_parameters,
      dynamic =
        dynamic,
      dynamic_mode =
        dynamic_mode,
      shade =
        shade,
      light =
        light,
      fire_reductions =
        fire_reductions,
      cohorts =
        cohorts,
      clear_cells =
        clear_cells,
      preserve_cohort_order = preserve_cohort_order,
      settings =
        settings,
      metadata =
        metadata
    )

  class(
    out
  ) <-
    "landisR_update"

  out
}

print.landisR_update <- function(
    x,
    ...) {

  cat(
    "<landisR_update>\n",
    sep = ""
  )

  components <-
    c(
      "project",
      "canonical",
      "landscape",
      "species",
      "species_parameters",
      "ecoregions",
      "ecoregion_parameters",
      "dynamic",
      "shade",
      "light",
      "fire_reductions",
      "cohorts"
    )

  changed <-
    components[
      !vapply(
        components,
        function(name) {
          is.null(
            x[[name]]
          )
        },
        logical(
          1
        )
      )
    ]

  if (length(
        x$clear_cells
      )) {
    changed <-
      c(
        changed,
        "clear_cells"
      )
  }

  if (length(
        x$settings
      )) {
    changed <-
      c(
        changed,
        "settings"
      )
  }

  cat(
    "  components: ",
    if (length(
          changed
        )) {
      paste(
        changed,
        collapse = ", "
      )
    } else {
      "none"
    },
    "\n",
    sep = ""
  )

  invisible(
    x
  )
}

landisR_merge_dynamic <- function(
    base,
    patch) {

  patch <-
    landisR_require_columns(
      patch,
      c(
        "year",
        "ecoregion",
        "species",
        "sep",
        "max_anpp",
        "max_biomass"
      ),
      "dynamic",
      exact = TRUE
    )

  key_base <-
    paste(
      base$year,
      base$ecoregion,
      base$species,
      sep = "\r"
    )

  key_patch <-
    paste(
      patch$year,
      patch$ecoregion,
      patch$species,
      sep = "\r"
    )

  if (anyDuplicated(
        key_patch
      )) {
    landisR_stop(
      "dynamic contient des cles dupliquees."
    )
  }

  index <-
    match(
      key_patch,
      key_base
    )

  replace_rows <-
    !is.na(
      index
    )

  if (any(
        replace_rows
      )) {

    base[
      index[
        replace_rows
      ],
      names(
        patch
      )
    ] <-
      patch[
        replace_rows,
        ,
        drop = FALSE
      ]
  }

  if (any(
        !replace_rows
      )) {

    base <-
      rbind(
        base,
        patch[
          !replace_rows,
          ,
          drop = FALSE
        ]
      )
  }

  base <-
    base[
      order(
        base$year,
        base$ecoregion,
        base$species
      ),
      ,
      drop = FALSE
    ]

  rownames(
    base
  ) <-
    NULL

  base
}

landisR_project_from_update <- function(
    simulation,
    update) {

  project <-
    if (!is.null(
          update$project
        )) {
      update$project
    } else {
      simulation$project
    }

  canonical <-
    project$canonical

  if (!is.null(
        update$canonical
      )) {

    if (is.function(
          update$canonical
        )) {

      canonical <-
        update$canonical(
          canonical
        )

    } else {

      canonical <-
        update$canonical
    }
  }

  replacements <-
    c(
      "species",
      "species_parameters",
      "ecoregions",
      "ecoregion_parameters",
      "shade",
      "light",
      "fire_reductions"
    )

  for (name in replacements) {

    value <-
      update[[name]]

    if (!is.null(
          value
        )) {
      canonical[[name]] <-
        value
    }
  }

  if (!is.null(
        update$landscape
      )) {

    canonical$landscape$cells <-
      update$landscape

    canonical$landscape$active <-
      as.logical(
        update$landscape$active
      )
  }

  if (!is.null(
        update$dynamic
      )) {

    if (identical(
          update$dynamic_mode,
          "replace"
        )) {

      canonical$dynamic <-
        update$dynamic

    } else {

      canonical$dynamic <-
        landisR_merge_dynamic(
          canonical$dynamic,
          update$dynamic
        )
    }
  }

  if (length(
        update$settings
      )) {

    allowed <-
      c(
        "duration",
        "spinup_cohorts",
        "spinup_mortality",
        "seeding"
      )

    unknown <-
      setdiff(
        names(
          update$settings
        ),
        allowed
      )

    if (length(
          unknown
        )) {
      landisR_stop(
        "Settings non modifiables via landis_update() : ",
        paste(
          unknown,
          collapse = ", "
        )
      )
    }

    for (name in names(
           update$settings
         )) {
      canonical[[name]] <-
        update$settings[[name]]
    }
  }

  canonical <-
    landisR_validate_canonical(
      canonical
    )

  landisR_project(
    canonical =
      canonical,
    source_type =
      "interactive_update",
    source =
      list(
        parent =
          simulation$project$name,
        year =
          simulation$year,
        metadata =
          update$metadata
      ),
    canonical_directory =
      NULL,
    name =
      project$name
  )
}

landisR_assert_project_compatible <- function(
    simulation,
    project) {

  old <-
    simulation$project$canonical

  new <-
    project$canonical

  if (!identical(
        as.integer(
          old$timestep
        ),
        as.integer(
          new$timestep
        )
      )) {
    landisR_stop(
      "Le timestep ne peut pas changer au milieu d'une simulation."
    )
  }

  if (!isTRUE(
        all.equal(
          as.numeric(
            old$cell_length
          ),
          as.numeric(
            new$cell_length
          ),
          tolerance = 0,
          check.attributes = FALSE
        )
      )) {
    landisR_stop(
      "cell_length ne peut pas changer au milieu d'une simulation."
    )
  }

  if (new$duration <
      simulation$year) {
    landisR_stop(
      "La nouvelle duree du projet est anterieure a l'annee courante."
    )
  }

  old_species <-
    as.character(
      old$species$species
    )

  new_species <-
    as.character(
      new$species$species
    )

  if (!identical(
        old_species,
        new_species
      )) {
    landisR_stop(
      "La liste et l'ordre des especes ne peuvent pas encore changer en cours ",
      "de simulation. Cette restriction pourra etre relachee dans une version ",
      "future de l'API."
    )
  }

  old_ids <-
    as.integer(
      old$landscape$ids
    )

  new_ids <-
    as.integer(
      new$landscape$ids
    )

  if (!identical(
        old_ids,
        new_ids
      ) ||
      !identical(
        as.integer(
          old$landscape$nrow
        ),
        as.integer(
          new$landscape$nrow
        )
      ) ||
      !identical(
        as.integer(
          old$landscape$ncol
        ),
        as.integer(
          new$landscape$ncol
        )
      )) {

    landisR_stop(
      "La geometrie et l'ensemble des cellules actives ne peuvent pas encore ",
      "changer en cours de simulation."
    )
  }

  invisible(
    TRUE
  )
}

landisR_rebind_project <- function(
    simulation,
    project) {

  landisR_assert_project_compatible(
    simulation,
    project
  )

  old_states <-
    landisR_state_list(
      simulation
    )

  new_ctx <-
    landisR_biomass_backend()$context(project$canonical, v7 = !is.null(simulation$landis_rng))

  pair_key <-
    paste(
      simulation$cell_state,
      new_ctx$active_eco,
      sep = "\r"
    )

  first <-
    !duplicated(
      pair_key
    )

  unique_key <-
    pair_key[
      first
    ]

  old_state_id <-
    simulation$cell_state[
      first
    ]

  new_state_eco <-
    as.integer(
      new_ctx$active_eco[
        first
      ]
    )

  new_states_list <-
    old_states[
      old_state_id
    ]

  new_states <-
    bs52_states_list_to_csr_cpp(
      new_states_list,
      as.character(
        project$canonical$species$species
      )
    )

  new_cell_state <-
    as.integer(
      match(
        pair_key,
        unique_key
      )
    )

  new_ctx$states <-
    new_states

  new_ctx$state_eco <-
    new_state_eco

  new_ctx$cell_state <-
    new_cell_state

  simulation$project <-
    project

  simulation$ctx <-
    new_ctx

  simulation$states <-
    new_states

  simulation$state_eco <-
    new_state_eco

  simulation$cell_state <-
    new_cell_state

  simulation
}

landisR_normalize_cohort_state <- function(
    x,
    species_names) {

  if (!nrow(
        x
      )) {

    return(
      data.frame(
        species = character(),
        age = numeric(),
        biomass = numeric(),
        stringsAsFactors = FALSE
      )
    )
  }

  x <-
    x[
      c(
        "species",
        "age",
        "biomass"
      )
    ]

  x$species <-
    as.character(
      x$species
    )

  x$age <-
    as.numeric(
      x$age
    )

  x$biomass <-
    as.numeric(
      x$biomass
    )

  if (anyNA(
        x
      ) ||
      any(
        !x$species %in%
          species_names
      ) ||
      any(
        x$age <
          1
      ) ||
      any(
        !is.finite(
          x$age
        )
      ) ||
      any(
        x$age !=
          trunc(
            x$age
          )
      ) ||
      any(
        !is.finite(
          x$biomass
        )
      ) ||
      any(
        x$biomass <
          0
      ) ||
      anyDuplicated(
        x[
          c(
            "species",
            "age"
          )
        ]
      )) {

    landisR_stop(
      "Etat de cohortes invalide."
    )
  }

  x <-
    x[
      x$biomass >
        0,
      ,
      drop = FALSE
    ]

  if (!nrow(
        x
      )) {

    rownames(
      x
    ) <-
      NULL

    return(
      x
    )
  }

  species_index <-
    match(
      x$species,
      species_names
    )

  x <-
    x[
      order(
        species_index,
        x$age
      ),
      ,
      drop = FALSE
    ]

  rownames(
    x
  ) <-
    NULL

  x
}

landisR_state_key <- function(
    x,
    eco,
    species_names) {

  normalized <-
    landisR_normalize_cohort_state(
      x,
      species_names
    )

  raw <-
    serialize(
      list(
        eco =
          as.integer(
            eco
          ),
        species =
          as.character(
            normalized$species
          ),
        age =
          as.numeric(
            normalized$age
          ),
        biomass =
          as.numeric(
            normalized$biomass
          )
      ),
      NULL,
      version =
        2
    )

  paste(
    as.character(
      raw
    ),
    collapse = ""
  )
}

.landisR_legacy_apply_270F <- function(
    simulation,
    cohorts,
    clear_cells) {

  if (is.null(
        cohorts
      ) &&
      !length(
        clear_cells
      )) {

    return(
      simulation
    )
  }

  active_ids <-
    as.integer(
      simulation$ctx$ids
    )

  species_names <-
    as.character(
      simulation$project$canonical$species$species
    )

  if (is.null(
        cohorts
      )) {

    cohorts <-
      data.frame(
        cell_id = integer(),
        species = character(),
        age = numeric(),
        biomass = numeric(),
        stringsAsFactors = FALSE
      )

  } else {

    cohorts$cell_id <-
      as.integer(
        cohorts$cell_id
      )

    cohorts$species <-
      as.character(
        cohorts$species
      )

    cohorts$age <-
      as.numeric(
        cohorts$age
      )

    cohorts$biomass <-
      as.numeric(
        cohorts$biomass
      )

    if (anyNA(
          cohorts
        ) ||
        any(
          !cohorts$cell_id %in%
            active_ids
        ) ||
        any(
          !cohorts$species %in%
            species_names
        ) ||
        any(
          cohorts$age <
            1
        ) ||
        any(
          cohorts$age !=
            trunc(
              cohorts$age
            )
        ) ||
        any(
          cohorts$biomass <
            0
        ) ||
        any(
          !is.finite(
            cohorts$biomass
          )
        ) ||
        anyDuplicated(
          cohorts[
            c(
              "cell_id",
              "species",
              "age"
            )
          ]
        )) {

      landisR_stop(
        "cohorts contient des valeurs invalides."
      )
    }
  }

  clear_cells <-
    unique(
      as.integer(
        clear_cells
      )
    )

  if (any(
        !clear_cells %in%
          active_ids
      )) {
    landisR_stop(
      "clear_cells contient une cellule absente ou inactive."
    )
  }

  replacement_cells <-
    unique(
      c(
        clear_cells,
        as.integer(
          cohorts$cell_id
        )
      )
    )

  if (!length(
        replacement_cells
      )) {

    return(
      simulation
    )
  }

  states_list <-
    landisR_state_list(
      simulation
    )

  state_eco <-
    as.integer(
      simulation$state_eco
    )

  state_keys <-
    vapply(
      seq_along(
        states_list
      ),
      function(i) {

        landisR_state_key(
          states_list[[i]],
          state_eco[i],
          species_names
        )
      },
      character(
        1
      )
    )

  cell_state <-
    as.integer(
      simulation$cell_state
    )

  for (cell_id in replacement_cells) {

    active_position <-
      match(
        cell_id,
        active_ids
      )

    eco <-
      as.integer(
        simulation$ctx$active_eco[
          active_position
        ]
      )

    replacement <-
      cohorts[
        cohorts$cell_id ==
          cell_id,
        c(
          "species",
          "age",
          "biomass"
        ),
        drop = FALSE
      ]

    replacement <-
      landisR_normalize_cohort_state(
        replacement,
        species_names
      )

    key <-
      landisR_state_key(
        replacement,
        eco,
        species_names
      )

    state_id <-
      match(
        key,
        state_keys
      )

    if (is.na(
          state_id
        )) {

      states_list[[length(states_list) + 1L]] <-
        replacement

      state_eco <-
        c(
          state_eco,
          eco
        )

      state_keys <-
        c(
          state_keys,
          key
        )

      state_id <-
        length(
          states_list
        )
    }

    cell_state[
      active_position
    ] <-
      as.integer(
        state_id
      )
  }

  used <-
    unique(
      cell_state
    )

  remap <-
    integer(
      length(
        states_list
      )
    )

  remap[
    used
  ] <-
    seq_along(
      used
    )

  cell_state <-
    as.integer(
      remap[
        cell_state
      ]
    )

  states_list <-
    states_list[
      used
    ]

  state_eco <-
    as.integer(
      state_eco[
        used
      ]
    )

  states <-
    bs52_states_list_to_csr_cpp(
      states_list,
      species_names
    )

  simulation$states <-
    states

  simulation$state_eco <-
    state_eco

  simulation$cell_state <-
    cell_state

  simulation$ctx$states <-
    states

  simulation$ctx$state_eco <-
    state_eco

  simulation$ctx$cell_state <-
    cell_state

  simulation
}

landis_apply <- function(
    simulation,
    update) {

  simulation <-
    landisR_validate_simulation(
      simulation
    )

  if (is.function(
        update
      )) {

    update <-
      update(
        simulation
      )
  }

  if (!inherits(
        update,
        "landisR_update"
      ) ||
      !identical(
        update$format,
        "landisR/update-v1"
      )) {

    landisR_stop(
      "update doit etre un landisR_update ou une fonction retournant un ",
      "landisR_update."
    )
  }

  project_change <-
    !is.null(
      update$project
    ) ||
      !is.null(
        update$canonical
      ) ||
      !is.null(
        update$landscape
      ) ||
      !is.null(
        update$species
      ) ||
      !is.null(
        update$species_parameters
      ) ||
      !is.null(
        update$ecoregions
      ) ||
      !is.null(
        update$ecoregion_parameters
      ) ||
      !is.null(
        update$dynamic
      ) ||
      !is.null(
        update$shade
      ) ||
      !is.null(
        update$light
      ) ||
      !is.null(
        update$fire_reductions
      ) ||
      length(
        update$settings
      ) >
        0L

  if (project_change) {
    if (inherits(simulation$project, "landisR_landscape_project"))
      landisR_stop("Landscape-only projects support cohort updates through landis_apply().")

    project <-
      landisR_project_from_update(
        simulation,
        update
      )

    simulation <-
      landisR_rebind_project(
        simulation,
        project
      )
  }

  simulation <-
    landisR_apply_cohorts(
      simulation,
      update$cohorts,
      update$clear_cells,
      preserve_order = isTRUE(update$preserve_cohort_order)
    )

  simulation$history[[length(simulation$history) + 1L]] <-
    landisR_event(
      simulation$year,
      "apply",
      update$metadata
    )

  simulation
}

# >>> FIX 107: context-cache wrapper support >>>
# ==============================================================================
# FIX 107 - landis_state() support for production context-cache wrapper
#
# Production landisR stores context.rds as:
#   list(
#     format = "landisR52/context-cache-v1",
#     signature = ...,
#     context = <actual context>
#   )
#
# landis_state() initially assumed context.rds contained the actual context
# directly. This helper accepts both representations.
# ==============================================================================

landisR_load_run_context <- function(run) {

  context_candidates <-
    landisR_run_context_candidates(
      run
    )

  existing_context <-
    context_candidates[
      file.exists(
        context_candidates
      )
    ]

  if (length(
        existing_context
      )) {

    cached <-
      readRDS(
        existing_context[1L]
      )

    # Current production cache: wrapper around the actual context.
    if (is.list(
          cached
        ) &&
        !is.null(
          cached$format
        ) &&
        grepl(
          "^landisR52/context-cache-v",
          as.character(
            cached$format
          )
        ) &&
        is.list(
          cached$context
        )) {

      ctx <-
        cached$context

    } else {

      # Backward compatibility with older/direct context caches.
      ctx <-
        cached
    }

    if (!is.list(
          ctx
        ) ||
        is.null(
          ctx$ids
        ) ||
        is.null(
          ctx$config
        )) {
      landisR_stop(
        "Le cache de contexte landisR est invalide : ",
        existing_context[1L]
      )
    }

    return(
      ctx
    )
  }

  canonical_candidates <-
    landisR_run_canonical_candidates(
      run,
      context_candidates
    )

  existing_canonical <-
    canonical_candidates[
      dir.exists(
        canonical_candidates
      )
    ]

  if (length(
        existing_canonical
      )) {

    biomass <- landisR_biomass_backend()

    canonical <-
      biomass$read_canonical(
        existing_canonical[1L]
      )

    return(
      biomass$context(
        canonical
      )
    )
  }

  landisR_stop(
    "Impossible de retrouver le contexte de la simulation. ",
    "Le cache context.rds et les entrees canoniques sont absents."
  )
}
# <<< FIX 107: context-cache wrapper support <<<
