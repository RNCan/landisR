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
  \item{duration}{Simulation duration in years.}
  \item{seed}{landisR random seed.}
  \item{output_directory}{Destination for compact simulation outputs.}
  \item{output_years}{Years for state snapshots.}
  \item{climate}{Climate configuration.}
  \item{dispersal}{Dispersal mode.}
  \item{ward_variant}{Ward implementation variant.}
  \item{checkpoint_every}{Checkpoint interval in years.}
  \item{snapshot_compression}{Snapshot RDS compression mode.}
  \item{checkpoint_compression}{Checkpoint RDS compression mode.}
  \item{cache_directory}{Canonical/context cache directory.}
  \item{rng_chunk_cells}{RNG processing chunk size.}
  \item{progress}{Show console progress during initialization, succession
  and output writing. Defaults to display in interactive sessions.
  Set \code{options(landisR52.progress = TRUE)} with progress enabled to
  use detailed native growth and recruitment progress for a production run.}
}
\value{A \code{landisR_run} object.}
