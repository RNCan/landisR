\name{landis_succession_services}
\alias{landis_succession_services}
\title{Core services for Biomass Succession}
\usage{landis_succession_services()}
\description{
Exposes the shared cohort encoding, persistence and progress reporting used by
the optional Biomass Succession engine.
}
\value{
A named list of functions for encoding and updating cohort state,
building snapshots and checkpoints, and writing compact RDS outputs.
}
\keyword{internal}

\examples{
services <- landis_succession_services()
names(services)
}
