# ==============================================================================
# map_api.R
#
# Lightweight spatial display/export helpers for landisR state.
#
# landis_map() accepts:
#   - landisR_run objects saved by landis_run()
#   - landisR_simulation objects created by landis_initialize()
#   - landisR_project objects for numeric/logical landscape fields
#   - spatial data.frames containing row/col plus a numeric variable
#
# The function deliberately does not change the scientific engine.
# Current canonical inputs preserve grid row/column geometry and cell length,
# but not the original georeferenced extent/CRS. SpatRaster outputs therefore
# use relative grid coordinates unless future raster metadata are available.
# ==============================================================================

landisR_map_context <- function(x) {

  if (inherits(
        x,
        "landisR_simulation"
      )) {
    return(
      x$ctx
    )
  }

  if (inherits(
        x,
        "landisR_run"
      )) {
    return(
      landisR_load_run_context(
        x
      )
    )
  }

  NULL
}

landisR_map_grid_info <- function(
    x,
    data = NULL,
    ctx = NULL,
    grid_nrow = NULL,
    grid_ncol = NULL,
    cell_length = NULL) {

  nr <- NULL
  nc <- NULL
  cl <- NULL

  if (!is.null(
        ctx
      )) {

    nr <- ctx$nrow
    nc <- ctx$ncol

    if (!is.null(
          ctx$config$cell_length
        )) {
      cl <- ctx$config$cell_length
    }

  } else if (inherits(
               x,
               "landisR_simulation"
             )) {

    nr <- x$ctx$nrow
    nc <- x$ctx$ncol

    if (!is.null(
          x$ctx$config$cell_length
        )) {
      cl <- x$ctx$config$cell_length
    }

  } else if (inherits(
               x,
               "landisR_run"
             )) {

    ctx <-
      landisR_map_context(
        x
      )

    nr <- ctx$nrow
    nc <- ctx$ncol

    if (!is.null(
          ctx$config$cell_length
        )) {
      cl <- ctx$config$cell_length
    }

  } else if (inherits(
               x,
               "landisR_project"
             )) {

    nr <- x$canonical$landscape$nrow
    nc <- x$canonical$landscape$ncol
    cl <- x$canonical$cell_length

  } else if (is.data.frame(
               data
             )) {

    if (!all(
          c(
            "row",
            "col"
          ) %in%
            names(
              data
            )
        )) {
      landisR_stop(
        "Le data.frame a cartographier doit contenir row et col."
      )
    }

    nr <-
      suppressWarnings(
        max(
          as.integer(
            data$row
          ),
          na.rm = TRUE
        )
      )

    nc <-
      suppressWarnings(
        max(
          as.integer(
            data$col
          ),
          na.rm = TRUE
        )
      )
  }

  if (!is.null(
        grid_nrow
      )) {
    nr <-
      landisR_scalar_integer(
        grid_nrow,
        "grid_nrow",
        1L
      )
  }

  if (!is.null(
        grid_ncol
      )) {
    nc <-
      landisR_scalar_integer(
        grid_ncol,
        "grid_ncol",
        1L
      )
  }

  if (is.null(
        nr
      ) ||
      is.null(
        nc
      ) ||
      !is.finite(
        nr
      ) ||
      !is.finite(
        nc
      ) ||
      nr < 1L ||
      nc < 1L) {
    landisR_stop(
      "Impossible de determiner les dimensions completes de la grille."
    )
  }

  if (!is.null(
        cell_length
      )) {
    cl <-
      landisR_scalar_numeric(
        cell_length,
        "cell_length",
        0
      )
  }

  if (is.null(
        cl
      ) ||
      !is.finite(
        cl
      ) ||
      cl <= 0) {
    cl <- 1
  }

  list(
    nrow = as.integer(
      nr
    ),
    ncol = as.integer(
      nc
    ),
    cell_length = as.numeric(
      cl
    )
  )
}

landisR_map_selected_ids <- function(
    active_ids,
    cells = NULL) {

  active_ids <-
    as.integer(
      active_ids
    )

  if (is.null(
        cells
      )) {
    return(
      active_ids
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
      ) ||
      any(
        !cells %in%
          active_ids
      )) {
    landisR_stop(
      "cells contient une cellule absente ou inactive."
    )
  }

  cells
}

