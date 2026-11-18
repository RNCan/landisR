\name{landis_schedule_regeneration}
\alias{landis_schedule_regeneration}
\alias{landis_deferred_regeneration}
\title{Queue regeneration from disturbance mortality}
\usage{
landis_deferred_regeneration(simulation)
landis_schedule_regeneration(simulation, mortality, source = c("other", "fire"))
}
\arguments{
  \item{simulation}{An interactive LANDIS simulation.}
  \item{mortality}{Data frame with active \code{cell_id}, cohort \code{species}
  and \code{age} for cohorts completely killed by the disturbance.}
  \item{source}{Use \code{"fire"} for fire mortality.}
}
\description{
In v7 regeneration mode, eligible cohort mortality queues one signal per cell
and species for Biomass Succession. The reproduction phase consumes the queue.
}
\value{A logical value from \code{landis_deferred_regeneration}, or the updated
simulation from \code{landis_schedule_regeneration}.}

\examples{
\dontrun{
# Use a biomass project with PICE.MAR and a recorded pre-disturbance age.
sim <- landis_initialize(landis_from_canonical("inputs/canonical"),
  recruitment_rng = "landis_v7", regeneration_mode = "landis_v7")
if (landis_deferred_regeneration(sim)) {
  cell <- landis_csr(sim)$cell_id[1L]
  killed <- data.frame(cell_id = cell, species = "PICE.MAR", age = 40L)
  # In an extension, queue the actual records of cohorts it removed.
  sim <- landis_schedule_regeneration(sim, killed, source = "other")
}
}
}
