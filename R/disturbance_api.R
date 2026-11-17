# A read-only view for native disturbance kernels. The vectors are shared.
landis_csr <- function(simulation) {
  simulation <- landisR_validate_simulation(simulation)
  ctx <- simulation$ctx
  list(states = simulation$states,
       cell_state = simulation$cell_state,
       state_eco = simulation$state_eco,
       cell_id = ctx$ids,
       cell_eco = ctx$active_eco,
       nrow = ctx$nrow,
       ncol = ctx$ncol,
       species = ctx$config$species$species,
       cell_length = ctx$config$cell_length)
}

# Apply one combined cohort edit, retaining one sparse journal entry per operation.
landis_apply_cohort_batch <- function(simulation, cohorts = NULL, clear_cells = integer(),
                                     event_metadata = list(), preserve_cohort_order = FALSE) {
  simulation <- landisR_validate_simulation(simulation)
  if (!is.list(event_metadata) || !all(vapply(event_metadata, is.list, logical(1L))))
    landisR_stop("event_metadata must be a list of metadata lists.")
  update <- landis_update(cohorts = cohorts, clear_cells = clear_cells,
                          preserve_cohort_order = preserve_cohort_order)
  simulation <- landisR_apply_cohorts(simulation, update$cohorts, update$clear_cells,
                                     preserve_order = update$preserve_cohort_order)
  if (length(event_metadata)) {
    journal <- lapply(unname(event_metadata), function(metadata) {
      landisR_event(simulation$year, "apply", metadata)
    })
    simulation$history <- c(simulation$history, journal)
  }
  simulation
}