landisR_map_compact_values <- function(
    x,
    year = NULL,
    variable = "TotalBiomass",
    species = NULL,
    cells = NULL) {

  if (!is.null(
        species
      )) {

    if (length(
          species
        ) !=
        1L ||
        is.na(
          species
        ) ||
        !nzchar(
          as.character(
            species
          )
        )) {
      landisR_stop(
        "species doit contenir un seul identifiant d'espece."
      )
    }

    variable <-
      as.character(
        species
      )
  }

  snapshot <-
    landis_state(
      x,
      representation = "compact",
      year = year
    )

  active_ids <-
    as.integer(
      snapshot$cell_id
    )

  selected_ids <-
    landisR_map_selected_ids(
      active_ids,
      cells
    )

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

  variable <-
    as.character(
      variable
    )

  if (length(
        variable
      ) !=
      1L ||
      is.na(
        variable
      ) ||
      !nzchar(
        variable
      )) {
    landisR_stop(
      "variable doit etre un seul nom non vide."
    )
  }

  if (identical(
        variable,
        "TotalBiomass"
      )) {

    values <-
      as.numeric(
        snapshot$state_total_biomass[
          state_id
        ]
      )

  } else if (identical(
               variable,
               "AGE_MAX"
             )) {

    values <-
      as.numeric(
        snapshot$state_max_age[
          state_id
        ]
      )

  } else {

    species_names <-
      as.character(
        snapshot$species
      )

    j <-
      match(
        variable,
        species_names
      )

    if (!is.na(
          j
        )) {

      values <-
        as.numeric(
          snapshot$state_biomass[
            state_id,
            j
          ]
        )

    } else if (!is.null(
               snapshot[[variable]]
             ) &&
             is.atomic(
               snapshot[[variable]]
             ) &&
             is.numeric(
               snapshot[[variable]]
             )) {

      candidate <-
        snapshot[[variable]]

      if (length(
            candidate
          ) ==
          length(
            active_ids
          )) {

        values <-
          as.numeric(
            candidate[
              position
            ]
          )

      } else if (length(
                   candidate
                 ) >=
                 max(
                   state_id
                 )) {

        values <-
          as.numeric(
            candidate[
              state_id
            ]
          )

      } else {

        landisR_stop(
          "La variable '",
          variable,
          "' existe dans le snapshot mais ne peut pas etre reliee aux cellules."
        )
      }

    } else {

      landisR_stop(
        "Variable inconnue : ",
        variable,
        ". Utiliser TotalBiomass, AGE_MAX, un nom d'espece, ",
        "ou une variable numerique compatible du snapshot."
      )
    }
  }

  ctx <-
    landisR_map_context(
      x
    )

  metadata <-
    landisR_context_cell_metadata(
      ctx,
      selected_ids
    )

  metadata$value <-
    values

  list(
    data = metadata,
    year = as.integer(
      snapshot$year
    ),
    label = variable,
    ctx = ctx
  )
}

landisR_map_validate_age <- function(
    age) {

  if (is.null(
        age
      )) {
    return(
      NULL
    )
  }

  if (!is.numeric(
        age
      ) ||
      !length(
        age
      ) %in%
        c(
          1L,
          2L
        ) ||
      anyNA(
        age
      ) ||
      any(
        age < 0
      )) {
    landisR_stop(
      "age doit etre une valeur ou un intervalle numerique de longueur 2."
    )
  }

  if (length(
        age
      ) ==
      1L) {
    age <-
      c(
        age,
        age
      )
  }

  if (age[1L] >
      age[2L]) {
    landisR_stop(
      "L'intervalle age doit etre en ordre croissant."
    )
  }

  as.numeric(
    age
  )
}

