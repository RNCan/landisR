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

landisR_establishment_mask <- function(mask, establishment, ids, cell_state,
                                       state_eco, species_names, sep) {
  mask[match(establishment$excluded_cells, ids)] <- 0L
  planting <- establishment$planting
  if (!NROW(planting)) return(mask)

  position <- match(planting$cell_id, ids)
  species <- match(planting$species, species_names)
  eligible <- sep[cbind(state_eco[cell_state[position]], species)] > 0
  if (!any(eligible)) return(mask)

  # A successful planting takes the place of natural seeding for this step.
  # The base engine has already consumed its usual cell-major random draws.
  planted <- rowsum(bitwShiftL(1L, species[eligible] - 1L),
                    position[eligible], reorder = FALSE)
  mask[as.integer(rownames(planted))] <- planted[, 1L]
  mask
}
