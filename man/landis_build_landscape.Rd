\name{landis_build_landscape}
\alias{landis_build_landscape}
\title{Build a landscape project for the simulation core}
\usage{
landis_build_landscape(landscape, duration, cell_length, timestep = 10L,
  species = data.frame(species = character()), name = "landscape")
}
\arguments{
  \item{landscape}{Data frame containing the full rectangular grid, including
  inactive cells, with integer \code{cell_id}, \code{row}, and \code{col}
  columns and a logical \code{active} column. IDs use one-based column-major
  order. Optional \code{ecoregion} labels default to \code{"default"}.}
  \item{duration}{Positive duration in years, a multiple of \code{timestep}.}
  \item{cell_length}{Positive cell side length in metres.}
  \item{timestep}{Positive time step in years.}
  \item{species}{Optional catalog with a \code{species} column of unique codes.
  Cell updates refer to these codes.}
  \item{name}{Project name.}
}
\description{
Build a project that initializes with an empty shared cohort store. Use
\code{landis_initialize()} and \code{landis_apply()} to seed the store with
explicit cohorts. Use \code{landis_sim()} to run registered extensions.
\code{landis_step()} advances the clock of a landscape project.
}
\value{A \code{landisR_landscape_project}, also inheriting \code{landisR_project}.}
\examples{
cells <- data.frame(cell_id = 1:2, row = 1L, col = 1:2, active = TRUE)
project <- landis_build_landscape(cells, duration = 20L, cell_length = 100)
run <- landis_sim(project)
stopifnot(run$simulation$year == 20L)
}
