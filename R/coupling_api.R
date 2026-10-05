# ==============================================================================
# coupling_api.R
#
# Generic coupling layer for landisR.
#
# This file intentionally contains NO biological process implementation.
# It provides:
#   - capability discovery;
#   - requirement checking;
#   - a lightweight optional modifier wrapper around arbitrary R functions.
#
# Full disturbance extensions do NOT need to use landis_modifier(). They can
# independently compute a landisR_update and pass it to landis_apply().
#
# The validated Biomass Succession 5.2 scientific engine is not modified.
# ==============================================================================

landisR_capabilities_biomass52 <- function(
    simulation = NULL) {

  available <-
    c(
      "engine.biomass52",
      "state.compact",
      "state.cohorts",
      "state.biomass",
      "update.project",
      "update.canonical",
      "update.landscape",
      "update.species",
      "update.species_parameters",
      "update.ecoregions",
      "update.ecoregion_parameters",
      "update.dynamic",
      "update.shade",
      "update.light",
      "update.fire_reductions",
      "update.cohorts",
      "update.clear_cells",
      "disturbance.fire",
      "reproduction.serotiny.facultative",
      "reproduction.serotiny.strict",
      "reproduction.serotiny.local",
      "reproduction.serotiny.kernel",
      "engine_input.sep",
      "engine_input.max_anpp",
      "engine_input.max_biomass",
      "context.year",
      "context.timestep",
      "context.project",
      "context.landscape",
      "context.active_cells",
      "context.ward_neighborhood_geometry"
    )

  current <-
    if (is.null(
          simulation
        )) {
      list(
        year = NULL,
        timestep = NULL,
        active_cells = NULL,
        nrow = NULL,
        ncol = NULL,
        cell_length = NULL
      )
    } else {
      list(
        year =
          as.integer(
            simulation$year
          ),
        timestep =
          as.integer(
            simulation$project$canonical$timestep
          ),
        active_cells =
          length(
            simulation$ctx$ids
          ),
        nrow =
          as.integer(
            simulation$project$canonical$landscape$nrow
          ),
        ncol =
          as.integer(
            simulation$project$canonical$landscape$ncol
          ),
        cell_length =
          as.numeric(
            simulation$project$canonical$cell_length
          )
      )
    }

  out <-
    list(
      format =
        "landisR/capabilities-v1",
      api_version =
        1L,
      growth_engine =
        list(
          id =
            "biomass52",
          label =
            "LANDIS-II Biomass Succession 5.2",
          version =
            "5.2"
        ),
      state =
        c(
          compact = TRUE,
          cohorts = TRUE,
          biomass = TRUE
        ),
      updates =
        c(
          project = TRUE,
          canonical = TRUE,
          landscape = TRUE,
          species = TRUE,
          species_parameters = TRUE,
          ecoregions = TRUE,
          ecoregion_parameters = TRUE,
          dynamic = TRUE,
          shade = TRUE,
          light = TRUE,
          fire_reductions = TRUE,
          cohorts = TRUE,
          clear_cells = TRUE
        ),
      engine_inputs =
        c(
          sep = TRUE,
          max_anpp = TRUE,
          max_biomass = TRUE
        ),
      context =
        c(
          year = TRUE,
          timestep = TRUE,
          project = TRUE,
          landscape = TRUE,
          active_cells = TRUE,
          ward_neighborhood_geometry = TRUE
        ),
      structural_changes =
        c(
          timestep = FALSE,
          cell_length = FALSE,
          grid_dimensions = FALSE,
          active_cell_set = FALSE,
          species_registry = FALSE
        ),
      current =
        current,
      available =
        sort(
          unique(
            available
          )
        )
    )

  class(
    out
  ) <-
    "landisR_capabilities"

  out
}

landis_capabilities <- function(
    x) {

  if (inherits(
        x,
        "landisR_simulation"
      )) {

    simulation <-
      landisR_validate_simulation(
        x
      )

    if (identical(
          simulation$growth_engine$id,
          "biomass52"
        )) {

      return(
        landisR_capabilities_biomass52(
          simulation
        )
      )
    }

    landisR_stop(
      "Aucun registre de capacites pour le moteur : ",
      simulation$growth_engine$id
    )
  }

  if (inherits(
        x,
        "landisR_growth_engine"
      )) {

    engine <-
      landisR_validate_growth_engine(
        x
      )

    if (identical(
          engine$id,
          "biomass52"
        )) {

      return(
        landisR_capabilities_biomass52()
      )
    }

    landisR_stop(
      "Aucun registre de capacites pour le moteur : ",
      engine$id
    )
  }

  landisR_stop(
    "x doit etre un landisR_simulation ou un landisR_growth_engine."
  )
}

