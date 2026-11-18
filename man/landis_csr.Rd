\name{landis_csr}
\alias{landis_csr}
\title{Read the shared cohort store for a disturbance kernel}
\usage{landis_csr(simulation)}
\arguments{
  \item{simulation}{An initialized landisR simulation.}
}
\description{
Provides the current compact cohort vectors and spatial indexes without
expanding the forest to a table of cohorts per cell.
}
\details{
Treat the returned vectors as read-only, including in native code.
Acquire a new view after applying an update or advancing succession.
Use \code{landis_apply()} or \code{landis_apply_cohort_batch()} to update
cohorts. Use \code{landis_state()} for reporting.
}
\value{
A named list. \code{states} is the CSR v3 store with zero-based
\code{offset} and \code{species_id} vectors, cohort \code{age} in years,
and cohort \code{biomass} in grams per square metre.
\code{cell_id} gives active cells in simulation order. The aligned
\code{cell_state} vector maps each active cell to a one-based CSR state.
\code{state_eco} and \code{cell_eco} give the ecoregion indexes per state
and per active cell. \code{species} catalog entries are in species ID
order. \code{nrow}, \code{ncol}, and \code{cell_length} describe the
grid. Cell length is in metres.
}

\examples{
grid <- data.frame(cell_id = 1:2, row = 1L, col = 1:2, active = TRUE)
project <- landis_build_landscape(grid, duration = 20L, cell_length = 100,
  species = data.frame(species = "PINE"))
sim <- landis_initialize(project)
forest <- landis_csr(sim)
forest$cell_id
forest$states$offset
}
