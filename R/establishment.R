# Sparse cell-level directives for the next interactive succession step.
landis_schedule_establishment <- function(simulation, planting = NULL,
                                          exclude = integer()) {
  simulation <- landisR_validate_simulation(simulation)
  species <- as.character(simulation$ctx$config$species$species)
  ids <- simulation$ctx$ids

  if (!is.numeric(exclude) || anyNA(exclude) || any(!exclude %in% ids))
    landisR_stop("exclude must contain active cell IDs.")
  if (!is.null(planting)) {
    if (!is.data.frame(planting) ||
        !all(c("cell_id", "species") %in% names(planting)) ||
        !is.numeric(planting$cell_id) || anyNA(planting$cell_id) ||
        any(!planting$cell_id %in% ids) ||
        anyNA(planting$species) || any(!planting$species %in% species))
      landisR_stop("planting must contain active cell_id and known species.")
    planting <- unique(data.frame(cell_id = as.integer(planting$cell_id),
                                  species = as.character(planting$species)))
  }
  if (!length(exclude) && !NROW(planting)) return(simulation)

  previous <- simulation$establishment
  excluded <- sort(unique(c(previous$excluded_cells, as.integer(exclude))))
  # A new schedule replaces the previous planting list for that cell.
  pending <- previous$planting
  if (NROW(pending) && NROW(planting))
    pending <- pending[!pending$cell_id %in% planting$cell_id, , drop = FALSE]
  pending <- rbind(pending, planting)
  if (NROW(pending)) {
    pending <- pending[!pending$cell_id %in% excluded, , drop = FALSE]
    rownames(pending) <- NULL
  }
  simulation$establishment <- list(
    excluded_cells = as.integer(excluded),
    planting = if (NROW(pending)) pending else NULL
  )
  simulation
}
