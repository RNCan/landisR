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
