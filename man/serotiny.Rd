\name{serotiny}
\alias{serotiny}
\alias{serotiny_type}
\alias{serotiny_dispersal}
\title{Configure facultative and strict serotiny}
\description{
Species-level landisR traits control whether fire-triggered serotinous
recruitment supplements ordinary sexual recruitment or replaces it, and
whether fire-released seed remains local or disperses through the Ward
kernel.
}
\section{Species fields}{
Two landisR-specific columns may be added to the species table:

\describe{
  \item{\code{serotiny_type}}{Character. One of \code{"none"},
  \code{"facultative"}, or \code{"strict"}.}
  \item{\code{serotiny_dispersal}}{Character. One of \code{"none"},
  \code{"local"}, or \code{"kernel"}.}
}

Valid combinations are:

\tabular{lll}{
\strong{serotiny_type} \tab \strong{serotiny_dispersal} \tab \strong{Meaning} \cr
none \tab none \tab no serotinous recruitment \cr
facultative \tab local \tab ordinary seeding plus local post-fire serotiny \cr
facultative \tab kernel \tab ordinary seeding plus dispersing post-fire serotiny \cr
strict \tab local \tab natural sexual recruitment only after fire, locally \cr
strict \tab kernel \tab natural sexual recruitment only after fire, with Ward dispersal \cr
}
}
\section{Defaults}{
If \code{serotiny_type} is missing, species imported with
\code{post_fire_regeneration = "serotiny"} default to
\code{"facultative"}; other species default to \code{"none"}.

If \code{serotiny_dispersal} is missing, serotinous species default to
\code{"local"} and non-serotinous species default to \code{"none"}.

A species with \code{serotiny_type = "none"} must use
\code{serotiny_dispersal = "none"}. A serotinous species must use
\code{"local"} or \code{"kernel"}.
}
\section{Strict serotiny}{
For \code{serotiny_type = "strict"}, mature cohorts do not contribute to
the ordinary natural sexual-recruitment pathway. A structured
\code{\link{landis_fire}} event is required to release seed. The parent
cohort must be mature and alive in a burned source cell immediately before
the fire update.

The source is captured before fire mortality is applied. This permits a
stand-replacing fire to kill the parent cohort while still allowing its
serotinous seed bank to contribute to post-fire recruitment.
}
\section{Local and kernel dispersal}{
\code{"local"} limits fire-released seed to the source cell.
\code{"kernel"} uses the same Ward dispersal machinery as ordinary
seeding. Seed may arrive in burned or unburned active cells. Recruitment
still depends on post-fire SEP and sufficient light.

For coarse landscapes, the Ward implementation preserves the first cardinal
neighbor even when the species effective and maximum seed distances are
shorter than one raster cell. Species-specific outer dispersal limits remain
in effect beyond this coarse-grid safeguard.
}
\section{Validation status}{
The beta.3 development implementation has targeted regression tests for
strict recruitment blocking, facultative recruitment, mature and immature
fire sources, local and Ward-kernel dispersal, RNG reproducibility, and the
coarse-grid case where maximum seed distance is shorter than raster
resolution.

A real 6est 5-km landscape test also verified that fire-created jack-pine
cohorts persist through subsequent succession timesteps and that seed can
arrive outside the burned footprint while establishment remains constrained
by local light and SEP.
}
\seealso{
\code{\link{landis_fire}}, \code{\link{landis_update}},
\code{\link{landis_step}}
}
\examples{
\dontrun{
# LANDIS-II-compatible facultative/local behavior
i <- project$canonical$species$species == "PINU.BAN"
project$canonical$species$serotiny_type[i] <- "facultative"
project$canonical$species$serotiny_dispersal[i] <- "local"

# Strict serotiny with post-fire Ward dispersal
project$canonical$species$serotiny_type[i] <- "strict"
project$canonical$species$serotiny_dispersal[i] <- "kernel"
}
}
