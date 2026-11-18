\name{landis_coupling}
\alias{landis_capabilities}
\alias{landis_supports}
\alias{landis_modifier}
\title{Generic model coupling capabilities and optional modifiers}
\usage{
landis_capabilities(x)

landis_supports(x, requirements, all = TRUE)

landis_modifier(fun, name = "modifier", requires = character(),
  state = c("compact", "cohorts", "biomass"), cells = NULL,
  scope = "unspecified", metadata = list())
}
\description{
Discover the capabilities of a running simulation or growth engine and create
an optional lightweight wrapper around an arbitrary R process function.
}
\details{
The core coupling contract is \code{landis_update()} plus
\code{landis_apply()}. A full disturbance extension does not need to use
\code{landis_modifier()}.

A modifier function can request any subset of the named arguments
\code{state}, \code{inputs}, \code{context}, \code{capabilities}, and
\code{simulation}. It must return a \code{landisR_update} or \code{NULL}.
Returning \code{NULL} means that the process makes no change at the current
timestep.

Requirements are stable capability identifiers such as
\code{"state.cohorts"}, \code{"update.dynamic"}, or
\code{"engine_input.sep"}.
}
\arguments{
  \item{x}{A Biomass Succession simulation or growth-engine descriptor.
  \code{landis_supports()} also accepts an existing
  \code{landisR_capabilities} object.}
  \item{requirements}{Character vector of capability identifiers.}
  \item{all}{If \code{TRUE}, require all capabilities; otherwise require any.}
  \item{fun}{Arbitrary R process function.}
  \item{name}{Human-readable process name.}
  \item{requires}{Capabilities required before the process is run.}
  \item{state}{Forest-state representation supplied to the process.}
  \item{cells}{Optional active cell identifiers, or a function resolving them.}
  \item{scope}{Free-form scope label. It does not determine biological logic.}
  \item{metadata}{Free-form metadata attached to updates from the modifier.}
}
\value{
\code{landis_capabilities()} returns a \code{landisR_capabilities} object.
\code{landis_supports()} returns a logical value.
\code{landis_modifier()} returns a callable \code{landisR_modifier}.
}

\examples{
engine <- landis_growth_biomass52()
capabilities <- landis_capabilities(engine)
landis_supports(capabilities, "state.cohorts")

clear_first_cell <- landis_modifier(
  function(state) landis_update(clear_cells = 1L),
  name = "clear cell 1", requires = "state.cohorts", state = "cohorts"
)
\dontrun{
# Use a Biomass Succession simulation with cell 1 active.
sim <- landis_apply(sim, clear_first_cell)
}
}
