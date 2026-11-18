# LANDIS-II inputs shared by any succession or disturbance extension.
landis_read <- function(source_directory, scenario = "scenario.txt",
                        cache_directory = NULL, prefer_cells_csv = TRUE,
                        name = NULL, timestep = 1L) {
  if (!is.null(cache_directory))
    landisR_stop("landis_read() reads the shared landscape. ",
                 "Use landis_from_canonical() to reopen a canonical Biomass Succession directory.")
  source_directory <- normalizePath(source_directory, winslash = "/", mustWork = TRUE)
  if (is.null(name)) name <- basename(source_directory)

  resolve <- function(path, directory) {
    path <- chartr("\\", "/", path)
    if (!grepl("^(/|[A-Za-z]:/)", path)) path <- file.path(directory, path)
    if (!file.exists(path)) landisR_stop("Missing LANDIS-II input: ", path)
    normalizePath(path, winslash = "/", mustWork = TRUE)
  }
  rows <- function(path) {
    lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
    lines <- trimws(sub("<<.*$", "", sub("^\ufeff", "", lines)))
    lapply(lines[nzchar(lines) & !startsWith(lines, ">>")], function(line)
      scan(text = line, what = character(), quote = '"', comment.char = "", quiet = TRUE))
  }
  read_table <- function(path, columns) {
    data <- rows(path)[-1L]
    if (!length(data) || any(lengths(data) != length(columns)))
      landisR_stop("Unexpected table columns in ", path)
    out <- as.data.frame(do.call(rbind, data), stringsAsFactors = FALSE)
    names(out) <- columns
    out[] <- lapply(out, utils::type.convert, as.is = TRUE)
    out
  }

  scenario_file <- resolve(scenario, source_directory)
  scenario_directory <- dirname(scenario_file)
  entries <- rows(scenario_file)
  if (!length(entries) || !identical(entries[[1L]], c("LandisData", "Scenario")))
    landisR_stop("Expected a LANDIS-II Scenario file: ", scenario_file)
  value <- function(key) {
    hits <- Filter(function(entry) length(entry) && identical(entry[[1L]], key), entries)
    if (length(hits) != 1L || length(hits[[1L]]) != 2L)
      landisR_stop("Expected exactly one scenario value for ", key, ".")
    hits[[1L]][2L]
  }
  scenario_path <- function(key) resolve(value(key), scenario_directory)

  species <- read_table(scenario_path("Species"), c(
    "species", "longevity", "maturity", "shade_tolerance", "fire_tolerance",
    "effective_seed_distance", "max_seed_distance", "vegetative_probability",
    "min_sprout_age", "max_sprout_age", "post_fire_regeneration"
  ))
  ecoregions <- read_table(scenario_path("Ecoregions"),
                           c("active", "map_code", "ecoregion", "description"))
  if (anyNA(ecoregions$map_code) || anyDuplicated(ecoregions$map_code))
    landisR_stop("Ecoregion map codes must be unique and nonmissing.")
  ecoregions_map <- scenario_path("EcoregionsMap")
  cells_path <- file.path(scenario_directory, "cells.csv")
  eco_codes <- as.character(ecoregions$map_code)
  eco_names <- as.character(ecoregions$ecoregion)

  if (isTRUE(prefer_cells_csv) && file.exists(cells_path)) {
    columns <- c("cell_id", "row", "col")
    header <- utils::read.csv(cells_path, nrows = 0L)
    needed <- c(columns, "ecoregion")
    landisR_require_columns(header, needed, "cells.csv")
    cells <- utils::read.csv(cells_path, stringsAsFactors = FALSE,
                             colClasses = ifelse(names(header) %in% needed, NA_character_, "NULL"))
    label <- as.character(cells$ecoregion)
    eco_id <- match(label, eco_names)
    missing <- is.na(eco_id)
    eco_id[missing] <- match(label[missing], eco_codes)
    grid <- cells[columns]
  } else {
    cells_path <- NULL
    if (!requireNamespace("terra", quietly = TRUE))
      landisR_stop("Install terra to read the LANDIS-II ecoregion raster.")
    raster <- terra::rast(ecoregions_map)
    if (terra::nlyr(raster) != 1L)
      landisR_stop("The LANDIS-II ecoregion map must have one layer: ", ecoregions_map)
    map <- terra::as.matrix(raster, wide = TRUE)
    # Flatten in LANDIS column-major cell order.
    eco_id <- match(as.character(as.vector(map)), eco_codes)
    grid <- data.frame(cell_id = seq_along(eco_id),
                       row = rep.int(seq_len(nrow(map)), ncol(map)),
                       col = rep(seq_len(ncol(map)), each = nrow(map)))
  }
  if (anyNA(eco_id))
    landisR_stop("The LANDIS-II grid contains an ecoregion absent from the description.")
  grid$ecoregion_map_code <- as.integer(ecoregions$map_code[eco_id])
  grid$ecoregion <- eco_names[eco_id]
  grid$active <- tolower(as.character(ecoregions$active[eco_id])) %in%
    c("yes", "true", "active")

  project <- landis_build_landscape(
    grid, duration = as.numeric(value("Duration")),
    cell_length = as.numeric(value("CellLength")), timestep = timestep,
    species = species, name = name
  )
  project$canonical$ecoregions <- ecoregions
  project$source_type <- "LANDIS-II-landscape"
  project$source <- list(directory = source_directory, scenario = scenario,
                         scenario_file = scenario_file, ecoregions_map = ecoregions_map,
                         cells_csv = cells_path)
  project
}
