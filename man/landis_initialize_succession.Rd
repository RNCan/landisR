\name{landis_initialize_succession}
\alias{landis_initialize_succession}
\title{Initialize a succession extension}
\usage{
landis_initialize_succession(succession, project, seed, ...)
}
\arguments{
  \item{succession}{Model inputs with an extension-specific S3 class.}
  \item{project}{A shared landscape from \code{landis_read()} or
    \code{landis_build_landscape()}.}
  \item{seed}{Random seed.}
  \item{...}{Other arguments explicitly supplied to \code{landis_initialize()}.}
}
\description{
S3 extension interface called by \code{landis_initialize()}. Register a
method on the extension's input class to check its inputs against the
shared landscape and initialize its forest state.
}
\value{A \code{landisR_simulation} at year zero.}
\seealso{\code{\link{landis_initialize}}, \code{\link{landis_extension}}}
