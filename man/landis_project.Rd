\name{landis_project}
\alias{landis_read}
\alias{landis_build}
\alias{landis_from_canonical}
\alias{landis_write_canonical}
\title{Create and materialize landisR projects}
\usage{
landis_read(source_directory, scenario = "scenario.txt", cache_directory = NULL,
  prefer_cells_csv = TRUE, name = NULL)

landis_build(landscape, species, species_parameters, ecoregions,
  ecoregion_parameters, dynamic, initial_cohorts, shade, light,
  fire_reductions, duration, cell_length, timestep = 10L,
  seeding_algorithm = "Ward", spinup_cohorts = FALSE,
  spinup_mortality_fraction = 0.05,
  initial_mode = c("explicit_biomass", "age_spinup"),
  community_codes = NULL, name = "custom_project")

landis_from_canonical(x, name = "canonical_project", cache_file = NULL)

landis_write_canonical(project, directory, overwrite = FALSE)
}
\description{
Create a common landisR project from LANDIS-II inputs, R-native tables, or
an existing canonical representation.
}
\arguments{
  \item{source_directory}{Directory containing a LANDIS-II scenario.}
  \item{scenario}{Scenario file name.}
  \item{cache_directory}{Optional canonical import cache.}
  \item{prefer_cells_csv}{Prefer an available cells.csv during LANDIS import.}
  \item{name}{Project name.}
  \item{landscape}{Canonical landscape cell table.}
  \item{species}{Species table.}
  \item{species_parameters}{Species succession parameter table.}
  \item{ecoregions}{Ecoregion table.}
  \item{ecoregion_parameters}{Ecoregion succession parameter table.}
  \item{dynamic}{Dynamic SEP, maxANPP, and maxBiomass table.}
  \item{initial_cohorts}{Initial cohort table.}
  \item{shade}{Minimum-relative-biomass shade table.}
  \item{light}{Sufficient-light table.}
  \item{fire_reductions}{Fire reduction table retained for compatibility.}
  \item{duration}{Maximum simulation duration in years.}
  \item{cell_length}{Cell length in metres.}
  \item{timestep}{Succession timestep in years.}
  \item{seeding_algorithm}{Seeding algorithm label.}
  \item{spinup_cohorts}{Whether age-only initial cohorts require spinup.}
  \item{spinup_mortality_fraction}{Spinup mortality fraction.}
  \item{initial_mode}{Explicit biomass or age-spinup initialization.}
  \item{community_codes}{Optional explicit set of community map codes.}
  \item{x}{Canonical object or canonical directory.}
  \item{cache_file}{Optional path to a dedicated binary RDS cache when
    \code{x} is a directory. The cache is populated on first use and rebuilt
    when canonical CSV inputs or the reader version change. Requires a
    Biomass Succession provider that supports binary caching.}
  \item{project}{A landisR project.}
  \item{directory}{Destination canonical directory.}
  \item{overwrite}{Whether to replace a non-empty destination.}
}
\value{
A \code{landisR_project}, or the canonical directory path for
\code{landis_write_canonical()}.
}
