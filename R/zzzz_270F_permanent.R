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

landisR_apply_cohorts <- function(simulation,cohorts,clear_cells) {
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
    as.integer(clear_cells),sp,0L)
  simulation$states <- ans$states
  simulation$state_eco <- ans$state_eco
  simulation$cell_state <- ans$cell_state
  simulation$ctx$states <- ans$states
  simulation$ctx$state_eco <- ans$state_eco
  simulation$ctx$cell_state <- ans$cell_state
  simulation
}

landisR_serotiny_prefire_sources <- function(simulation,cells) {
  traits <- landisR_normalize_serotiny_traits(simulation$ctx$config$species)
  sero <- which(traits$serotiny_type != 'none')
  labels <- as.character(traits$species[sero])
  if (!length(sero) || !length(cells))
    return(stats::setNames(vector('list',length(sero)),labels))
  positions <- match(cells,as.integer(simulation$ctx$ids))
  if (anyNA(positions))
    return(.landisR_legacy_prefire_270F(simulation,cells))
  ans <- basefire_prefire_csr_252(simulation$states,
    as.integer(simulation$cell_state),as.integer(positions),
    as.integer(cells),as.integer(sero),as.numeric(traits$maturity[sero]),0L)
  names(ans) <- labels
  ans
}

.landisR_baseprob_270F <- function(simulation,config,year) {
  eco <- as.integer(simulation$state_eco)
  codes <- sort(unique(eco))
  sp <- as.character(config$species$species)
  nsp <- length(sp)
  thresholds <- vector('list',length(codes))
  probability <- vector('list',length(codes))
  maxbio <- numeric(length(codes))
  for (k in seq_along(codes)) {
    key <- as.character(codes[[k]])
    p <- bs52_dynamic_at(config,year,codes[[k]])
    if (!identical(as.character(p$species),sp))
      stop('270F: ordre des especes incompatible avec la reference 259')
    thresholds[[k]] <- as.numeric(config$shade[[key]][order(config$shade$shade)])
    if (!length(thresholds[[k]]) || anyNA(thresholds[[k]]))
      stop('270F: seuils de classe d ombre incomplets')
    maxbio[[k]] <- max(p$max_biomass)
    light_rows <- match(p$shade_tolerance,config$light$shade_tolerance)
    if (anyNA(light_rows)) stop('270F: shade_tolerance introuvable')
    class_prob <- matrix(0,nrow=length(thresholds[[k]])+1L,ncol=nsp)
    for (shade in seq.int(0L,length(thresholds[[k]]))) {
      col <- paste0('shade_',shade)
      if (!col %in% names(config$light)) stop('270F: lumiere absente: ',col)
      light <- as.numeric(config$light[light_rows,col])
      class_prob[shade+1L,] <- pmin(1,pmax(0,p$sep*light))
    }
    probability[[k]] <- class_prob
  }
  basefire_serotiny_baseprob_csr_259(simulation$states,eco,
    as.integer(codes),thresholds,as.numeric(maxbio),probability)
}

.landisR_native_site_build_270F <- function(simulation,pairs,active_sero,
    species_names,arrival,probability,get_params,timestep) {
  ecos <- as.integer(simulation$ctx$active_eco)
  eco_keys <- sort(unique(ecos[unique(pairs[,1L])]))
  anpp <- matrix(NA_real_,nrow=length(eco_keys),ncol=length(species_names))
  eco_max <- numeric(length(eco_keys))
  for (i in seq_along(eco_keys)) {
    p <- get_params(eco_keys[[i]])
    eco_max[[i]] <- max(p$max_biomass)
    anpp[i,] <- as.numeric(p$max_anpp[match(species_names,p$species)])
  }
  basefire_serotiny_build_256(simulation$states,as.integer(simulation$cell_state),
    as.integer(simulation$ctx$ids),ecos,pairs,as.integer(active_sero),
    as.character(species_names),arrival,probability,as.integer(eco_keys),
    anpp,eco_max,as.integer(timestep))
}

