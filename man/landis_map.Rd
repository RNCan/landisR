\name{landis_map}
\alias{landis_map}
\title{Display or return a spatial map from landisR}
\usage{
landis_map(
  x,
  year = NULL,
  variable = "TotalBiomass",
  species = NULL,
  age = NULL,
  cells = NULL,
  output = c("matrix", "data.frame", "SpatRaster"),
  plot = TRUE,
  engine = c("auto", "terra", "base"),
  grid_nrow = NULL,
  grid_ncol = NULL,
  cell_length = NULL,
  fill = NA_real_,
  main = NULL,
  col = NULL,
  axes = FALSE,
  ...
)
}
\arguments{
\item{x}{A \code{landisR_run}, \code{landisR_simulation}, \code{landisR_project}, or spatial data.frame.}
\item{year}{Saved simulation year. \code{NULL} uses the latest compatible state for a run.}
\item{variable}{Cell-level numeric output, commonly \code{"TotalBiomass"}, \code{"AGE_MAX"}, or a species identifier.}
\item{species}{Optional species identifier. With \code{age}, filters cohort biomass.}
\item{age}{Optional exact age or inclusive \code{c(min, max)} interval.}
\item{cells}{Optional active cell IDs.}
\item{output}{Return type: matrix, data.frame, or SpatRaster.}
\item{plot}{Display the map immediately.}
\item{engine}{Plot backend. Auto uses terra when available and base graphics otherwise.}
\item{grid_nrow,grid_ncol}{Optional complete grid dimensions for standalone data.frames.}
\item{cell_length}{Optional cell length for relative SpatRaster coordinates.}
\item{fill}{Value for unmapped cells, normally \code{NA_real_}.}
\item{main}{Plot title.}
\item{col}{Color vector.}
\item{axes}{Whether to draw axes.}
\item{...}{Additional plotting arguments.}
}
\value{
A matrix, data.frame, or terra SpatRaster. When \code{plot=TRUE}, the object is returned invisibly.
}
\description{
Maps saved or interactive landisR cell state without manual reshaping. Biomass and AGE_MAX use compact state. Age-filtered cohort biomass uses checkpoint/cohort state.
}
\details{
The current canonical beta format retains row/column geometry and cell length but not the original raster CRS or origin. SpatRaster output therefore uses relative grid coordinates unless georeferencing metadata are added in a future input format.
}
\examples{
\dontrun{
landis_map(sim, year = 100, variable = "TotalBiomass")
landis_map(sim, year = 100, species = "PICE.MAR")
landis_map(sim, year = 100, variable = "AGE_MAX")
landis_map(sim, year = 100, species = "PICE.MAR", age = c(80, 120))
}
}
