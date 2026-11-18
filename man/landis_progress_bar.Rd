\name{landis_progress_bar}
\alias{landis_progress_bar}
\alias{landis_progress_native}
\title{Progress helpers for LANDIS-R extensions}
\usage{
landis_progress_bar(progress, title)
landis_progress_native(report, from, to, code)
}
\arguments{
  \item{progress}{Logical flag to enable the console display.}
  \item{title}{Title shown before the phase label.}
  \item{report}{A function of a fraction between zero and one and a phase label,
  or \code{NULL} to disable native progress.}
  \item{from, to}{Bounds of the native operation within its extension step.}
  \item{code}{Expression calling a native operation.}
}
\description{Services for extension authors. A progress bar supplies
\code{update(fraction, label)} and \code{close()} callbacks. The native
helper temporarily enables reports for a single native operation.}
\value{A list of console callbacks or \code{NULL} from
\code{landis_progress_bar()}. The unmodified value of \code{code} from
\code{landis_progress_native()}.}
\keyword{internal}
