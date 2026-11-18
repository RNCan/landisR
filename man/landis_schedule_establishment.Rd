\name{landis_schedule_establishment}
\alias{landis_schedule_establishment}
\title{Schedule cell-level establishment directives}
\usage{
landis_schedule_establishment(simulation, planting = NULL, exclude = integer())
}
\arguments{
  \item{simulation}{An interactive simulation returned by \code{landis_initialize()}.}
  \item{planting}{A data frame of active \code{cell_id} and \code{species} pairs.
  A new list for a cell replaces its pending list.}
  \item{exclude}{Active cell IDs to exclude from subsequent Biomass Succession establishment.}
}
\description{
Schedule plantings for the next succession step. An excluded cell retains its existing
cohorts and their growth. The exclusions persist in the simulation across steps and saves.
A planting establishes deterministically where the species has a positive establishment
probability in the cell's ecoregion. Successful planting takes priority over natural seeding
for that step. Exclusion takes priority over planting.
}
\value{The interactive simulation with its pending directives and persistent exclusions.}

\examples{
\dontrun{
# Use a biomass project with PICE.MAR in its species catalog.
sim <- landis_initialize(landis_from_canonical("inputs/canonical"))
ids <- landis_csr(sim)$cell_id
plant <- data.frame(cell_id = ids[1L], species = "PICE.MAR")
sim <- landis_schedule_establishment(sim, planting = plant, exclude = ids[2L])
sim <- landis_step(sim, progress = FALSE)
}
}
