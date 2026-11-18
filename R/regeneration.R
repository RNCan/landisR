landis_deferred_regeneration <- function(simulation) {
  identical(simulation$regeneration_mode, "landis_v7")
}

landis_schedule_regeneration <- function(simulation, mortality, source = c("other", "fire")) {
  if (!landis_deferred_regeneration(simulation) || !NROW(mortality)) return(simulation)
  source <- match.arg(source)
  species <- simulation$ctx$config$species
  if (!is.data.frame(mortality) || !all(c("cell_id", "species", "age") %in% names(mortality)))
    stop("mortality must contain cell_id, species and age.", call. = FALSE)
  index <- match(mortality$species, species$species)
  if (anyNA(index) || anyNA(match(mortality$cell_id, simulation$ctx$ids)) ||
      !is.numeric(mortality$age) || any(!is.finite(mortality$age) | mortality$age < 1))
    stop("Invalid cohort mortality for deferred regeneration.", call. = FALSE)
  landisR_queue_regeneration(simulation, mortality$cell_id, index, mortality$age, source)
}

landisR_queue_regeneration <- function(simulation, cells, index, age, source) {
  traits <- simulation$ctx$config$species
  mode <- traits$post_fire_regeneration[index]
  serotiny <- source == "fire" & mode == "serotiny" & age >= traits$maturity[index]
  resprout <- (source == "other" | mode == "resprout") &
              age >= traits$min_sprout_age[index] & age <= traits$max_sprout_age[index]
  keep <- serotiny | resprout
  if (any(keep)) {
    queue <- data.frame(cell_id = as.integer(cells[keep]), species = as.integer(index[keep]),
                       serotiny = serotiny[keep])
    simulation$pending_regeneration <- unique(rbind(simulation$pending_regeneration, queue))
  }
  simulation
}
