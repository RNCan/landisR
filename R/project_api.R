# ==============================================================================
# landisR public project API - beta.2-dev
#
# Core design:
#   LANDIS-II files ---- landis_read() -----------\
#   R tables ---------- landis_build() ------------> landisR_project
#   canonical object -- landis_from_canonical() ---/
#                                                   |
#                                                   v
#                                              landis_run()
#
# LANDIS-II is therefore OPTIONAL. The frozen engine only sees canonical inputs.
# ==============================================================================

landisR_stop <- function(...) {
  stop(
    ...,
    call. = FALSE
  )
}

landisR_root <- function() {
  root <- getOption(
    "landisR.root",
    NULL
  )

  if (is.null(
        root
      )) {
    return(
      normalizePath(
        getwd(),
        winslash = "/",
        mustWork = TRUE
      )
    )
  }

  normalizePath(
    root,
    winslash = "/",
    mustWork = TRUE
  )
}

landisR_scalar_integer <- function(
    x,
    label,
    minimum = 0L) {

  if (!is.numeric(x) ||
      length(x) != 1L ||
      is.na(x) ||
      !is.finite(x) ||
      x != trunc(x) ||
      x < minimum) {
    landisR_stop(
      label,
      " doit etre un entier >= ",
      minimum,
      "."
    )
  }

  as.integer(
    x
  )
}

landisR_scalar_numeric <- function(
    x,
    label,
    minimum = 0) {

  if (!is.numeric(x) ||
      length(x) != 1L ||
      is.na(x) ||
      !is.finite(x) ||
      x < minimum) {
    landisR_stop(
      label,
      " doit etre numerique et >= ",
      minimum,
      "."
    )
  }

  as.numeric(
    x
  )
}

landisR_require_data_frame <- function(
    x,
    label) {

  if (!is.data.frame(
        x
      )) {
    landisR_stop(
      label,
      " doit etre un data.frame."
    )
  }

  x
}

landisR_require_columns <- function(
    x,
    columns,
    label,
    exact = FALSE) {

  x <- landisR_require_data_frame(
    x,
    label
  )

  if (isTRUE(
        exact
      )) {

    if (!identical(
          names(
            x
          ),
          columns
        )) {
      landisR_stop(
        label,
        " doit contenir exactement : ",
        paste(
          columns,
          collapse = ", "
        )
      )
    }

  } else if (!all(
               columns %in%
                 names(
                   x
                 )
             )) {

    landisR_stop(
      label,
      " doit contenir au minimum : ",
      paste(
        columns,
        collapse = ", "
      )
    )
  }

  x
}

