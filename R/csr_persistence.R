# Compact CSR operations and checkpoint encoding shared with succession engines.

bs52_large_n_states52 <- function(states) {
  if (!is.list(states) ||
      is.null(states$offset) ||
      !identical(
        states$format,
        "landisR52/state-csr-v3"
      )) {
    landisR_stop(
      "Store d'etats CSR v3 invalide."
    )
  }

  as.integer(
    length(states$offset) - 1L
  )
}

bs52_large_atomic_save52 <- function(
    object,
    path,
    compress = c(
      "gzip1",
      "gzip",
      "none"
    ),
    overwrite = FALSE) {

  compress <- match.arg(
    compress
  )

  dir.create(
    dirname(
      path
    ),
    recursive = TRUE,
    showWarnings = FALSE
  )

  if (file.exists(path) &&
      !isTRUE(overwrite)) {
    landisR_stop(
      "Fichier de sortie deja present : ",
      path
    )
  }

  # Keep the temporary filename short for Windows path compatibility.
  tmp <- paste0(
    path,
    ".tmp_",
    Sys.getpid()
  )

  if (file.exists(tmp)) {
    unlink(
      tmp,
      force = TRUE
    )
  }

  on.exit(
    {
      if (file.exists(tmp)) {
        unlink(
          tmp,
          force = TRUE
        )
      }
    },
    add = TRUE
  )

  if (identical(
        compress,
        "gzip1"
      )) {

    con <- gzfile(
      tmp,
      open = "wb",
      compression = 1
    )

    tryCatch(
      {
        serialize(
          object,
          con,
          ascii = FALSE,
          xdr = TRUE
        )
      },
      finally = {
        close(
          con
        )
      }
    )

  } else if (identical(
               compress,
               "gzip"
             )) {

    saveRDS(
      object,
      tmp,
      compress = "gzip"
    )

  } else {

    saveRDS(
      object,
      tmp,
      compress = FALSE
    )
  }

  if (!file.exists(tmp)) {
    landisR_stop(
      "Ecriture temporaire impossible : ",
      tmp
    )
  }

  if (file.exists(path)) {
    if (!isTRUE(overwrite)) {
      landisR_stop(
        "Impossible de remplacer : ",
        path
      )
    }

    unlink(
      path,
      force = TRUE
    )

    if (file.exists(path)) {
      landisR_stop(
        "Impossible de supprimer l'ancien fichier : ",
        path
      )
    }
  }

  if (!file.rename(
        tmp,
        path
      )) {
    landisR_stop(
      "Impossible de finaliser atomiquement le fichier : ",
      path
    )
  }

  invisible(
    path
  )
}

bs52_large_compact_snapshot52 <- function(states, state_eco, cell_state,
                                          ctx, year) {
  snapshot <- bs52_state_snapshot_csr_cpp(
    states,
    as.integer(
      nrow(ctx$config$species)
    )
  )

  colnames(snapshot$state_biomass) <-
    as.character(ctx$config$species$species)

  list(
    format = "landisR52/state-snapshot-v1",
    year = as.integer(year),
    cell_id = as.integer(ctx$ids),
    state_id = as.integer(cell_state),
    species = as.character(ctx$config$species$species),
    state_biomass = snapshot$state_biomass,
    state_total_biomass = as.numeric(snapshot$state_total_biomass),
    state_max_age = as.numeric(snapshot$state_max_age),
    state_ecoregion = as.integer(state_eco)
  )
}

bs52_large_checkpoint52 <- function(year, states, state_eco, cell_state,
                                    rng_state, run_signature) {
  list(
    format = "landisR52/state-checkpoint-v3-csr",
    year = as.integer(year),
    states = states,
    state_eco = as.integer(state_eco),
    cell_state = as.integer(cell_state),
    rng_state = rng_state,
    run_signature = run_signature,
    saved_at = Sys.time()
  )
}
