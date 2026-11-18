\name{landis_fire}
\alias{landis_fire}
\alias{landis_fire_history}
\title{Apply a structured fire event with serotinous recruitment}
\usage{
landis_fire(
  simulation,
  cells,
  update = NULL,
  stochastic = TRUE,
  severity = NULL,
  metadata = list(),
  year = simulation$year
)

landis_fire_history(simulation)
}
\arguments{
  \item{simulation}{A \code{landisR_simulation}.}
  \item{cells}{Integer vector of active cell IDs affected by fire. These
  cells define the fire footprint and are inspected for mature serotinous
  seed sources before any post-fire update is applied.}
  \item{update}{Optional \code{landisR_update} describing the post-fire
  cohort or project state. It is applied after pre-fire seed sources are
  captured and before serotinous establishment is evaluated. For a severe
  stand-replacing fire, a typical update is
  \code{landis_update(clear_cells = cells)}.}
  \item{stochastic}{Logical. If \code{TRUE}, recruitment is sampled from
  the simulation RNG stream. If \code{FALSE}, every destination with a
  strictly positive final establishment probability recruits. The latter is
  mainly useful for diagnostics and spatial-support tests.}
  \item{severity}{Optional finite numeric scalar or vector aligned with
  \code{cells}. In the current implementation severity is stored in fire
  event metadata. It does not yet alter cone opening, seed release, or
  establishment probability.}
  \item{metadata}{Optional list appended to the fire-event history.}
  \item{year}{Current or next succession year. Pass the target year
  in a disturbance called by \code{landis_sim()}.}
}
\description{
Applies a structured fire event and evaluates fire-triggered serotinous
recruitment. Mature serotinous sources are identified from the pre-fire
cohort state, an optional fire-impact update is applied, and seed arrival
and establishment are then evaluated in the post-fire environment.
\code{landis_fire_history()} returns the latest positive recorded fire
year per burned cell as a sparse \code{cell_id}, \code{year} table, or
\code{NULL} before any such record. A cell with positive severity
qualifies even when no cohort dies. When severity is omitted, the
footprint supplied by the caller is treated as burned.
}
\details{
\strong{Event order.} The function intentionally separates fire-triggered
seed release from post-fire establishment. The order is: (1) identify mature
serotinous parent cohorts in \code{cells}; (2) save those pre-fire sources;
(3) apply \code{update}, if supplied; (4) disperse fire-released seed; (5)
apply post-fire SEP and sufficient-light constraints; and (6) create new
age-1 cohorts where recruitment succeeds.

\strong{Serotiny type.} Species may define \code{serotiny_type} as:
\itemize{
  \item \code{"none"}: no serotinous recruitment.
  \item \code{"facultative"}: ordinary sexual recruitment remains
  available and fire also activates serotinous recruitment.
  \item \code{"strict"}: ordinary natural sexual recruitment is
  disabled. Natural seed recruitment can occur only through a structured
  fire event with a mature pre-fire source.
}

Strict serotiny only blocks the ordinary natural sexual-recruitment path.
External state updates or planting represented by another model remain
separate processes.

\strong{Post-fire seed dispersal.} Serotinous species use
\code{serotiny_dispersal}:
\itemize{
  \item \code{"local"}: fire-released seed is available only in the
  burned source cell.
  \item \code{"kernel"}: fire-released seed uses the species Ward
  dispersal kernel with \code{effective_seed_distance} and
  \code{max_seed_distance}. Destination cells do not need to have burned.
}

The Ward implementation preserves access to the first cardinal neighboring
cell when species dispersal distances are shorter than raster resolution.
This prevents coarse rasters from making short-distance species completely
unable to disperse between cells.

\strong{Arrival is not establishment.} In kernel mode a non-burned cell
may receive seeds but still fail to recruit. The final establishment
probability combines seed arrival with the normal species- and
ecoregion-specific establishment environment, including SEP and
sufficient-light probability. Dense unburned forest can therefore receive
serotinous seed while remaining unsuitable for establishment.

\strong{LANDIS-II compatibility.} When a LANDIS-II project is imported, a
species with \code{post_fire_regeneration = "serotiny"} and no explicit
landisR serotiny traits defaults to
\code{serotiny_type = "facultative"} and
\code{serotiny_dispersal = "local"}. This retains the existing
LANDIS-II-style behavior unless the user explicitly requests strict
serotiny or Ward-kernel post-fire dispersal.

\strong{Random-number state.} With \code{stochastic = TRUE}, fire
recruitment consumes and advances the simulation RNG state, so repeated runs
remain reproducible when initialized from the same simulation state and RNG
state.
}
\value{
The updated \code{landisR_simulation}. The simulation history receives a
\code{"fire"} event containing the affected cells, severity metadata,
serotinous source counts, recruited-cell count, and recruited-cohort count.
\code{landis_fire_history()} returns a sparse data frame of burned cell IDs
and their most recent positive fire year, or \code{NULL} before any such
record is available.
}
\seealso{
\code{\link{landis_initialize}}, \code{\link{landis_step}},
\code{\link{landis_update}}, \code{\link{landis_apply}},
\code{\link{serotiny}}
}
\examples{
\dontrun{
# Import or build a project, then configure jack pine as strictly serotinous.
scenario_directory <- "D:/LANDIS/my_project"
project <- landis_read(scenario_directory)
succession <- landisR.succession.biomass::biomass_succession_read(scenario_directory)

i <- project$canonical$species$species == "PINU.BAN"
project$canonical$species$serotiny_type[i] <- "strict"
project$canonical$species$serotiny_dispersal[i] <- "kernel"

sim <- landis_initialize(project, seed = 4357L, succession = succession)

# Example severe fire. Mature seed sources are captured before cells are
# cleared, then Ward dispersal and post-fire establishment are evaluated.
burned_cells <- c(101L, 102L, 103L)

sim <- landis_fire(
  sim,
  cells = burned_cells,
  update = landis_update(clear_cells = burned_cells),
  severity = 5
)

landis_fire_history(sim)

# Continue succession normally.
sim <- landis_step(sim)

# Diagnostic mode: every positive-probability establishment succeeds.
sim2 <- landis_initialize(project, seed = 4357L, succession = succession)
sim2 <- landis_fire(
  sim2,
  cells = burned_cells,
  update = landis_update(clear_cells = burned_cells),
  stochastic = FALSE
)
}
}