landisR_map_cohort_values <- function(
    x,
    year = NULL,
    species = NULL,
    age,
    cells = NULL) {

  age <-
    landisR_map_validate_age(
      age
    )

  if (is.null(
        age
      )) {
    landisR_stop(
      "Une plage d'age est requise pour une carte de cohortes."
    )
  }

  if (!is.null(
        species
      )) {

    if (length(
          species
        ) !=
        1L ||
        is.na(
          species
        ) ||
        !nzchar(
          as.character(
            species
          )
        )) {
      landisR_stop(
        "species doit contenir un seul identifiant d'espece."
      )
    }

    species <-
      as.character(
        species
      )
  }

  map_year <-
    year

  if (inherits(
        x,
        "landisR_run"
      )) {

    selected <-
      landisR_run_pick_state_file(
        x,
        type = "checkpoint",
        year = year
      )

    map_year <-
      selected$year
  }

  if (inherits(
        x,
        "landisR_simulation"
      )) {
    map_year <-
      as.integer(
        x$year
      )
  }

  ctx <-
    landisR_map_context(
      x
    )

  selected_ids <-
    landisR_map_selected_ids(
      as.integer(
        ctx$ids
      ),
      cells
    )

  base <-
    landisR_context_cell_metadata(
      ctx,
      selected_ids
    )

  # Zero is biologically meaningful for an active cell with no matching cohort.
  base$value <-
    0

  cohorts <-
    landis_state(
      x,
      representation = "cohorts",
      cells = selected_ids,
      year = map_year
    )

  if (nrow(
        cohorts
      )) {

    keep <-
      cohorts$age >=
        age[1L] &
      cohorts$age <=
        age[2L]

    if (!is.null(
          species
        )) {
      keep <-
        keep &
        cohorts$species ==
          species
    }

    cohorts <-
      cohorts[
        keep,
        ,
        drop = FALSE
      ]

    if (nrow(
          cohorts
        )) {

      summed <-
        stats::aggregate(
          biomass ~ cell_id,
          data = cohorts,
          FUN = sum
        )

      where <-
        match(
          summed$cell_id,
          base$cell_id
        )

      base$value[
        where
      ] <-
        as.numeric(
          summed$biomass
        )
    }
  }

  age_label <-
    if (identical(
          age[1L],
          age[2L]
        )) {
      paste0(
        "age ",
        format(
          age[1L],
          trim = TRUE
        )
      )
    } else {
      paste0(
        "ages ",
        format(
          age[1L],
          trim = TRUE
        ),
        "-",
        if (is.infinite(
              age[2L]
            )) {
          "Inf"
        } else {
          format(
            age[2L],
            trim = TRUE
          )
        }
      )
    }

  label <-
    if (is.null(
          species
        )) {
      paste0(
        "Cohort biomass, ",
        age_label
      )
    } else {
      paste0(
        species,
        " biomass, ",
        age_label
      )
    }

  list(
    data = base,
    year = as.integer(
      map_year
    ),
    label = label,
    ctx = ctx
  )
}

landisR_map_dataframe_values <- function(
    x,
    variable = "TotalBiomass",
    species = NULL,
    age = NULL,
    cells = NULL) {

  if (!is.data.frame(
        x
      )) {
    landisR_stop(
      "x doit etre un objet landisR compatible ou un data.frame."
    )
  }

  if (!all(
        c(
          "row",
          "col"
        ) %in%
          names(
            x
          )
      )) {
    landisR_stop(
      "Le data.frame doit contenir les colonnes row et col."
    )
  }

  if (!is.null(
        cells
      )) {

    if (!"cell_id" %in%
        names(
          x
        )) {
      landisR_stop(
        "cells exige une colonne cell_id lorsque x est un data.frame."
      )
    }

    cells <-
      unique(
        as.integer(
          cells
        )
      )

    x <-
      x[
        x$cell_id %in%
          cells,
        ,
        drop = FALSE
      ]
  }

  age <-
    landisR_map_validate_age(
      age
    )

  cohort_like <-
    all(
      c(
        "cell_id",
        "species",
        "age",
        "biomass"
      ) %in%
        names(
          x
        )
    )

  if (!is.null(
        age
      )) {

    if (!cohort_like) {
      landisR_stop(
        "Une carte filtree par age exige un data.frame de cohortes avec ",
        "cell_id, species, age et biomass."
      )
    }

    base <-
      unique(
        x[
          c(
            "cell_id",
            "row",
            "col"
          )
        ]
      )

    base$value <-
      0

    keep <-
      x$age >=
        age[1L] &
      x$age <=
        age[2L]

    if (!is.null(
          species
        )) {
      keep <-
        keep &
        x$species ==
          as.character(
            species
          )
    }

    y <-
      x[
        keep,
        ,
        drop = FALSE
      ]

    if (nrow(
          y
        )) {

      summed <-
        stats::aggregate(
          biomass ~ cell_id,
          data = y,
          FUN = sum
        )

      pos <-
        match(
          summed$cell_id,
          base$cell_id
        )

      base$value[
        pos
      ] <-
        as.numeric(
          summed$biomass
        )
    }

    label <-
      if (is.null(
            species
          )) {
        "Cohort biomass"
      } else {
        paste0(
          as.character(
            species
          ),
          " cohort biomass"
        )
      }

    return(
      list(
        data = base,
        year = NA_integer_,
        label = label,
        ctx = NULL
      )
    )
  }

  if (!is.null(
        species
      )) {
    variable <-
      as.character(
        species
      )
  }

  variable <-
    as.character(
      variable
    )

  if (length(
        variable
      ) !=
      1L ||
      is.na(
        variable
      ) ||
      !variable %in%
        names(
          x
        )) {
    landisR_stop(
      "Variable absente du data.frame : ",
      variable
    )
  }

  if (!is.numeric(
        x[[variable]]
      ) &&
      !is.logical(
        x[[variable]]
      )) {
    landisR_stop(
      "La variable cartographiee doit etre numerique ou logique."
    )
  }

  out <-
    x[
      c(
        intersect(
          "cell_id",
          names(
            x
          )
        ),
        "row",
        "col"
      )
    ]

  out$value <-
    as.numeric(
      x[[variable]]
    )

  if (anyDuplicated(
        out[
          c(
            "row",
            "col"
          )
        ]
      )) {
    landisR_stop(
      "Plusieurs valeurs sont presentes pour une meme cellule. ",
      "Agreger les donnees ou utiliser species/age pour les cohortes."
    )
  }

  list(
    data = out,
    year = NA_integer_,
    label = variable,
    ctx = NULL
  )
}