print.landisR_capabilities <- function(
    x,
    ...) {

  cat(
    "<landisR_capabilities>\n",
    sep = ""
  )

  cat(
    "  growth engine : ",
    x$growth_engine$id,
    " ",
    x$growth_engine$version,
    "\n",
    sep = ""
  )

  if (!is.null(
        x$current$year
      )) {

    cat(
      "  year          : ",
      x$current$year,
      "\n",
      sep = ""
    )

    cat(
      "  timestep      : ",
      x$current$timestep,
      " years\n",
      sep = ""
    )

    cat(
      "  active cells  : ",
      format(
        x$current$active_cells,
        big.mark = " "
      ),
      "\n",
      sep = ""
    )
  }

  cat(
    "  capabilities  : ",
    length(
      x$available
    ),
    "\n",
    sep = ""
  )

  invisible(
    x
  )
}

landis_supports <- function(
    x,
    requirements,
    all = TRUE) {

  capabilities <-
    if (inherits(
          x,
          "landisR_capabilities"
        )) {
      x
    } else {
      landis_capabilities(
        x
      )
    }

  requirements <-
    unique(
      as.character(
        requirements
      )
    )

  if (!length(
        requirements
      )) {
    return(
      TRUE
    )
  }

  if (anyNA(
        requirements
      ) ||
      any(
        !nzchar(
          requirements
        )
      )) {
    landisR_stop(
      "requirements doit contenir des identifiants non vides."
    )
  }

  supported <-
    requirements %in%
      capabilities$available

  if (isTRUE(
        all
      )) {
    all(
      supported
    )
  } else {
    any(
      supported
    )
  }
}

landisR_assert_requirements <- function(
    capabilities,
    requirements,
    process_name = "process") {

  requirements <-
    unique(
      as.character(
        requirements
      )
    )

  if (!length(
        requirements
      )) {
    return(
      invisible(
        TRUE
      )
    )
  }

  missing <-
    requirements[
      !requirements %in%
        capabilities$available
    ]

  if (length(
        missing
      )) {

    landisR_stop(
      "Le processus '",
      process_name,
      "' requiert des capacites absentes : ",
      paste(
        missing,
        collapse = ", "
      )
    )
  }

  invisible(
    TRUE
  )
}

landisR_modifier_context <- function(
    simulation,
    capabilities) {

  canonical <-
    simulation$project$canonical

  list(
    format =
      "landisR/process-context-v1",
    year =
      as.integer(
        simulation$year
      ),
    timestep =
      as.integer(
        canonical$timestep
      ),
    project_name =
      simulation$project$name,
    growth_engine =
      simulation$growth_engine,
    capabilities =
      capabilities,
    landscape =
      canonical$landscape$cells,
    active_cells =
      as.integer(
        simulation$ctx$ids
      ),
    dimensions =
      c(
        nrow =
          as.integer(
            canonical$landscape$nrow
          ),
        ncol =
          as.integer(
            canonical$landscape$ncol
          )
      ),
    cell_length =
      as.numeric(
        canonical$cell_length
      ),
    neighborhood_geometry =
      simulation$ctx$neighborhood
  )
}

landisR_resolve_modifier_cells <- function(
    cells,
    simulation) {

  if (is.null(
        cells
      )) {
    return(
      NULL
    )
  }

  if (is.function(
        cells
      )) {

    cells <-
      cells(
        simulation
      )
  }

  cells <-
    unique(
      as.integer(
        cells
      )
    )

  if (anyNA(
        cells
      )) {
    landisR_stop(
      "cells du modifier contient NA."
    )
  }

  active <-
    as.integer(
      simulation$ctx$ids
    )

  if (any(
        !cells %in%
          active
      )) {
    landisR_stop(
      "cells du modifier contient une cellule absente ou inactive."
    )
  }

  cells
}

landisR_call_process <- function(
    fun,
    arguments) {

  if (!is.function(
        fun
      )) {
    landisR_stop(
      "fun doit etre une fonction."
    )
  }

  formal_names <-
    names(
      formals(
        fun
      )
    )

  if (is.null(
        formal_names
      )) {
    formal_names <-
      character()
  }

  if ("..." %in%
      formal_names) {

    return(
      do.call(
        fun,
        arguments
      )
    )
  }

  accepted <-
    intersect(
      names(
        arguments
      ),
      formal_names
    )

  do.call(
    fun,
    arguments[
      accepted
    ]
  )
}

