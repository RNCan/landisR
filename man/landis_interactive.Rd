\name{landis_interactive}
\alias{landis_growth_biomass52}
\alias{landis_initialize}
\alias{landis_step}
\alias{landis_state}
\alias{landis_update}
\alias{landis_apply}
\title{Interactive simulation and model coupling}
\usage{
landis_growth_biomass52()

landis_initialize(project, seed = 4357L,
  growth_engine = landis_growth_biomass52(),
  dispersal = "ward", ward_variant = "ward2019",
  rng_chunk_cells = 100000L)

landis_step(simulation, steps = 1L)

landis_state(simulation,
  representation = c("compact", "cohorts", "biomass"),
  cells = NULL)

landis_update(project = NULL, canonical = NULL, landscape = NULL,
  species = NULL, species_parameters = NULL, ecoregions = NULL,
  ecoregion_parameters = NULL, dynamic = NULL,
  dynamic_mode = c("merge", "replace"), shade = NULL, light = NULL,
  fire_reductions = NULL, cohorts = NULL, clear_cells = integer(),
  settings = list(), metadata = list())

landis_apply(simulation, update)
}
\description{
Initialize a landisR simulation, advance it one succession timestep at a time,
inspect the current forest, and apply compatible state or input modifications
between timesteps.
}
\details{
The interactive API is an orchestration layer around the frozen Biomass
Succession 5.2 engine. External models do not manipulate the internal CSR state.

The first interactive implementation keeps the succession timestep, cell size,
raster geometry, active-cell set, and species registry fixed within a running
simulation. Ecological parameters, ecoregion assignments, dynamic parameters
and living cohorts can be modified when the resulting canonical project passes
validation.
}
\arguments{
  \item{project}{A \code{landisR_project}.}
  \item{seed}{Random seed for the Biomass Succession process.}
  \item{growth_engine}{A \code{landisR_growth_engine}.}
  \item{dispersal}{Dispersal mode.}
  \item{ward_variant}{Ward dispersal variant.}
  \item{rng_chunk_cells}{RNG chunk size used by the validated engine.}
  \item{simulation}{A \code{landisR_simulation}.}
  \item{steps}{Number of succession timesteps to advance.}
  \item{representation}{State representation to return.}
  \item{cells}{Optional active cell identifiers for expanded state output.}
  \item{canonical}{Complete canonical object or a function modifying one.}
  \item{landscape}{Replacement canonical landscape cell table.}
  \item{species}{Replacement species table with the same species registry.}
  \item{species_parameters}{Replacement species-parameter table.}
  \item{ecoregions}{Replacement ecoregion table.}
  \item{ecoregion_parameters}{Replacement ecoregion-parameter table.}
  \item{dynamic}{Dynamic parameter rows or complete replacement table.}
  \item{dynamic_mode}{Merge by year/ecoregion/species key or replace all.}
  \item{shade}{Replacement shade table.}
  \item{light}{Replacement sufficient-light table.}
  \item{fire_reductions}{Replacement compatibility table.}
  \item{cohorts}{Replacement living cohorts for affected active cells.}
  \item{clear_cells}{Cells whose living cohorts are cleared before replacement.}
  \item{settings}{Compatible scalar canonical settings to modify.}
  \item{metadata}{Free-form metadata describing an update.}
  \item{update}{A \code{landisR_update} or a function returning one.}
}
\value{
\code{landis_initialize()}, \code{landis_step()} and \code{landis_apply()}
return a \code{landisR_simulation}. \code{landis_state()} returns a state
representation. \code{landis_update()} returns a \code{landisR_update}.
}
