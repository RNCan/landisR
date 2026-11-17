\name{landisR-package}
\alias{landisR-package}
\alias{landisR}
\title{landisR: Landscape Simulation Core}
\description{
Manages the landscape grid, shared cohort state, simulation clock,
extensions, and persistent runs.
}
\details{
\code{landis_build_landscape()} and \code{landis_sim()} run a landscape
with the extensions selected by the user. Projects using the living
biomass engine require \pkg{landisR.succession.biomass}. The core loads
that package when a biomass project or simulation uses its services.
}
\docType{package}
