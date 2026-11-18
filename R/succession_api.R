# Core services used by the separately installed Biomass Succession provider.
landis_succession_services <- function() {
  list(
    n_states = bs52_large_n_states52,
    encode_csr = bs52_states_list_to_csr_cpp,
    snapshot = bs52_large_compact_snapshot52,
    checkpoint = bs52_large_checkpoint52,
    write_rds = bs52_large_atomic_save52,
    state_list = landisR_state_list,
    apply_cohorts = landisR_apply_cohorts,
    progress_bar = landis_progress_bar
  )
}

landisR_biomass_backend <- function() {
  if (!isNamespaceLoaded("landisR.succession.biomass") &&
      !nzchar(system.file(package = "landisR.succession.biomass"))) {
    landisR_stop("Install landisR.succession.biomass to use Biomass Succession.")
  }
  backend <- getExportedValue("landisR.succession.biomass", "landis_biomass_backend")()
  if (identical(backend$api_version, 1L)) {
    backend$fire <- list(capture_sources = backend$prefire, recruit = backend$postfire)
  } else if (!identical(backend$api_version, 2L)) {
    landisR_stop("Unsupported Biomass Succession provider API.")
  }
  if (!is.function(backend$fire$capture_sources) || !is.function(backend$fire$recruit))
    landisR_stop("Biomass Succession must provide both fire response hooks.")
  backend
}

# Dispatch on a configuration supplied by a succession package.
landis_initialize_succession <- function(succession, project, seed, ...) {
  UseMethod("landis_initialize_succession")
}

landis_initialize_succession.default <- function(succession, project, seed, ...) {
  landisR_stop("No succession initializer for class ", paste(class(succession), collapse = ", "), ".")
}
