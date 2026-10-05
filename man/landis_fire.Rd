\name{landis_fire}
\alias{landis_fire}
\title{Apply a structured fire event with serotinous recruitment}
\usage{
landis_fire(
  simulation,
  cells,
  update = NULL,
  stochastic = TRUE,
  severity = NULL,
  metadata = list()
)
}
\arguments{
  \item{simulation}{A \code{landisR_simulation}.}
  \item{cells}{Integer vector of active cell IDs affected by fire. These cells
  are used to identify pre-fire mature serotinous seed sources.}
  \item{update}{Optional \code{landisR_update}, or function returning one,
  describing the post-fire cohort or project state. The pre-fire seed sources
  are captured before this update is applied.}
  \item{stochastic}{Logical. If \code{TRUE}, establishment is sampled from the
  current simulation RNG stream. If \code{FALSE}, every positive-probability
  serotinous establishment succeeds.}
  \item{severity}{Optional scalar or vector aligned with \code{cells}. Severity
  is currently recorded as event metadata and does not alter cone opening or
  establishment.}
  \item{metadata}{Optional list added to the fire event history.}
}
\description{
Implements fire-triggered serotinous recruitment for landisR beta.3. Mature
serotinous seed sources are identified from the pre-fire state. An optional
post-fire update is then applied, followed by serotinous seed arrival and
establishment using the post-fire light and establishment environment.
}
\details{
Species may define \code{serotiny_type} as \code{"none"},
\code{"facultative"}, or \code{"strict"}. Facultative species retain ordinary
sexual recruitment and also recruit after fire. Strict species are excluded
from ordinary sexual recruitment and can recruit naturally only through a
structured fire event.

\code{serotiny_dispersal} may be \code{"local"} or \code{"kernel"}. Local
mode restricts fire-released seed to the burned source cell, preserving the
LANDIS-II-style behavior. Kernel mode disperses fire-released seed with the
species Ward kernel using effective and maximum seed distances. Destination
cells do not need to have burned, but must satisfy normal establishment and
light constraints.

For imported LANDIS-II species with
\code{post_fire_regeneration = "serotiny"}, missing landisR-specific traits
default to \code{serotiny_type = "facultative"} and
\code{serotiny_dispersal = "local"}.
}
\value{
The updated \code{landisR_simulation}, including the advanced RNG state and a
\code{"fire"} entry in its event history.
}
\examples{
\dontrun{
# The external fire model supplies the post-fire cohort state.
burned <- c(101L, 102L)
after_fire <- landis_state(sim, "cohorts", cells = burned)
after_fire$biomass <- floor(after_fire$biomass * 0.25)

sim <- landis_fire(
  sim,
  cells = burned,
  update = landis_update(cohorts = after_fire),
  severity = 4
)
}
}
