\name{landis_sim}
\alias{landis_sim}
\alias{landis_extension}
\title{Run succession and external extensions on one forest state}
\usage{
landis_sim(x, steps = NULL, extensions = NULL, seed = 4357L, ...)

landis_extension(
  step,
  initialize = function(simulation) NULL,
  phase = c("before_succession", "after_succession", "succession"),
  type = c("disturbance", "output", "succession")
)
}
\arguments{
  \item{x}{A landisR project, an initialized simulation, or a result from
  \code{landis_sim()}.}
  \item{steps}{Number of complete simulation steps. \code{NULL} runs all
  remaining complete steps. Use zero to initialize without advancing.}
  \item{extensions}{Named list of extensions when starting a run.}
  \item{seed, ...}{Arguments passed to \code{landis_initialize()} when
  \code{x} is a project.}
  \item{step}{Function of \code{simulation}, \code{state} and \code{year}.
  Return a list with \code{simulation}, \code{state}, and optionally
  \code{events}. The extension must preserve the clock and active grid.}
  \item{initialize}{Function of the initial simulation that returns
  the extension state.}
  \item{phase}{Defaults to the phase associated with \code{type}.}
  \item{type}{Disturbances run before succession. Read-only output
  extensions run after succession and may update their own state and events.
  Projects from \code{landis_build_landscape()} can register one
  \code{type = "succession"} extension.}
}
\description{
Each step applies the disturbances in declaration order to the same forest
state, advances succession once, and runs the output extensions. All
extensions receive the target year. For landscape projects, an external
succession extension receives the forest after the disturbances and
returns its updated cohorts before the core advances the clock.
A landscape project can also run with no succession extension. For Base Fire and Biomass Harvest, supply descriptors from
\code{landisR.fire::basefire_extension()} and
\code{landisR.harvest::harvest_extension()} in the desired order. The
latest fire date for each burned cell is available to subsequent harvest
steps, including a harvest in the same year. For a custom disturbance,
use the \code{year} argument when calling \code{landis_fire()}.
Older saved runs that contain after-succession disturbances must be
restarted with descriptors that use the new order.
}
\value{
\code{landis_extension()} returns an extension descriptor.
\code{landis_sim()} returns a \code{landisR_coupled_run} with the current
\code{simulation}, \code{extensions}, \code{extension_states}, and
\code{events} indexed by extension name and target year. Pass this result
back to \code{landis_sim()} to continue with the saved states and journals.
}