# landisR_serotiny_recruit_after_fire est genere AU BUILD, depuis
# la fonction source 0.1.0.9003 et deux ancres AST strictes.

landisR_serotiny_recruit_after_fire <- function (simulation, prefire_sources, stochastic = TRUE)
{
    config <- simulation$ctx$config
    species <- landisR_normalize_serotiny_traits(config$species)
    sero <- which(species$serotiny_type != "none")
    source_count <- integer(length(sero))
    names(source_count) <- species$species[sero]
    if (!length(sero)) {
        return(list(simulation = simulation, source_count = source_count, recruited_cells = 0L, recruited_cohorts = 0L, recruitment = data.frame()))
    }
    source_count[] <- vapply(species$species[sero], function(sp) length(prefire_sources[[sp]]), integer(1L))
    active_sero <- sero[source_count > 0L]
    if (!length(active_sero)) {
        return(list(simulation = simulation, source_count = source_count, recruited_cells = 0L, recruited_cohorts = 0L, recruitment = data.frame()))
    }
    states <- NULL
    features <- list(base_probability = .landisR_baseprob_270F(simulation, config, simulation$year))
    n_sites <- length(simulation$ctx$ids)
    n_sero <- length(active_sero)
    arrival <- matrix(0, nrow = n_sites, ncol = n_sero, dimnames = list(NULL, species$species[active_sero]))
    for (j in seq_along(active_sero)) {
        sp_index <- active_sero[j]
        sp <- species$species[sp_index]
        arrival[, j] <- landisR_serotiny_arrival(simulation, prefire_sources[[sp]], species[sp_index, , drop = FALSE])
    }
    base <- features$base_probability[simulation$cell_state, active_sero, drop = FALSE]
    if (!is.matrix(base) || !identical(dim(base), dim(arrival))) {
        stop("Dimensions incompatibles entre probabilite d'etablissement et arrivee serotineuse.", call. = FALSE)
    }
    probability <- base * arrival
    probability[!is.finite(probability)] <- 0
    probability[probability < 0] <- 0
    probability[probability > 1] <- 1
    dim(probability) <- dim(arrival)
    dimnames(probability) <- dimnames(arrival)
    if (isTRUE(stochastic)) {
        rng <- landisR_serotiny_rng_draw(simulation, n_sites, n_sero)
        simulation <- rng$simulation
        recruited <- rng$draw < probability
    }
    else {
        recruited <- probability > 0
    }
    pairs <- which(recruited, arr.ind = TRUE)
    if (!nrow(pairs)) {
        return(list(simulation = simulation, source_count = source_count, recruited_cells = 0L, recruited_cohorts = 0L, recruitment = data.frame()))
    }
    active_ids <- as.integer(simulation$ctx$ids)
    cell_groups <- split(pairs[, 2L], pairs[, 1L])
    replacement <- vector("list", length(cell_groups))
    record <- vector("list", nrow(pairs))
    record_i <- 0L
    params_cache <- new.env(parent = emptyenv())
    get_params <- function(eco) {
        key <- as.character(eco)
        if (!exists(key, params_cache, inherits = FALSE)) {
            assign(key, bs52_dynamic_at(config, simulation$year, eco), envir = params_cache)
        }
        get(key, params_cache, inherits = FALSE)
    }
    group_names <- names(cell_groups)
    {
        built_270F <- .landisR_native_site_build_270F(simulation, pairs, active_sero, as.character(species$species), arrival, probability, get_params, config$timestep)
        replacement <- list(built_270F$replacement)
        record <- list(built_270F$recruitment)
        record_i <- 1L
    }
    replacement <- do.call(rbind, replacement)
    rownames(replacement) <- NULL
    simulation <- landisR_apply_cohorts(simulation, cohorts = replacement, clear_cells = integer())
    recruitment <- do.call(rbind, record[seq_len(record_i)])
    rownames(recruitment) <- NULL
    list(simulation = simulation, source_count = source_count, recruited_cells = length(unique(recruitment$cell_id)), recruited_cohorts = nrow(recruitment), recruitment = recruitment)
}
