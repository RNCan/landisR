# 270F: fonctions destinees a etre INSTALLEES DANS UNE COPIE ISOLEE de landisR.
# Pas de sourceCpp, ni remplacement de namespace au runtime.
# Corps sources originaux renommees .landisR_legacy_*_270F au build.

.landisR_csr_cache_270F <- local({
  e <- new.env(parent=emptyenv())
  e$valid <- FALSE
  e$states <- NULL
  e$species <- NULL
  e$result <- NULL
  e
})

landisR_state_list <- function(simulation) {
  sp <- as.character(simulation$ctx$config$species$species)
  cache <- .landisR_csr_cache_270F
  if (isTRUE(cache$valid) && identical(simulation$states,cache$states) &&
      identical(sp,cache$species)) return(cache$result)
  result <- basefire_csr_decode_states_255(simulation$states,sp,0L)
  cache$states <- unserialize(serialize(simulation$states,NULL,version=3L))
  cache$species <- sp
  cache$result <- result
  cache$valid <- TRUE
  result
}

landis_state <- function(simulation,representation=c('compact','cohorts','biomass'),
                         cells=NULL,year=NULL) {
  selected <- match.arg(representation)
  if (!identical(selected,'cohorts') || !is.null(cells) || !is.null(year) ||
      !inherits(simulation,'landisR_simulation')) {
    return(.landisR_legacy_state_270F(simulation,representation=representation,
                                     cells=cells,year=year))
  }
  ids <- as.integer(simulation$ctx$ids)
  tab <- simulation$project$canonical$landscape$cells
  states <- landisR_state_list(simulation)
  expanded <- basefire_expand_cohorts_251(states,as.integer(simulation$cell_state),ids,
    as.integer(tab$row[ids]),as.integer(tab$col[ids]),as.character(tab$ecoregion[ids]))
  out <- data.frame(cell_id=as.integer(expanded$cell_id),
    row=as.integer(expanded$row),col=as.integer(expanded$col),
    ecoregion=as.character(expanded$ecoregion),
    species=as.character(expanded$species),
    age=as.numeric(expanded$age),biomass=as.numeric(expanded$biomass),
    stringsAsFactors=FALSE)
  rownames(out) <- NULL
  out
}

landisR_apply_cohorts <- function(simulation, cohorts, clear_cells, preserve_order = FALSE) {
  if (is.null(cohorts) && !length(clear_cells)) return(simulation)
  if (is.null(cohorts)) cohorts <- data.frame(cell_id=integer(),species=character(),
    age=numeric(),biomass=numeric(),stringsAsFactors=FALSE)
  stopifnot(all(c('cell_id','species','age','biomass') %in% names(cohorts)))
  sp <- as.character(simulation$project$canonical$species$species)
  ans <- basefire_apply_csr_253(simulation$states,as.integer(simulation$state_eco),
    as.integer(simulation$cell_state),as.integer(simulation$ctx$ids),
    as.integer(simulation$ctx$active_eco),
    data.frame(cell_id=as.integer(cohorts$cell_id),
      species=as.character(cohorts$species),age=as.numeric(cohorts$age),
      biomass=as.numeric(cohorts$biomass),stringsAsFactors=FALSE),
    as.integer(clear_cells), sp, 0L, preserve_order)
  simulation$states <- ans$states
  simulation$state_eco <- ans$state_eco
  simulation$cell_state <- ans$cell_state
  simulation$ctx$states <- ans$states
  simulation$ctx$state_eco <- ans$state_eco
  simulation$ctx$cell_state <- ans$cell_state
  simulation
}
