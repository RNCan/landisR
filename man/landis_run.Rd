\name{landis_run}
\alias{landis_run}
\title{Run a landisR succession simulation}
\usage{
landis_run(project, duration = NULL, seed = 4357L, output_directory,
  output_years = NULL, climate = list(name = "baseline", dynamic_file = NULL),
  dispersal = "ward", ward_variant = "ward2019", checkpoint_every = 20L,
  snapshot_compression = "gzip1", checkpoint_compression = "gzip1",
  cache_directory = NULL, rng_chunk_cells = 100000L,
  progress = getOption("landisR.progress", interactive()))
}
\description{
Run the living-biomass succession engine from a landisR project.
This function requires the installed package \pkg{landisR.succession.biomass}.
}
\arguments{
  \item{project}{A landisR project.}
  \item{duration}{Duration in years, a multiple of the project timestep.
    \code{NULL} uses the full project duration.}
  \item{seed}{landisR random seed.}
  \item{output_directory}{Destination for compact simulation outputs.}
  \item{output_years}{Sorted, unique snapshot years including zero,
    aligned to the project timestep. \code{NULL} saves each timestep.}
  \item{climate}{List with a scenario \code{name} and an optional
    \code{dynamic_file} path for alternative dynamic parameters.}
  \item{dispersal}{Use \code{"ward"} for Ward dispersal or \code{"local"}
    for within-cell dispersal.}
  \item{ward_variant}{Ward kernel variant, \code{"ward2019"} or
    \code{"ward2022"}.}
  \item{checkpoint_every}{Checkpoint interval in years.}
  \item{snapshot_compression, checkpoint_compression}{Compression for
    the respective RDS outputs, one of \code{"gzip1"}, \code{"gzip"}, or
    \code{"none"}.}
  \item{cache_directory}{Canonical/context cache directory.}
  \item{rng_chunk_cells}{RNG processing chunk size.}
  \item{progress}{Show console progress during initialization, succession
  and output writing. Defaults to display in interactive sessions.
  Set \code{options(landisR52.progress = TRUE)} with progress enabled to
  use detailed native growth and recruitment progress for a production run.}
}
\value{A \code{landisR_run} object.}

\examples{
\dontrun{
# Use the directory containing your LANDIS-II scenario files.
landscape <- landis_read("inputs")
succession <- landisR.succession.biomass::biomass_succession_read("inputs", scenario = "scenario.txt")
project <- landis_initialize(landscape, succession = succession)$project
run <- landis_run(project, output_directory = "outputs/biomass",
  output_years = c(0L, 10L, 20L), checkpoint_every = 10L, progress = FALSE)
print(run)
}
}