landisR_map_project_values <- function(
    project,
    variable = "community",
    cells = NULL) {

  grid <-
    project$canonical$landscape$cells

  if (!is.null(
        cells
      )) {

    cells <-
      unique(
        as.integer(
          cells
        )
      )

    grid <-
      grid[
        grid$cell_id %in%
          cells,
        ,
        drop = FALSE
      ]
  }

  variable <-
    as.character(
      variable
    )

  if (length(
        variable
      ) !=
      1L ||
      is.na(
        variable
      ) ||
      !variable %in%
        names(
          grid
        )) {
    landisR_stop(
      "Variable absente de project$canonical$landscape$cells : ",
      variable
    )
  }

  if (!is.numeric(
        grid[[variable]]
      ) &&
      !is.logical(
        grid[[variable]]
      )) {
    landisR_stop(
      "La variable du paysage doit etre numerique ou logique."
    )
  }

  out <-
    grid[
      c(
        "cell_id",
        "row",
        "col"
      )
    ]

  out$value <-
    as.numeric(
      grid[[variable]]
    )

  list(
    data = out,
    year = NA_integer_,
    label = variable,
    ctx = NULL
  )
}

landisR_map_matrix <- function(
    data,
    nrow,
    ncol,
    fill = NA_real_) {

  if (!is.data.frame(
        data
      ) ||
      !all(
        c(
          "row",
          "col",
          "value"
        ) %in%
          names(
            data
          )
      )) {
    landisR_stop(
      "Donnees cartographiques invalides."
    )
  }

  row <-
    as.integer(
      data$row
    )

  col <-
    as.integer(
      data$col
    )

  if (anyNA(
        row
      ) ||
      anyNA(
        col
      ) ||
      any(
        row < 1L |
          row > nrow |
          col < 1L |
          col > ncol
      )) {
    landisR_stop(
      "row/col depassent les dimensions de la grille."
    )
  }

  if (anyDuplicated(
        data.frame(
          row = row,
          col = col
        )
      )) {
    landisR_stop(
      "Plusieurs valeurs sont presentes pour une meme cellule."
    )
  }

  z <-
    matrix(
      fill,
      nrow = nrow,
      ncol = ncol
    )

  z[
    cbind(
      row,
      col
    )
  ] <-
    as.numeric(
      data$value
    )

  z
}

landisR_map_spatraster <- function(
    matrix,
    cell_length,
    name) {

  if (!requireNamespace(
        "terra",
        quietly = TRUE
      )) {
    landisR_stop(
      "Le package optionnel 'terra' est requis pour output='SpatRaster'."
    )
  }

  nr <-
    nrow(
      matrix
    )

  nc <-
    ncol(
      matrix
    )

  r <-
    terra::rast(
      nrows = nr,
      ncols = nc,
      xmin = 0,
      xmax = nc *
        cell_length,
      ymin = 0,
      ymax = nr *
        cell_length
    )

  # terra stores cells row-major from the top-left; canonical landisR row 1
  # is also the first LANDIS row, so as.vector(t(matrix)) preserves orientation.
  r <-
    terra::setValues(
      r,
      as.vector(
        t(
          matrix
        )
      )
    )

  names(
    r
  ) <-
    make.names(
      name,
      unique = TRUE
    )

  r
}