landisR_validate_dynamic <- function(
    dynamic,
    species,
    ecoregions) {

  dynamic <- landisR_require_columns(
    dynamic,
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

  if (!nrow(
        dynamic
      )) {
    landisR_stop(
      "dynamic est vide."
    )
  }

  dynamic$year <-
    suppressWarnings(
      as.integer(
        dynamic$year
      )
    )

  dynamic$ecoregion <-
    as.character(
      dynamic$ecoregion
    )

  dynamic$species <-
    as.character(
      dynamic$species
    )

  for (field in c(
         "sep",
         "max_anpp",
         "max_biomass"
       )) {

    dynamic[[field]] <-
      suppressWarnings(
        as.numeric(
          dynamic[[field]]
        )
      )
  }

  if (anyNA(
        dynamic
      ) ||
      any(
        dynamic$year < 0L
      ) ||
      any(
        dynamic$sep < 0 |
          dynamic$sep > 1
      ) ||
      any(
        dynamic$max_anpp < 0
      ) ||
      any(
        dynamic$max_biomass < 0
      ) ||
      anyDuplicated(
        dynamic[
          c(
            "year",
            "ecoregion",
            "species"
          )
        ]
      )) {

    landisR_stop(
      "dynamic contient des valeurs invalides."
    )
  }

  valid_species <-
    as.character(
      species$species
    )

  valid_ecoregions <-
    as.character(
      ecoregions$ecoregion
    )

  if (any(
        !dynamic$species %in%
          valid_species
      ) ||
      any(
        !dynamic$ecoregion %in%
          valid_ecoregions
      )) {

    landisR_stop(
      "dynamic contient une espece ou une ecoregion inconnue."
    )
  }

  dynamic
}

landisR_validate_canonical <- function(
    canonical) {

  if (!is.list(
        canonical
      )) {
    landisR_stop(
      "Les entrees canoniques doivent etre une liste."
    )
  }

  required <- c(
    "duration",
    "cell_length",
    "timestep",
    "spinup_cohorts",
    "seeding",
    "spinup_mortality",
    "species",
    "species_parameters",
    "ecoregions",
    "ecoregion_parameters",
    "dynamic",
    "initial_cohorts",
    "community_codes",
    "shade",
    "light",
    "fire_reductions",
    "explicit_initial",
    "landscape"
  )

  missing <-
    setdiff(
      required,
      names(
        canonical
      )
    )

  if (length(
        missing
      )) {
    landisR_stop(
      "Entrees canoniques incompletes : ",
      paste(
        missing,
        collapse = ", "
      )
    )
  }

  canonical$duration <-
    landisR_scalar_integer(
      canonical$duration,
      "duration",
      1L
    )

  canonical$timestep <-
    landisR_scalar_integer(
      canonical$timestep,
      "timestep",
      1L
    )

  canonical$cell_length <-
    landisR_scalar_numeric(
      canonical$cell_length,
      "cell_length",
      0
    )

  canonical$spinup_mortality <-
    landisR_scalar_numeric(
      canonical$spinup_mortality,
      "spinup_mortality",
      0
    )

  if (canonical$spinup_mortality > 1) {
    landisR_stop(
      "spinup_mortality doit etre <= 1."
    )
  }

  if (!is.logical(
        canonical$spinup_cohorts
      ) ||
      length(
        canonical$spinup_cohorts
      ) != 1L ||
      is.na(
        canonical$spinup_cohorts
      )) {

    landisR_stop(
      "spinup_cohorts doit etre TRUE ou FALSE."
    )
  }

  canonical$species <-
    landisR_require_columns(
      canonical$species,
      "species",
      "species"
    )

  canonical$species$species <-
    as.character(
      canonical$species$species
    )

  if (!nrow(
        canonical$species
      ) ||
      anyNA(
        canonical$species$species
      ) ||
      any(
        !nzchar(
          canonical$species$species
        )
      ) ||
      anyDuplicated(
        canonical$species$species
      )) {

    landisR_stop(
      "Table species invalide."
    )
  }

  canonical$species <-
    landisR_normalize_serotiny_traits(
      canonical$species
    )

  canonical$ecoregions <-
    landisR_require_columns(
      canonical$ecoregions,
      c(
        "map_code",
        "ecoregion",
        "active"
      ),
      "ecoregions"
    )

  if (anyDuplicated(
        canonical$ecoregions$map_code
      ) ||
      anyDuplicated(
        as.character(
          canonical$ecoregions$ecoregion
        )
      )) {

    landisR_stop(
      "Table ecoregions dupliquee."
    )
  }

  canonical$dynamic <-
    landisR_validate_dynamic(
      canonical$dynamic,
      canonical$species,
      canonical$ecoregions
    )

  canonical$initial_cohorts <-
    landisR_require_columns(
      canonical$initial_cohorts,
      c(
        "map_code",
        "species",
        "age"
      ),
      "initial_cohorts"
    )

  if (any(
        !canonical$initial_cohorts$species %in%
          canonical$species$species
      ) ||
      any(
        canonical$initial_cohorts$age < 1L
      ) ||
      anyDuplicated(
        canonical$initial_cohorts[
          c(
            "map_code",
            "species",
            "age"
          )
        ]
      )) {

    landisR_stop(
      "Cohortes initiales invalides."
    )
  }

  canonical$community_codes <-
    as.integer(
      canonical$community_codes
    )

  if (!length(
        canonical$community_codes
      ) ||
      anyNA(
        canonical$community_codes
      ) ||
      anyDuplicated(
        canonical$community_codes
      )) {

    landisR_stop(
      "community_codes invalide."
    )
  }

  landscape <-
    canonical$landscape

  if (!is.list(
        landscape
      ) ||
      is.null(
        landscape$cells
      )) {

    landisR_stop(
      "landscape invalide."
    )
  }

  grid <-
    landisR_require_columns(
      landscape$cells,
      c(
        "cell_id",
        "row",
        "col",
        "ecoregion_map_code",
        "ecoregion",
        "active",
        "community"
      ),
      "landscape$cells",
      exact = TRUE
    )

  nr <-
    max(
      grid$row
    )

  nc <-
    max(
      grid$col
    )

  active <-
    as.logical(
      grid$active
    )

  if (anyNA(
        active
      ) ||
      nrow(
        grid
      ) !=
        nr *
        nc ||
      !identical(
        as.integer(
          grid$cell_id
        ),
        seq_len(
          nr *
            nc
        )
      ) ||
      any(
        grid$cell_id !=
          grid$row +
          (
            grid$col -
              1L
          ) *
          nr
      ) ||
      !any(
        active
      )) {

    landisR_stop(
      "Grille invalide. cell_id doit suivre row + (col - 1) * nrow."
    )
  }

  eco_index <-
    match(
      as.character(
        grid$ecoregion_map_code
      ),
      as.character(
        canonical$ecoregions$map_code
      )
    )

  if (anyNA(
        eco_index
      )) {
    landisR_stop(
      "La grille contient un ecoregion_map_code inconnu."
    )
  }

  expected_label <-
    as.character(
      canonical$ecoregions$ecoregion[
        eco_index
      ]
    )

  expected_active <-
    tolower(
      as.character(
        canonical$ecoregions$active[
          eco_index
        ]
      )
    ) %in%
      c(
        "yes",
        "true",
        "active"
      )

  if (any(
        as.character(
          grid$ecoregion
        ) !=
          expected_label
      ) ||
      any(
        active !=
          expected_active
      ) ||
      any(
        active &
          !grid$community %in%
            canonical$community_codes
      ) ||
      any(
        !active &
          grid$community !=
            0L
      )) {

    landisR_stop(
      "La grille est incompatible avec les ecoregions ou les communautes."
    )
  }

  if (!is.null(
        canonical$explicit_initial
      )) {

    explicit <-
      canonical$explicit_initial

    if (!is.list(
          explicit
        ) ||
        is.null(
          explicit$community_codes
        ) ||
        is.null(
          explicit$cohorts
        )) {

      landisR_stop(
        "explicit_initial invalide."
      )
    }

    explicit$cohorts <-
      landisR_require_columns(
        explicit$cohorts,
        c(
          "map_code",
          "species",
          "age",
          "biomass"
        ),
        "explicit_initial$cohorts",
        exact = TRUE
      )

    if (anyNA(
          explicit$cohorts$biomass
        ) ||
        any(
          !is.finite(
            explicit$cohorts$biomass
          )
        ) ||
        any(
          explicit$cohorts$biomass <
            0
        )) {

      landisR_stop(
        "Biomasse initiale explicite invalide."
      )
    }
  }

  canonical$landscape <-
    list(
      cells = grid,
      active = active,
      ids =
        as.integer(
          grid$cell_id[
            active
          ]
        ),
      nrow =
        as.integer(
          nr
        ),
      ncol =
        as.integer(
          nc
        ),
      order =
        "cell_id = row + (col - 1) * nrow; LANDIS rows"
    )

  canonical
}

landisR_project <- function(
    canonical,
    source_type,
    source = NULL,
    canonical_directory = NULL,
    name = "project") {

  canonical <-
    landisR_validate_canonical(
      canonical
    )

  out <-
    list(
      format =
        "landisR/project-v1",
      name =
        as.character(
          name
        ),
      source_type =
        as.character(
          source_type
        ),
      source =
        source,
      canonical =
        canonical,
      canonical_directory =
        canonical_directory
    )

  class(
    out
  ) <-
    "landisR_project"

  out
}

print.landisR_project <- function(
    x,
    ...) {

  cat(
    "<landisR_project>\n",
    sep = ""
  )

  cat(
    "  name        : ",
    x$name,
    "\n",
    sep = ""
  )

  cat(
    "  source      : ",
    x$source_type,
    "\n",
    sep = ""
  )

  cat(
    "  grid        : ",
    x$canonical$landscape$nrow,
    " x ",
    x$canonical$landscape$ncol,
    "\n",
    sep = ""
  )

  cat(
    "  active cells: ",
    format(
      length(
        x$canonical$landscape$ids
      ),
      big.mark = " "
    ),
    "\n",
    sep = ""
  )

  cat(
    "  species     : ",
    nrow(
      x$canonical$species
    ),
    "\n",
    sep = ""
  )

  cat(
    "  timestep    : ",
    x$canonical$timestep,
    " years\n",
    sep = ""
  )

  cat(
    "  max duration: ",
    x$canonical$duration,
    " years\n",
    sep = ""
  )

  invisible(
    x
  )
}

landis_from_canonical <- function(
    x,
    name = "canonical_project") {

  if (is.character(
        x
      ) &&
      length(
        x
      ) == 1L) {

    if (!exists(
          "bs52_read_canonical52",
          mode = "function"
        )) {
      landisR_stop(
        "bs52_read_canonical52() n'est pas charge. ",
        "Charger R/canonical52.R."
      )
    }

    root <-
      normalizePath(
        x,
        winslash = "/",
        mustWork = TRUE
      )

    canonical <-
      bs52_read_canonical52(
        root
      )

    return(
      landisR_project(
        canonical = canonical,
        source_type = "canonical_directory",
        source = root,
        canonical_directory = root,
        name = name
      )
    )
  }

  landisR_project(
    canonical = x,
    source_type = "canonical_object",
    source = NULL,
    canonical_directory = NULL,
    name = name
  )
}

landis_build <- function(
    landscape,
    species,
    species_parameters,
    ecoregions,
    ecoregion_parameters,
    dynamic,
    initial_cohorts,
    shade,
    light,
    fire_reductions,
    duration,
    cell_length,
    timestep = 10L,
    seeding_algorithm = "Ward",
    spinup_cohorts = FALSE,
    spinup_mortality_fraction = 0.05,
    initial_mode = c(
      "explicit_biomass",
      "age_spinup"
    ),
    community_codes = NULL,
    name = "custom_project") {

  initial_mode <-
    match.arg(
      initial_mode
    )

  grid <-
    landisR_require_columns(
      landscape,
      c(
        "cell_id",
        "row",
        "col",
        "ecoregion_map_code",
        "ecoregion",
        "active",
        "community"
      ),
      "landscape",
      exact = TRUE
    )

  initial_cohorts <-
    landisR_require_columns(
      initial_cohorts,
      c(
        "map_code",
        "species",
        "age"
      ),
      "initial_cohorts"
    )

  if (is.null(
        community_codes
      )) {

    community_codes <-
      sort(
        unique(
          c(
            as.integer(
              grid$community[
                as.logical(
                  grid$active
                )
              ]
            ),
            as.integer(
              initial_cohorts$map_code
            )
          )
        )
      )

    community_codes <-
      community_codes[
        community_codes !=
          0L
      ]
  }

  if (identical(
        initial_mode,
        "explicit_biomass"
      )) {

    if (!"biomass" %in%
        names(
          initial_cohorts
        )) {
      landisR_stop(
        "initial_mode='explicit_biomass' requiert la colonne biomass."
      )
    }

    explicit_cohorts <-
      initial_cohorts[
        c(
          "map_code",
          "species",
          "age",
          "biomass"
        )
      ]

    explicit_initial <-
      list(
        community_codes =
          as.integer(
            community_codes
          ),
        cohorts =
          explicit_cohorts
      )

  } else {

    explicit_initial <-
      NULL
  }

  canonical <-
    list(
      root = NULL,
      duration =
        as.integer(
          duration
        ),
      cell_length =
        as.numeric(
          cell_length
        ),
      timestep =
        as.integer(
          timestep
        ),
      spinup_cohorts =
        isTRUE(
          spinup_cohorts
        ),
      seeding =
        as.character(
          seeding_algorithm
        ),
      spinup_mortality =
        as.numeric(
          spinup_mortality_fraction
        ),
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
      initial_cohorts =
        initial_cohorts[
          c(
            "map_code",
            "species",
            "age"
          )
        ],
      community_codes =
        as.integer(
          community_codes
        ),
      shade =
        shade,
      light =
        light,
      fire_reductions =
        fire_reductions,
      explicit_initial =
        explicit_initial,
      landscape =
        list(
          cells = grid,
          active =
            as.logical(
              grid$active
            ),
          ids =
            as.integer(
              grid$cell_id[
                as.logical(
                  grid$active
                )
              ]
            ),
          nrow =
            as.integer(
              max(
                grid$row
              )
            ),
          ncol =
            as.integer(
              max(
                grid$col
              )
            ),
          order =
            "cell_id = row + (col - 1) * nrow; LANDIS rows"
        )
    )

  landisR_project(
    canonical = canonical,
    source_type = "R_tables",
    source = NULL,
    canonical_directory = NULL,
    name = name
  )
}

landis_write_canonical <- function(
    project,
    directory,
    overwrite = FALSE) {

  if (!inherits(
        project,
        "landisR_project"
      )) {
    landisR_stop(
      "project doit etre un landisR_project."
    )
  }

  canonical <-
    landisR_validate_canonical(
      project$canonical
    )

  root <-
    normalizePath(
      directory,
      winslash = "/",
      mustWork = FALSE
    )

  if (dir.exists(
        root
      ) &&
      length(
        list.files(
          root,
          all.files = TRUE,
          no.. = TRUE
        )
      )) {

    if (!isTRUE(
          overwrite
        )) {
      landisR_stop(
        "Le dossier canonique existe et n'est pas vide : ",
        root
      )
    }

    unlink(
      root,
      recursive = TRUE,
      force = TRUE
    )
  }

  for (subdir in c(
         "ecology",
         "succession",
         "initial",
         "landscape",
         "provenance"
       )) {

    dir.create(
      file.path(
        root,
        subdir
      ),
      recursive = TRUE,
      showWarnings = FALSE
    )
  }

  initial_mode <-
    if (is.null(
          canonical$explicit_initial
        )) {
      "age_spinup"
    } else {
      "explicit_biomass"
    }

  settings <-
    data.frame(
      key = c(
        "format",
        "source_duration",
        "cell_length",
        "timestep",
        "seeding_algorithm",
        "spinup_cohorts",
        "spinup_mortality_fraction",
        "initial_mode"
      ),
      value = c(
        "landisR52/canonical-inputs-v1",
        canonical$duration,
        canonical$cell_length,
        canonical$timestep,
        canonical$seeding,
        tolower(
          as.character(
            canonical$spinup_cohorts
          )
        ),
        canonical$spinup_mortality,
        initial_mode
      ),
      stringsAsFactors = FALSE
    )

  write_csv <- function(
      x,
      ...) {

    utils::write.csv(
      x,
      file.path(
        root,
        ...
      ),
      row.names = FALSE,
      na = "",
      fileEncoding = "UTF-8"
    )
  }

  write_csv(
    settings,
    "model_settings.csv"
  )

  write_csv(
    canonical$species,
    "ecology",
    "species.csv"
  )

  write_csv(
    canonical$ecoregions,
    "ecology",
    "ecoregions.csv"
  )

  write_csv(
    canonical$species_parameters,
    "succession",
    "species_parameters.csv"
  )

  write_csv(
    canonical$ecoregion_parameters,
    "succession",
    "ecoregion_parameters.csv"
  )

  write_csv(
    canonical$dynamic,
    "succession",
    "dynamic.csv"
  )

  write_csv(
    canonical$shade,
    "succession",
    "shade.csv"
  )

  write_csv(
    canonical$light,
    "succession",
    "sufficient_light.csv"
  )

  write_csv(
    canonical$fire_reductions,
    "succession",
    "fire_reductions.csv"
  )

  write_csv(
    data.frame(
      map_code =
        as.integer(
          canonical$community_codes
        )
    ),
    "initial",
    "community_codes.csv"
  )

  cohorts_to_write <-
    if (is.null(
          canonical$explicit_initial
        )) {
      canonical$initial_cohorts
    } else {
      canonical$explicit_initial$cohorts
    }

  write_csv(
    cohorts_to_write,
    "initial",
    "cohorts.csv"
  )

  write_csv(
    canonical$landscape$cells,
    "landscape",
    "grid.csv"
  )

  saveRDS(
    list(
      format =
        "landisR/project-provenance-v1",
      project_name =
        project$name,
      source_type =
        project$source_type,
      source =
        project$source,
      created_at =
        Sys.time()
    ),
    file.path(
      root,
      "provenance",
      "project_manifest.rds"
    ),
    compress = "gzip"
  )

  root
}

landisR_try_source <- function(
    files) {

  root <-
    landisR_root()

  for (path in files) {

    candidate <-
      if (grepl(
            "^(?:[A-Za-z]:)?[/\\]",
            path
          )) {
        path
      } else {
        file.path(
          root,
          path
        )
      }

    if (file.exists(
          candidate
        )) {
      sys.source(
        candidate,
        envir = .GlobalEnv
      )
    }
  }

  invisible(
    NULL
  )
}

landis_read <- function(
    source_directory,
    scenario = "scenario.txt",
    cache_directory = NULL,
    prefer_cells_csv = TRUE,
    name = NULL) {

  source_directory <-
    normalizePath(
      source_directory,
      winslash = "/",
      mustWork = TRUE
    )

  if (is.null(
        name
      )) {
    name <-
      basename(
        source_directory
      )
  }

  if (is.null(
        cache_directory
      )) {

    safe_name <-
      gsub(
        "[^A-Za-z0-9._-]+",
        "_",
        name
      )

    cache_directory <-
      file.path(
        getwd(),
        "cache",
        paste0(
          "landis_import_",
          safe_name
        )
      )
  }

  cache_directory <-
    normalizePath(
      cache_directory,
      winslash = "/",
      mustWork = FALSE
    )

  if (!exists(
        "bs52_import_landis_to_r",
        mode = "function"
      )) {

    landisR_try_source(
      c(
        "R/read_landis52.R",
        "R/explicit_initial52.R",
        "R/import_landis52.R",
        "R/canonical52.R"
      )
    )
  }

  if (!exists(
        "bs52_import_landis_to_r",
        mode = "function"
      ) ||
      !exists(
        "bs52_read_canonical52",
        mode = "function"
      )) {

    landisR_stop(
      "L'adaptateur LANDIS-II n'est pas disponible. ",
      "Dans le package final, il sera inclus automatiquement. ",
      "Dans le projet de developpement actuel, charger read_landis52.R, ",
      "explicit_initial52.R, import_landis52.R et canonical52.R."
    )
  }

  manifest <-
    file.path(
      cache_directory,
      "provenance",
      "import_manifest.rds"
    )

  if (!file.exists(
        manifest
      )) {

    if (dir.exists(
          cache_directory
        ) &&
        length(
          list.files(
            cache_directory,
            all.files = TRUE,
            no.. = TRUE
          )
        )) {

      incomplete <-
        paste0(
          cache_directory,
          "_incomplete_",
          format(
            Sys.time(),
            "%Y%m%d_%H%M%S"
          )
        )

      if (!file.rename(
            cache_directory,
            incomplete
          )) {
        landisR_stop(
          "Impossible de preserver l'import LANDIS incomplet : ",
          cache_directory
        )
      }
    }

    bs52_import_landis_to_r(
      source_directory =
        source_directory,
      destination =
        cache_directory,
      scenario =
        scenario,
      prefer_cells_csv =
        prefer_cells_csv
    )
  }

  canonical <-
    bs52_read_canonical52(
      cache_directory
    )

  landisR_project(
    canonical = canonical,
    source_type = "LANDIS-II",
    source =
      list(
        directory =
          source_directory,
        scenario =
          scenario
      ),
    canonical_directory =
      cache_directory,
    name =
      name
  )
}

landisR_load_engine <- function() {
  if (exists(
        "bs52_run_large_production52",
        mode = "function"
      )) {
    return(
      invisible(
        TRUE
      )
    )
  }

  landisR_try_source(
    file.path(
      "R",
      paste0(
        c(
          "biomass52",
          "explicit_initial52",
          "spinup52",
          "fast52",
          "rcpp52",
          "simulation52",
          "ward52",
          "canonical52",
          "climate52",
          "production52",
          "large52"
        ),
        ".R"
      )
    )
  )

  if (!exists(
        "bs52_run_large_production52",
        mode = "function"
      )) {
    landisR_stop(
      "Le moteur large52 fige n'est pas charge."
    )
  }

  invisible(
    TRUE
  )
}

landis_run <- function(
    project,
    duration = NULL,
    seed = 4357L,
    output_directory,
    output_years = NULL,
    climate = list(
      name = "baseline",
      dynamic_file = NULL
    ),
    dispersal = "ward",
    ward_variant = "ward2019",
    checkpoint_every = 20L,
    snapshot_compression = "gzip1",
    checkpoint_compression = "gzip1",
    cache_directory = NULL,
    rng_chunk_cells = 100000L) {

  if (!inherits(
        project,
        "landisR_project"
      )) {
    landisR_stop(
      "project doit etre un landisR_project."
    )
  }

  landisR_load_engine()

  canonical <-
    landisR_validate_canonical(
      project$canonical
    )

  if (is.null(
        duration
      )) {
    duration <-
      canonical$duration
  }

  duration <-
    landisR_scalar_integer(
      duration,
      "duration",
      1L
    )

  if (duration >
      canonical$duration) {
    landisR_stop(
      "duration depasse la duree disponible dans les entrees."
    )
  }

  seed <-
    landisR_scalar_integer(
      seed,
      "seed",
      0L
    )

  output_directory <-
    normalizePath(
      output_directory,
      winslash = "/",
      mustWork = FALSE
    )

  if (is.null(
        output_years
      )) {

    output_years <-
      seq.int(
        0L,
        duration,
        by =
          canonical$timestep
      )
  }

  output_years <-
    as.integer(
      output_years
    )

  if (!length(
        output_years
      ) ||
      !0L %in%
        output_years ||
      anyNA(
        output_years
      ) ||
      any(
        output_years <
          0L |
          output_years >
            duration
      ) ||
      any(
        output_years %%
          canonical$timestep !=
          0L
      ) ||
      anyDuplicated(
        output_years
      ) ||
      is.unsorted(
        output_years
      )) {

    landisR_stop(
      "output_years invalide."
    )
  }

  if (is.null(
        cache_directory
      )) {

    cache_directory <-
      file.path(
        dirname(
          output_directory
        ),
        paste0(
          ".landisR_cache_",
          gsub(
            "[^A-Za-z0-9._-]+",
            "_",
            project$name
          )
        )
      )
  }

  cache_directory <-
    normalizePath(
      cache_directory,
      winslash = "/",
      mustWork = FALSE
    )

  dir.create(
    cache_directory,
    recursive = TRUE,
    showWarnings = FALSE
  )

  canonical_directory <-
    project$canonical_directory

  if (is.null(
        canonical_directory
      )) {

    canonical_directory <-
      file.path(
        cache_directory,
        "canonical_inputs"
      )

    manifest <-
      file.path(
        canonical_directory,
        "provenance",
        "project_manifest.rds"
      )

    if (!file.exists(
          manifest
        )) {

      landis_write_canonical(
        project,
        canonical_directory,
        overwrite = FALSE
      )
    }
  }

  scenario <-
    list(
      name =
        project$name,
      inputs =
        canonical_directory,
      duration =
        duration,
      timestep =
        canonical$timestep,
      seed =
        seed,
      engine =
        "Rcpp",
      dispersal =
        dispersal,
      ward_variant =
        ward_variant,
      climate =
        climate,
      track_dead_pools =
        FALSE,
      save_recruitment =
        FALSE,
      output_years =
        output_years,
      output_directory =
        output_directory,
      checkpoint_every =
        as.integer(
          checkpoint_every
        ),
      snapshot_compression =
        snapshot_compression,
      checkpoint_compression =
        checkpoint_compression,
      rng_chunk_cells =
        as.integer(
          rng_chunk_cells
        ),
      canonical_cache_file =
        file.path(
          cache_directory,
          "canonical.rds"
        ),
      context_cache_file =
        file.path(
          cache_directory,
          "context.rds"
        )
    )

  old_working_directory <-
    getwd()

  on.exit(
    setwd(
      old_working_directory
    ),
    add = TRUE
  )

  setwd(
    landisR_root()
  )

  dir.create(
    output_directory,
    recursive = TRUE,
    showWarnings = FALSE
  )

  run_started_at <- Sys.time()

  running_descriptor <-
    landisR_new_run_descriptor(
      project = project$name,
      output_directory = output_directory,
      duration = duration,
      seed = seed,
      cache_directory = cache_directory,
      canonical_directory = canonical_directory,
      status = "running",
      result = NULL,
      started_at = run_started_at
    )

  landis_save_run(
    running_descriptor,
    output_directory = output_directory
  )

  result <-
    tryCatch(
      bs52_run_large_production52(
        scenario
      ),
      error = function(e) {
        failed_descriptor <- running_descriptor
        failed_descriptor$status <- "failed"
        failed_descriptor$finished_at <- Sys.time()
        failed_descriptor$error <- conditionMessage(e)
        landis_save_run(
          failed_descriptor,
          output_directory = output_directory
        )
        stop(e)
      }
    )

  out <-
    list(
      format =
        "landisR/run-v1",
      project =
        project$name,
      output_directory =
        output_directory,
      duration =
        duration,
      seed =
        seed,
      result =
        result
    )

  class(
    out
  ) <-
    "landisR_run"

  out$status <- "complete"
  out$started_at <- run_started_at
  out$finished_at <- Sys.time()
  out$cache_directory <- cache_directory
  out$canonical_directory <- canonical_directory

  landis_save_run(
    out,
    output_directory = output_directory
  )

  out
}

print.landisR_run <- function(
    x,
    ...) {

  cat(
    "<landisR_run>\n",
    sep = ""
  )

  cat(
    "  project : ",
    x$project,
    "\n",
    sep = ""
  )

  cat(
    "  duration: ",
    x$duration,
    " years\n",
    sep = ""
  )

  cat(
    "  seed    : ",
    x$seed,
    "\n",
    sep = ""
  )

  cat(
    "  output  : ",
    x$output_directory,
    "\n",
    sep = ""
  )

  invisible(
    x
  )
}


# ==============================================================================
# Beta.2 technical compatibility hotfix
#
# v3.12 changed bs52_large_atomic_save52() from logical compression
# (TRUE/FALSE) to named modes ("gzip1", "gzip", "none").
# The canonical-cache helper still used the old `compress = FALSE` call.
#
# This override changes ONLY that storage argument to `compress = "none"`.
# The frozen growth/Ward/scientific engine is not modified.
# ==============================================================================

bs52_large_read_canonical_cached52 <- function(
    inputs,
    cache_file = NULL) {

  inputs <-
    normalizePath(
      inputs,
      winslash = "/",
      mustWork = TRUE
    )

  if (is.null(
        cache_file
      )) {
    return(
      bs52_read_canonical52(
        inputs
      )
    )
  }

  cache_file <-
    normalizePath(
      cache_file,
      winslash = "/",
      mustWork = FALSE
    )

  signature <-
    bs52_large_input_signature52(
      inputs
    )

  if (file.exists(
        cache_file
      )) {

    cache <-
      readRDS(
        cache_file
      )

    if (is.list(
          cache
        ) &&
        identical(
          cache$format,
          "landisR52/canonical-cache-v1"
        ) &&
        identical(
          cache$source,
          inputs
        ) &&
        identical(
          cache$signature,
          signature
        ) &&
        is.list(
          cache$canonical
        )) {

      message(
        "Cache canonique reutilise : ",
        cache_file
      )

      return(
        cache$canonical
      )
    }

    message(
      "Cache canonique obsolete; reconstruction."
    )
  }

  message(
    "Lecture CSV canonique et creation du cache binaire..."
  )

  canonical <-
    bs52_read_canonical52(
      inputs
    )

  bs52_large_atomic_save52(
    list(
      format =
        "landisR52/canonical-cache-v1",
      source =
        inputs,
      signature =
        signature,
      canonical =
        canonical
    ),
    cache_file,
    compress = "none",
    overwrite = TRUE
  )

  message(
    "Cache canonique cree : ",
    cache_file
  )

  canonical
}


# ==============================================================================
# LANDIS-II output comparison
#
# Compare compact landisR snapshots against LANDIS-II Biomass Succession TIFFs.
# LANDIS TIFFs may be ungeoreferenced and vertically mirrored. Orientation is
# established from year 0 across ALL species + TotalBiomass and must reproduce
# the initial state exactly.
# ==============================================================================

landisR_resolve_landis_output52 <- function(
    path) {

  root <-
    normalizePath(
      path,
      winslash = "/",
      mustWork = TRUE
    )

  candidates <-
    list(
      list(
        root = root,
        biomass =
          file.path(
            root,
            "output",
            "biomass"
          ),
        age =
          file.path(
            root,
            "output",
            "cohort-stats"
          )
      ),
      list(
        root = dirname(
          root
        ),
        biomass =
          file.path(
            root,
            "biomass"
          ),
        age =
          file.path(
            root,
            "cohort-stats"
          )
      ),
      list(
        root = dirname(
          dirname(
            root
          )
        ),
        biomass = root,
        age =
          file.path(
            dirname(
              root
            ),
            "cohort-stats"
          )
      )
    )

  for (candidate in candidates) {
    if (dir.exists(
          candidate$biomass
        )) {
      return(
        candidate
      )
    }
  }

  landisR_stop(
    "Impossible de trouver le repertoire LANDIS output/biomass sous : ",
    root
  )
}

landisR_snapshot_files52 <- function(
    output_directory) {

  output_directory <-
    normalizePath(
      output_directory,
      winslash = "/",
      mustWork = TRUE
    )

  snapshot_directory <-
    file.path(
      output_directory,
      "snapshots"
    )

  if (!dir.exists(
        snapshot_directory
      )) {
    snapshot_directory <-
      output_directory
  }

  files <-
    list.files(
      snapshot_directory,
      pattern =
        "^snapshot_[0-9]+\\.rds$",
      full.names = TRUE,
      recursive = FALSE
    )

  if (!length(
        files
      )) {
    landisR_stop(
      "Aucun snapshot compact landisR dans : ",
      output_directory
    )
  }

  years <-
    suppressWarnings(
      as.integer(
        sub(
          "^snapshot_([0-9]+)\\.rds$",
          "\\1",
          basename(
            files
          )
        )
      )
    )

  if (anyNA(
        years
      ) ||
      anyDuplicated(
        years
      )) {
    landisR_stop(
      "Noms de snapshots landisR invalides."
    )
  }

  files[
    order(
      years
    )
  ]
}

landisR_snapshot_values52 <- function(
    snapshot,
    variable) {

  required <- c(
    "cell_id",
    "state_id",
    "species",
    "state_biomass",
    "state_total_biomass",
    "state_max_age"
  )

  missing <-
    setdiff(
      required,
      names(
        snapshot
      )
    )

  if (length(
        missing
      )) {
    landisR_stop(
      "Snapshot compact incomplet : ",
      paste(
        missing,
        collapse = ", "
      )
    )
  }

  state_id <-
    as.integer(
      snapshot$state_id
    )

  if (anyNA(
        state_id
      ) ||
      any(
        state_id <
          1L |
          state_id >
            nrow(
              snapshot$state_biomass
            )
      )) {
    landisR_stop(
      "state_id invalide dans le snapshot."
    )
  }

  if (identical(
        variable,
        "TotalBiomass"
      )) {

    values <-
      snapshot$state_total_biomass[
        state_id
      ]

  } else if (identical(
               variable,
               "AGE-MAX"
             )) {

    values <-
      snapshot$state_max_age[
        state_id
      ]

  } else {

    species <-
      as.character(
        snapshot$species
      )

    j <-
      match(
        variable,
        species
      )

    if (is.na(
          j
        )) {
      landisR_stop(
        "Espece absente du snapshot landisR : ",
        variable
      )
    }

    values <-
      snapshot$state_biomass[
        state_id,
        j
      ]
  }

  data.frame(
    cell_id =
      as.integer(
        snapshot$cell_id
      ),
    value =
      as.numeric(
        values
      ),
    stringsAsFactors = FALSE
  )
}

landisR_read_landis_raster52 <- function(
    file,
    nr,
    nc) {

  if (!requireNamespace(
        "terra",
        quietly = TRUE
      )) {
    landisR_stop(
      "Le package terra est requis pour comparer les sorties LANDIS-II."
    )
  }

  if (!file.exists(
        file
      )) {
    landisR_stop(
      "Raster LANDIS absent : ",
      file
    )
  }

  raster <-
    withCallingHandlers(
      terra::rast(
        file
      ),
      warning = function(w) {
        if (grepl(
              "unknown extent",
              conditionMessage(
                w
              ),
              fixed = TRUE
            )) {
          invokeRestart(
            "muffleWarning"
          )
        }
      }
    )

  if (terra::nlyr(
        raster
      ) !=
      1L ||
      terra::nrow(
        raster
      ) !=
      nr ||
      terra::ncol(
        raster
      ) !=
      nc) {

    landisR_stop(
      "Dimensions LANDIS incompatibles : ",
      file,
      ". Observe ",
      terra::nrow(
        raster
      ),
      " x ",
      terra::ncol(
        raster
      ),
      ", attendu ",
      nr,
      " x ",
      nc,
      "."
    )
  }

  raw <-
    as.numeric(
      terra::values(
        raster,
        mat = FALSE
      )
    )

  # terra returns the file in raster row-major order. Convert explicitly to the
  # column-major cell_id convention used by the validated landisR importer:
  # cell_id = row + (col - 1) * nrow.
  as.vector(
    matrix(
      raw,
      nrow = nr,
      ncol = nc,
      byrow = TRUE
    )
  )
}

landisR_mirror_y52 <- function(
    values,
    nr,
    nc) {

  if (length(
        values
      ) !=
      nr *
        nc) {
    landisR_stop(
      "Vecteur raster incompatible avec nr x nc."
    )
  }

  cell_id <-
    seq_len(
      nr *
        nc
    )

  row <-
    (
      cell_id -
        1L
    ) %%
      nr +
    1L

  col <-
    (
      cell_id -
        1L
    ) %/%
      nr +
    1L

  mirrored_id <-
    (
      nr +
        1L -
        row
    ) +
    (
      col -
        1L
    ) *
      nr

  out <-
    values

  out[
    mirrored_id
  ] <-
    values

  out
}

landisR_numeric_difference52 <- function(
    reference,
    candidate) {

  if (length(
        reference
      ) !=
      length(
        candidate
      )) {
    landisR_stop(
      "Vecteurs de comparaison de longueurs differentes."
    )
  }

  reference <-
    as.numeric(
      reference
    )

  candidate <-
    as.numeric(
      candidate
    )

  missing_mismatch <-
    xor(
      is.na(
        reference
      ),
      is.na(
        candidate
      )
    )

  finite <-
    is.finite(
      reference
    ) &
    is.finite(
      candidate
    )

  nonfinite_same <-
    !finite &
    !missing_mismatch &
    (
      is.na(
        reference
      ) &
      is.na(
        candidate
      )
    )

  diff <-
    rep(
      NA_real_,
      length(
        reference
      )
    )

  diff[
    finite
  ] <-
    candidate[
      finite
    ] -
    reference[
      finite
    ]

  unequal <-
    missing_mismatch

  unequal[
    finite
  ] <-
    diff[
      finite
    ] !=
      0

  unequal[
    nonfinite_same
  ] <-
    FALSE

  list(
    diff =
      diff,
    unequal =
      unequal,
    n_diff =
      sum(
        unequal
      ),
    max_abs_diff =
      if (any(
            finite
          )) {
        max(
          abs(
            diff[
              finite
            ]
          ),
          na.rm = TRUE
        )
      } else {
        NA_real_
      },
    mean_abs_diff =
      if (any(
            finite
          )) {
        mean(
          abs(
            diff[
              finite
            ]
          ),
          na.rm = TRUE
        )
      } else {
        NA_real_
      },
    rmse =
      if (any(
            finite
          )) {
        sqrt(
          mean(
            diff[
              finite
            ]^2,
            na.rm = TRUE
          )
        )
      } else {
        NA_real_
      }
  )
}

landisR_landis_orientation52 <- function(
    snapshot0,
    biomass_directory,
    nr,
    nc,
    active_ids,
    orientation = c(
      "auto",
      "direct",
      "mirror_y"
    )) {

  orientation <-
    match.arg(
      orientation
    )

  species <-
    c(
      as.character(
        snapshot0$species
      ),
      "TotalBiomass"
    )

  score_one <- function(
      use_mirror) {

    mismatches <-
      0L

    max_abs <-
      0

    for (sp in species) {

      file <-
        file.path(
          biomass_directory,
          paste0(
            "biomass_",
            sp,
            "_0.tif"
          )
        )

      landis_values <-
        landisR_read_landis_raster52(
          file,
          nr,
          nc
        )

      if (isTRUE(
            use_mirror
          )) {
        landis_values <-
          landisR_mirror_y52(
            landis_values,
            nr,
            nc
          )
      }

      r_values <-
        landisR_snapshot_values52(
          snapshot0,
          sp
        )

      order_r <-
        match(
          active_ids,
          r_values$cell_id
        )

      if (anyNA(
            order_r
          )) {
        landisR_stop(
          "Le snapshot t=0 ne couvre pas toutes les cellules actives."
        )
      }

      z <-
        landisR_numeric_difference52(
          r_values$value[
            order_r
          ],
          landis_values[
            active_ids
          ]
        )

      mismatches <-
        mismatches +
        z$n_diff

      if (is.finite(
            z$max_abs_diff
          )) {
        max_abs <-
          max(
            max_abs,
            z$max_abs_diff
          )
      }
    }

    c(
      mismatches =
        mismatches,
      max_abs_diff =
        max_abs
    )
  }

  direct <-
    score_one(
      FALSE
    )

  mirror <-
    score_one(
      TRUE
    )

  audit <-
    data.frame(
      orientation =
        c(
          "direct",
          "mirror_y"
        ),
      mismatches =
        c(
          direct[["mismatches"]],
          mirror[["mismatches"]]
        ),
      max_abs_diff =
        c(
          direct[["max_abs_diff"]],
          mirror[["max_abs_diff"]]
        ),
      stringsAsFactors = FALSE
    )

  if (identical(
        orientation,
        "direct"
      )) {
    selected <-
      "direct"
  } else if (identical(
               orientation,
               "mirror_y"
             )) {
    selected <-
      "mirror_y"
  } else {

    direct_exact <-
      direct[["mismatches"]] ==
      0

    mirror_exact <-
      mirror[["mismatches"]] ==
      0

    if (direct_exact &&
        mirror_exact) {
      landisR_stop(
        "Orientation LANDIS ambigue : direct et mirror_y reproduisent tous deux exactement l'annee 0."
      )
    }

    if (!direct_exact &&
        !mirror_exact) {
      landisR_stop(
        "Impossible d'etablir l'orientation LANDIS a l'annee 0. ",
        "Ecarts direct = ",
        direct[["mismatches"]],
        ", mirror_y = ",
        mirror[["mismatches"]],
        "."
      )
    }

    selected <-
      if (direct_exact) {
        "direct"
      } else {
        "mirror_y"
      }
  }

  audit$selected <-
    audit$orientation ==
    selected

  list(
    orientation =
      selected,
    audit =
      audit
  )
}

landis_compare <- function(
    run,
    landis_outputs,
    project,
    years = NULL,
    orientation = c(
      "auto",
      "direct",
      "mirror_y"
    ),
    include_age_max = TRUE,
    output_directory = NULL,
    max_discrepancies = 1000L) {

  orientation <-
    match.arg(
      orientation
    )

  if (!inherits(
        project,
        "landisR_project"
      )) {
    landisR_stop(
      "project doit etre un landisR_project."
    )
  }

  run_directory <-
    if (inherits(
          run,
          "landisR_run"
        )) {
      run$output_directory
    } else if (is.character(
               run
             ) &&
             length(
               run
             ) ==
               1L) {
      run
    } else {
      landisR_stop(
        "run doit etre un landisR_run ou le chemin d'un dossier de sortie landisR."
      )
    }

  run_directory <-
    normalizePath(
      run_directory,
      winslash = "/",
      mustWork = TRUE
    )

  landis <-
    landisR_resolve_landis_output52(
      landis_outputs
    )

  canonical <-
    landisR_validate_canonical(
      project$canonical
    )

  nr <-
    canonical$landscape$nrow

  nc <-
    canonical$landscape$ncol

  active_ids <-
    as.integer(
      canonical$landscape$ids
    )

  snapshot_files <-
    landisR_snapshot_files52(
      run_directory
    )

  snapshot_years <-
    as.integer(
      sub(
        "^snapshot_([0-9]+)\\.rds$",
        "\\1",
        basename(
          snapshot_files
        )
      )
    )

  if (is.null(
        years
      )) {
    years <-
      snapshot_years
  }

  years <-
    as.integer(
      years
    )

  if (!length(
        years
      ) ||
      anyNA(
        years
      ) ||
      any(
        !years %in%
          snapshot_years
      )) {
    landisR_stop(
      "years contient une annee sans snapshot landisR."
    )
  }

  file_by_year <-
    setNames(
      snapshot_files,
      snapshot_years
    )

  snapshot0_file <-
    file_by_year[[as.character(min(snapshot_years))]]

  if (!0L %in%
      snapshot_years) {
    landisR_stop(
      "Un snapshot t=0 est requis pour valider l'orientation LANDIS."
    )
  }

  snapshot0 <-
    readRDS(
      file_by_year[["0"]]
    )

  orient <-
    landisR_landis_orientation52(
      snapshot0 =
        snapshot0,
      biomass_directory =
        landis$biomass,
      nr =
        nr,
      nc =
        nc,
      active_ids =
        active_ids,
      orientation =
        orientation
    )

  selected_orientation <-
    orient$orientation

  if (is.null(
        output_directory
      )) {
    output_directory <-
      file.path(
        run_directory,
        "LANDIS_comparison"
      )
  }

  output_directory <-
    normalizePath(
      output_directory,
      winslash = "/",
      mustWork = FALSE
    )

  dir.create(
    output_directory,
    recursive = TRUE,
    showWarnings = FALSE
  )

  utils::write.csv(
    orient$audit,
    file.path(
      output_directory,
      "orientation_audit.csv"
    ),
    row.names = FALSE,
    na = ""
  )

  results <-
    list()

  discrepancies <-
    list()

  k <-
    0L

  d <-
    0L

  for (year in years) {

    snapshot <-
      readRDS(
        file_by_year[[as.character(year)]]
      )

    variables <-
      c(
        as.character(
          snapshot$species
        ),
        "TotalBiomass"
      )

    if (isTRUE(
          include_age_max
        )) {
      variables <-
        c(
          variables,
          "AGE-MAX"
        )
    }

    for (variable in variables) {

      if (identical(
            variable,
            "AGE-MAX"
          )) {

        file <-
          file.path(
            landis$age,
            paste0(
              "AGE-MAX-",
              year,
              ".tif"
            )
          )

      } else {

        file <-
          file.path(
            landis$biomass,
            paste0(
              "biomass_",
              variable,
              "_",
              year,
              ".tif"
            )
          )
      }

      landis_values <-
        landisR_read_landis_raster52(
          file,
          nr,
          nc
        )

      if (identical(
            selected_orientation,
            "mirror_y"
          )) {
        landis_values <-
          landisR_mirror_y52(
            landis_values,
            nr,
            nc
          )
      }

      r_values <-
        landisR_snapshot_values52(
          snapshot,
          variable
        )

      order_r <-
        match(
          active_ids,
          r_values$cell_id
        )

      if (anyNA(
            order_r
          )) {
        landisR_stop(
          "Snapshot incomplet a l'annee ",
          year,
          "."
        )
      }

      reference <-
        r_values$value[
          order_r
        ]

      candidate <-
        landis_values[
          active_ids
        ]

      z <-
        landisR_numeric_difference52(
          reference,
          candidate
        )

      finite <-
        is.finite(
          reference
        ) &
        is.finite(
          candidate
        )

      correlation <-
        if (sum(
              finite
            ) >
            1L &&
            stats::sd(
              reference[
                finite
              ]
            ) >
            0 &&
            stats::sd(
              candidate[
                finite
              ]
            ) >
            0) {
          stats::cor(
            reference[
              finite
            ],
            candidate[
              finite
            ]
          )
        } else if (z$n_diff ==
                   0L) {
          1
        } else {
          NA_real_
        }

      k <-
        k +
        1L

      results[[k]] <-
        data.frame(
          year =
            year,
          variable =
            variable,
          n_cells =
            length(
              active_ids
            ),
          n_different =
            z$n_diff,
          proportion_different =
            z$n_diff /
            length(
              active_ids
            ),
          max_abs_difference =
            z$max_abs_diff,
          mean_abs_difference =
            z$mean_abs_diff,
          rmse =
            z$rmse,
          correlation =
            correlation,
          exact =
            z$n_diff ==
            0L,
          stringsAsFactors = FALSE
        )

      bad <-
        which(
          z$unequal
        )

      if (length(
            bad
          )) {

        remaining <-
          max_discrepancies -
          sum(
            vapply(
              discrepancies,
              nrow,
              integer(1)
            )
          )

        if (remaining >
            0L) {

          take <-
            head(
              bad[
                order(
                  abs(
                    z$diff[
                      bad
                    ]
                  ),
                  decreasing = TRUE,
                  na.last = TRUE
                )
              ],
              remaining
            )

          d <-
            d +
            1L

          discrepancies[[d]] <-
            data.frame(
              year =
                year,
              variable =
                variable,
              cell_id =
                active_ids[
                  take
                ],
              landisR =
                reference[
                  take
                ],
              LANDIS =
                candidate[
                  take
                ],
              difference =
                z$diff[
                  take
                ],
              stringsAsFactors = FALSE
            )
        }
      }
    }
  }

  summary <-
    do.call(
      rbind,
      results
    )

  utils::write.csv(
    summary,
    file.path(
      output_directory,
      "comparison_summary.csv"
    ),
    row.names = FALSE,
    na = ""
  )

  if (length(
        discrepancies
      )) {

    discrepancy_table <-
      do.call(
        rbind,
        discrepancies
      )

    utils::write.csv(
      discrepancy_table,
      file.path(
        output_directory,
        "largest_discrepancies.csv"
      ),
      row.names = FALSE,
      na = ""
    )
  }

  overall_exact <-
    all(
      summary$exact
    )

  result <-
    list(
      format =
        "landisR/LANDIS-comparison-v1",
      run_directory =
        run_directory,
      landis_root =
        landis$root,
      orientation =
        selected_orientation,
      orientation_audit =
        orient$audit,
      summary =
        summary,
      all_exact =
        overall_exact,
      output_directory =
        output_directory
    )

  class(
    result
  ) <-
    "landisR_comparison"

  message("")
  message(
    "============================================================"
  )
  message(
    "COMPARAISON landisR vs LANDIS-II"
  )
  message(
    "============================================================"
  )

  message(
    "Orientation LANDIS : ",
    selected_orientation
  )

  message(
    "Annees             : ",
    paste(
      years,
      collapse = ", "
    )
  )

  message(
    "Variables          : ",
    nrow(
      summary
    )
  )

  message(
    "Comparaisons exactes: ",
    sum(
      summary$exact
    ),
    " / ",
    nrow(
      summary
    )
  )

  message(
    "Statut global      : ",
    if (overall_exact) {
      "EXACT"
    } else {
      "DIFFERENCES DETECTEES"
    }
  )

  message(
    "Rapport            : ",
    file.path(
      output_directory,
      "comparison_summary.csv"
    )
  )

  invisible(
    result
  )
}

print.landisR_comparison <- function(
    x,
    ...) {

  cat(
    "<landisR_comparison>\n",
    sep = ""
  )

  cat(
    "  orientation : ",
    x$orientation,
    "\n",
    sep = ""
  )

  cat(
    "  exact       : ",
    x$all_exact,
    "\n",
    sep = ""
  )

  cat(
    "  comparisons : ",
    nrow(
      x$summary
    ),
    "\n",
    sep = ""
  )

  cat(
    "  output      : ",
    x$output_directory,
    "\n",
    sep = ""
  )

  invisible(
    x
  )
}