landis_modifier <- function(
    fun,
    name = "modifier",
    requires = character(),
    state = c(
      "compact",
      "cohorts",
      "biomass"
    ),
    cells = NULL,
    scope = "unspecified",
    metadata = list()) {

  if (!is.function(
        fun
      )) {
    landisR_stop(
      "fun doit etre une fonction."
    )
  }

  if (!is.character(
        name
      ) ||
      length(
        name
      ) !=
        1L ||
      is.na(
        name
      ) ||
      !nzchar(
        name
      )) {
    landisR_stop(
      "name doit etre une chaine non vide."
    )
  }

  state <-
    match.arg(
      state
    )

  requires <-
    unique(
      as.character(
        requires
      )
    )

  if (anyNA(
        requires
      ) ||
      any(
        !nzchar(
          requires
        )
      )) {
    landisR_stop(
      "requires doit contenir des identifiants non vides."
    )
  }

  if (!is.character(
        scope
      ) ||
      length(
        scope
      ) !=
        1L ||
      is.na(
        scope
      ) ||
      !nzchar(
        scope
      )) {
    landisR_stop(
      "scope doit etre une chaine non vide."
    )
  }

  if (!is.null(
        cells
      ) &&
      !is.function(
        cells
      ) &&
      !is.numeric(
        cells
      )) {
    landisR_stop(
      "cells doit etre NULL, numerique ou une fonction."
    )
  }

  if (!is.list(
        metadata
      )) {
    landisR_stop(
      "metadata doit etre une liste."
    )
  }

  if (identical(
        state,
        "compact"
      ) &&
      !is.null(
        cells
      )) {
    landisR_stop(
      "cells doit etre NULL lorsque state='compact'."
    )
  }

  modifier <-
    function(simulation) {

      simulation <-
        landisR_validate_simulation(
          simulation
        )

      capabilities <-
        landis_capabilities(
          simulation
        )

      landisR_assert_requirements(
        capabilities,
        requires,
        process_name =
          name
      )

      selected_cells <-
        landisR_resolve_modifier_cells(
          cells,
          simulation
        )

      current_state <-
        landis_state(
          simulation,
          representation =
            state,
          cells =
            selected_cells
        )

      context <-
        landisR_modifier_context(
          simulation,
          capabilities
        )

      result <-
        landisR_call_process(
          fun,
          list(
            state =
              current_state,
            inputs =
              simulation$project$canonical,
            context =
              context,
            capabilities =
              capabilities,
            simulation =
              simulation
          )
        )

      if (is.null(
            result
          )) {

        result <-
          landis_update(
            metadata =
              list(
                process =
                  name,
                scope =
                  scope,
                status =
                  "no_change"
              )
          )
      }

      if (!inherits(
            result,
            "landisR_update"
          ) ||
          !identical(
            result$format,
            "landisR/update-v1"
          )) {

        landisR_stop(
          "Le modifier '",
          name,
          "' doit retourner landis_update() ou NULL."
        )
      }

      process_metadata <-
        c(
          list(
            process =
              name,
            scope =
              scope,
            process_type =
              "modifier"
          ),
          metadata
        )

      result$metadata <-
        c(
          process_metadata,
          result$metadata
        )

      result
    }

  attr(
    modifier,
    "landisR_modifier_spec"
  ) <-
    list(
      name =
        name,
      requires =
        requires,
      state =
        state,
      cells =
        cells,
      scope =
        scope,
      metadata =
        metadata
    )

  class(
    modifier
  ) <-
    c(
      "landisR_modifier",
      "function"
    )

  modifier
}

print.landisR_modifier <- function(
    x,
    ...) {

  spec <-
    attr(
      x,
      "landisR_modifier_spec"
    )

  cat(
    "<landisR_modifier>\n",
    sep = ""
  )

  cat(
    "  name        : ",
    spec$name,
    "\n",
    sep = ""
  )

  cat(
    "  state       : ",
    spec$state,
    "\n",
    sep = ""
  )

  cat(
    "  scope       : ",
    spec$scope,
    "\n",
    sep = ""
  )

  cat(
    "  requirements: ",
    if (length(
          spec$requires
        )) {
      paste(
        spec$requires,
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