landisR_plot_matrix_base <- function(
    matrix,
    main,
    col,
    axes = FALSE,
    ...) {

  finite <-
    matrix[
      is.finite(
        matrix
      )
    ]

  if (!length(
        finite
      )) {
    landisR_stop(
      "La carte ne contient aucune valeur finie a afficher."
    )
  }

  zlim <-
    range(
      finite
    )

  if (identical(
        zlim[1L],
        zlim[2L]
      )) {

    delta <-
      if (zlim[1L] ==
          0) {
        0.5
      } else {
        abs(
          zlim[1L]
        ) *
          0.01
      }

    if (!is.finite(
          delta
        ) ||
        delta ==
          0) {
      delta <- 0.5
    }

    zlim <-
      zlim +
      c(
        -delta,
        delta
      )
  }

  # image() places the first y value at the bottom. Reverse matrix rows so
  # LANDIS row 1 is displayed at the top.
  z <-
    t(
      matrix[
        nrow(
          matrix
        ):1L,
        ,
        drop = FALSE
      ]
    )

  graphics::image(
    x = seq_len(
      ncol(
        matrix
      )
    ),
    y = seq_len(
      nrow(
        matrix
      )
    ),
    z = z,
    col = col,
    zlim = zlim,
    axes = axes,
    xlab = "column",
    ylab = "row",
    main = main,
    useRaster = TRUE,
    ...
  )

  graphics::box()
}

