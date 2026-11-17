\name{landis_apply_cohort_batch}
\alias{landis_apply_cohort_batch}
\title{Apply a combined cohort edit and record its operations}
\usage{
landis_apply_cohort_batch(simulation, cohorts = NULL, clear_cells = integer(),
  event_metadata = list(), preserve_cohort_order = FALSE)
}
\arguments{
  \item{simulation}{An initialized landisR simulation.}
  \item{cohorts}{Replacement cohort rows with columns \code{cell_id},
  \code{species}, \code{age}, and \code{biomass}. Affected cells receive
  their complete replacement cohort sets.}
  \item{clear_cells}{Active cell IDs to empty. A replacement row for a
  clear cell supplies its new cohort set.}
  \item{event_metadata}{A list of sparse metadata lists, in journal order.
  Each element produces one apply entry at the simulation's current year.}
  \item{preserve_cohort_order}{Preserve the order of cohorts in replacements
  and in the state comparison keys.}
}
\description{
Commits one combined edit to the compact state and appends the corresponding
journal entries. The clock and random streams are preserved.
}
\details{
When using this API to group operations, the extension is responsible for
determining which edits can be computed from the same starting state and
combining their replacements. Apply dependent edits in sequence.
}
\value{The updated simulation.}
