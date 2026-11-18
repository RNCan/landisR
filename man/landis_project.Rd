\name{landis_project}
\alias{landis_read}
\alias{landis_build}
\alias{landis_from_canonical}
\alias{landis_write_canonical}
\title{Create and materialize landisR projects}
\usage{
landis_read(source_directory, scenario = "scenario.txt", cache_directory = NULL,
  prefer_cells_csv = TRUE, name = NULL, timestep = 1L)

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
Create a shared landisR landscape from LANDIS-II inputs, build a model
project from R tables, or open an existing canonical project.
}
\details{
\code{landis_read()} imports the species, ecoregions and ecoregion map,
and reads the duration and cell length from the scenario. The succession
extension supplies its own inputs. For Biomass Succession, pass the
landscape and the configuration read by
\code{landisR.succession.biomass::biomass_succession_read()} to
\code{landis_initialize()}.
}
\arguments{
  \item{source_directory}{Base directory for resolving the scenario path. Paths declared in the
    scenario are resolved relative to the scenario file.}
  \item{scenario}{Scenario file path, absolute or relative to
    \code{source_directory}.}
  \item{cache_directory}{Legacy argument. Use \code{landis_from_canonical()}
    to reopen existing canonical Biomass Succession inputs.}
  \item{prefer_cells_csv}{Use the shared grid columns from a scenario-local \file{cells.csv} when present.}
  \item{name}{Project name. For \code{landis_read()}, \code{NULL}
    uses the name of \code{source_directory}.}
  \item{landscape}{Data frame with \code{cell_id}, \code{row}, \code{col},
    \code{ecoregion_map_code}, \code{ecoregion}, \code{active}, and
    \code{community}. Use one row per grid cell, including inactive cells,
    with one-based column-major cell IDs.}
  \item{species}{Species traits keyed by \code{species}. Include longevity,
    maturity, shade and fire tolerance, seed distances in metres,
    vegetative probability, sprout age bounds and post-fire regeneration
    type, as shown below.}
  \item{species_parameters}{Biomass Succession traits keyed by
    \code{species}, including \code{leaf_longevity}, \code{woody_decay},
    \code{mortality_shape}, \code{growth_shape}, and \code{leaf_lignin}.}
  \item{ecoregions}{Ecoregion catalog with \code{map_code},
    \code{ecoregion}, \code{active}, and \code{description}.}
  \item{ecoregion_parameters}{Ecoregion table keyed by \code{ecoregion}
    with actual evapotranspiration in the \code{aet} column.}
  \item{dynamic}{Table keyed by \code{year}, \code{ecoregion}, and
    \code{species}, with establishment probability \code{sep}, production
    \code{max_anpp}, and \code{max_biomass}. Include baseline rows at year
    zero.}
  \item{initial_cohorts}{Table with \code{map_code} (community code),
    \code{species} and \code{age} in years. In explicit biomass mode,
    also supply \code{biomass} in grams per square metre.}
  \item{shade}{Minimum relative biomass per shade class, with a
    \code{shade} column and a column for each active ecoregion.}
  \item{light}{Establishment probabilities keyed by \code{shade_tolerance}
    with columns \code{shade_0} through \code{shade_5}.}
  \item{fire_reductions}{Compatibility table keyed by \code{severity},
    with \code{wood_reduction} and \code{litter_reduction}.}
  \item{duration}{Maximum simulation duration in years.}
  \item{cell_length}{Cell side length in metres.}
  \item{timestep}{Timestep in years. For \code{landis_read()}, the default is one year.}
  \item{seeding_algorithm}{Seeding algorithm label stored with the project.}
  \item{spinup_cohorts}{Logical value stored for the LANDIS-II
    \code{SpinupCohorts} setting. Use \code{initial_mode} to choose how
    initial biomass is obtained.}
  \item{spinup_mortality_fraction}{Biomass mortality fraction during spinup.}
  \item{initial_mode}{Use supplied cohort biomass with
    \code{"explicit_biomass"} or calculate it from ages using
    \code{"age_spinup"}.}
  \item{community_codes}{Optional vector of initial community codes.
    With \code{NULL}, use codes found on active cells or in the cohort
    table, excluding zero.}
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
\code{landis_read()} returns a \code{landisR_landscape_project}.
A \code{landisR_project}, or the canonical directory path for
\code{landis_write_canonical()}.
}

\examples{
if (requireNamespace("landisR.succession.biomass", quietly = TRUE)) {
  species <- data.frame(species = "PINU.BAN", longevity = 120L,
    maturity = 15L, shade_tolerance = 1L, fire_tolerance = 3L,
    effective_seed_distance = 100, max_seed_distance = 250,
    vegetative_probability = 0, min_sprout_age = 0L, max_sprout_age = 0L,
    post_fire_regeneration = "serotiny")
  traits <- data.frame(species = "PINU.BAN", leaf_longevity = 3,
    woody_decay = 0.05, mortality_shape = 15, growth_shape = 0.5,
    leaf_lignin = 0.2)
  grid <- data.frame(cell_id = 1L, row = 1L, col = 1L,
    ecoregion_map_code = 1L, ecoregion = "north", active = TRUE,
    community = 1L)
  eco <- data.frame(map_code = 1L, ecoregion = "north", active = TRUE,
    description = "Example ecoregion")
  productivity <- data.frame(year = 0L, ecoregion = "north",
    species = "PINU.BAN", sep = 1, max_anpp = 100, max_biomass = 5000)
  initial <- data.frame(map_code = 1L, species = "PINU.BAN",
    age = 30L, biomass = 100)
  shade <- data.frame(shade = 1:5, north = c(0, 0.2, 0.4, 0.6, 0.8))
  light <- data.frame(shade_tolerance = 1:5, shade_0 = 1, shade_1 = 1,
    shade_2 = 1, shade_3 = 1, shade_4 = 1, shade_5 = 1)
  reductions <- data.frame(severity = 1L, wood_reduction = 0,
    litter_reduction = 0.5)

  project <- landis_build(grid, species, traits, eco,
    data.frame(ecoregion = "north", aet = 600), productivity, initial,
    shade, light, reductions, duration = 10L, cell_length = 100)
  canonical_dir <- tempfile("landis-canonical-")
  landis_write_canonical(project, canonical_dir)
  restored <- landis_from_canonical(canonical_dir)
  print(restored)
  unlink(canonical_dir, recursive = TRUE)
}
\dontrun{
# Import an existing LANDIS-II project instead.
landscape <- landis_read("inputs", scenario = "scenario.txt")
succession <- landisR.succession.biomass::biomass_succession_read("inputs")
sim <- landis_initialize(landscape, succession = succession)
}
}
