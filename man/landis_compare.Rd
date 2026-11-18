\name{landis_compare}
\alias{landis_compare}
\title{Compare landisR with LANDIS-II outputs}
\usage{
landis_compare(run, landis_outputs, project, years = NULL,
  orientation = c("auto", "direct", "mirror_y"), include_age_max = TRUE,
  output_directory = NULL, max_discrepancies = 1000L)
}
\description{
Compare compact landisR snapshots with LANDIS-II biomass and AGE-MAX TIFFs.
}
\arguments{
  \item{run}{landisR run object or output directory.}
  \item{landis_outputs}{LANDIS-II scenario or output root.}
  \item{project}{The corresponding landisR project.}
  \item{years}{Years to compare.}
  \item{orientation}{Raster orientation handling.}
  \item{include_age_max}{Compare AGE-MAX outputs.}
  \item{output_directory}{Comparison-report directory.}
  \item{max_discrepancies}{Maximum detailed discrepancies to retain.}
}
\value{A \code{landisR_comparison} object.}
\note{The optional package terra is required to read LANDIS-II TIFF files.}

\examples{
\dontrun{
# Set the directories to matching runs of the same input project.
landscape <- landis_read("inputs")
succession <- landisR.succession.biomass::biomass_succession_read("inputs")
project <- landis_initialize(landscape, succession = succession)$project
comparison <- landis_compare("outputs/landisR", "outputs/LANDIS-II",
  project, years = c(10L, 20L), orientation = "auto")
print(comparison)
}
}
