\name{landis_run_io}
\alias{landis_save_run}
\alias{landis_load_run}
\title{Save and reload a landisR run descriptor}
\description{
Save the lightweight \code{landisR_run} object inside a simulation output
folder and reload it later without rerunning the simulation.
}
\usage{
landis_save_run(run, output_directory = NULL, filename = landisR_run_descriptor_filename())

landis_load_run(output_directory, filename = landisR_run_descriptor_filename(), check = TRUE)
}
\arguments{
  \item{run}{A \code{landisR_run} object returned by \code{landis_run()}.}
  \item{output_directory}{Simulation output directory. For
  \code{landis_load_run()}, a direct path to the RDS descriptor is also
  accepted.}
  \item{filename}{Descriptor filename.}
  \item{check}{Logical; check for snapshots/checkpoints and emit informative
  warnings when appropriate.}
}
\value{
\code{landis_save_run()} returns the descriptor path invisibly.
\code{landis_load_run()} returns a \code{landisR_run} object.
}
\details{
The descriptor does not duplicate simulation snapshots or checkpoints. It stores
only the lightweight run object needed to rediscover those files. When a run
folder is moved, \code{landis_load_run()} rebases its output path and attempts to
rediscover the nearby context cache.
}
\examples{
\dontrun{
sim <- landis_run(
  project,
  duration = 100,
  seed = 4357,
  output_directory = "outputs/baseline"
)

# Written automatically by landis_run():
# outputs/baseline/landisR_run.rds

sim2 <- landis_load_run("outputs/baseline")
}
}