#' Display or return a spatial map from landisR
#'
#' `landis_map()` maps cell-level state without requiring users to manually
#' reshape `landis_state()` outputs. For a `landisR_run`, biomass maps are read
#' from saved snapshots. Age-filtered cohort maps use checkpoints.
#'
#' @param x A landisR_run, landisR_simulation, landisR_project, or spatial
#'   data.frame containing row and col.
#' @param year Saved year to map. NULL uses the latest compatible saved state
#'   for a landisR_run and the current year for a landisR_simulation.
#' @param variable Numeric output to map. Common values are "TotalBiomass",
#'   "AGE_MAX", or a species identifier such as "PICE.MAR".
#' @param species Optional species identifier. Without age this is a shortcut
#'   for variable = species. With age it filters cohort biomass.
#' @param age Optional exact age or inclusive c(min, max) interval. This route
#'   uses cohort state and therefore a saved checkpoint for landisR_run objects.
#' @param cells Optional active cell IDs to display. Other cells remain NA.
#' @param output Return class: "matrix", "data.frame", or "SpatRaster".
#' @param plot Logical. Display the map immediately.
#' @param engine Plotting backend: "auto", "terra", or "base".
#' @param grid_nrow,grid_ncol Optional full grid dimensions for standalone
#'   data.frames.
#' @param cell_length Optional cell side length used for SpatRaster relative
#'   coordinates.
#' @param fill Value assigned to cells not represented in the mapped data.
#' @param main Optional plot title.
#' @param col Optional color vector.
#' @param axes Logical passed to the plotting backend.
#' @param ... Additional arguments passed to terra::plot() or graphics::image().
#'
#' @return Invisibly returns the requested object when plot=TRUE, otherwise
#'   returns it visibly. SpatRaster output currently uses relative grid
#'   coordinates because the canonical beta format does not retain the original
#'   raster CRS/origin.
#' @export
landis_map <- function(
    x,
    year = NULL,
    variable = "TotalBiomass",
    species = NULL,
    age = NULL,
    cells = NULL,
    output = c(
      "matrix",
      "data.frame",
      "SpatRaster"
    ),
    plot = TRUE,
    engine = c(
      "auto",
      "terra",
      "base"
    ),
    grid_nrow = NULL,
    grid_ncol = NULL,
    cell_length = NULL,
    fill = NA_real_,
    main = NULL,
    col = NULL,
    axes = FALSE,
    ...) {

  output <-
    match.arg(
      output
    )

  engine <-
    match.arg(
      engine
    )

  if (!is.logical(
        plot
      ) ||
      length(
        plot
      ) !=
        1L ||
      is.na(
        plot
      )) {
    landisR_stop(
      "plot doit etre TRUE ou FALSE."
    )
  }

  if (!is.numeric(
        fill
      ) ||
      length(
        fill
      ) !=
        1L ||
      (!is.na(
          fill
        ) &&
       !is.finite(
         fill
       ))) {
    landisR_stop(
      "fill doit etre une valeur numerique finie ou NA."
    )
  }

  if (!is.null(
        age
      )) {

    if (!inherits(
          x,
          c(
            "landisR_run",
            "landisR_simulation"
          )
        ) &&
        !is.data.frame(
          x
        )) {
      landisR_stop(
        "Le filtrage par age est disponible pour les simulations/runs ",
        "ou les data.frames de cohortes."
      )
    }

    if (inherits(
          x,
          c(
            "landisR_run",
            "landisR_simulation"
          )
        )) {

      prepared <-
        landisR_map_cohort_values(
          x,
          year = year,
          species = species,
          age = age,
          cells = cells
        )

    } else {

      prepared <-
        landisR_map_dataframe_values(
          x,
          variable = variable,
          species = species,
          age = age,
          cells = cells
        )
    }

  } else if (inherits(
               x,
               c(
                 "landisR_run",
                 "landisR_simulation"
               )
             )) {

    prepared <-
      landisR_map_compact_values(
        x,
        year = year,
        variable = variable,
        species = species,
        cells = cells
      )

  } else if (inherits(
               x,
               "landisR_project"
             )) {

    if (!is.null(
          species
        )) {
      landisR_stop(
        "species n'est pas utilise pour une carte directe de landisR_project."
      )
    }

    prepared <-
      landisR_map_project_values(
        x,
        variable = variable,
        cells = cells
      )

  } else if (is.data.frame(
               x
             )) {

    prepared <-
      landisR_map_dataframe_values(
        x,
        variable = variable,
        species = species,
        age = NULL,
        cells = cells
      )

  } else {

    landisR_stop(
      "x doit etre un landisR_run, landisR_simulation, landisR_project ",
      "ou un data.frame spatial."
    )
  }

  data <-
    prepared$data

  grid <-
    landisR_map_grid_info(
      x,
      data = data,
      ctx = prepared$ctx,
      grid_nrow = grid_nrow,
      grid_ncol = grid_ncol,
      cell_length = cell_length
    )

  matrix <-
    landisR_map_matrix(
      data,
      nrow = grid$nrow,
      ncol = grid$ncol,
      fill = fill
    )

  label <-
    prepared$label

  map_year <-
    prepared$year

  if (is.null(
        main
      )) {

    main <-
      label

    if (length(
          map_year
        ) ==
        1L &&
        !is.na(
          map_year
        )) {
      main <-
        paste0(
          main,
          " | year ",
          map_year
        )
    }
  }

  if (is.null(
        col
      )) {
    col <-
      grDevices::hcl.colors(
        64L,
        "Viridis"
      )
  }

  raster <-
    NULL

  need_raster <-
    identical(
      output,
      "SpatRaster"
    ) ||
    (
      isTRUE(
        plot
      ) &&
      (
        identical(
          engine,
          "terra"
        ) ||
        (
          identical(
            engine,
            "auto"
          ) &&
          requireNamespace(
            "terra",
            quietly = TRUE
          )
        )
      )
    )

  if (need_raster) {

    raster <-
      landisR_map_spatraster(
        matrix,
        cell_length = grid$cell_length,
        name = label
      )
  }

  if (isTRUE(
        plot
      )) {

    plot_engine <-
      engine

    if (identical(
          plot_engine,
          "auto"
        )) {

      plot_engine <-
        if (requireNamespace(
              "terra",
              quietly = TRUE
            )) {
          "terra"
        } else {
          "base"
        }
    }

    if (identical(
          plot_engine,
          "terra"
        )) {

      if (is.null(
            raster
          )) {
        raster <-
          landisR_map_spatraster(
            matrix,
            cell_length = grid$cell_length,
            name = label
          )
      }

      terra::plot(
        raster,
        main = main,
        col = col,
        axes = axes,
        ...
      )

    } else {

      landisR_plot_matrix_base(
        matrix,
        main = main,
        col = col,
        axes = axes,
        ...
      )
    }
  }

  result <-
    switch(
      output,
      matrix = matrix,
      data.frame = data,
      SpatRaster = {
        if (is.null(
              raster
            )) {
          raster <-
            landisR_map_spatraster(
              matrix,
              cell_length = grid$cell_length,
              name = label
            )
        }
        raster
      }
    )

  attr(
    result,
    "landisR_map_label"
  ) <-
    label

  attr(
    result,
    "landisR_map_year"
  ) <-
    map_year

  attr(
    result,
    "landisR_grid_nrow"
  ) <-
    grid$nrow

  attr(
    result,
    "landisR_grid_ncol"
  ) <-
    grid$ncol

  attr(
    result,
    "landisR_cell_length"
  ) <-
    grid$cell_length

  if (isTRUE(
        plot
      )) {
    invisible(
      result
    )
  } else {
    result
  }
}
