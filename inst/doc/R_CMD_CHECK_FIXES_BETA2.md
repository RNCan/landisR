# First R CMD check findings and beta.2 fixes

The first documented package check produced:

- 1 ERROR;
- 3 NOTEs;
- 0 WARNINGs.

The package itself installed and loaded successfully during the check. The
findings were package-engineering issues rather than scientific discrepancies.

## Test ERROR

The package test could directly call the compiled kernel version, but
`bs52_large_init_bulk52()` reported all C++ wrappers as missing.

Cause: the package runtime bridge used `vapply(..., exists)` without explicitly
supplying the package namespace. This could work in the development/smoke-test
session because compiled functions also existed in the global search context,
but failed in the clean `R CMD check` session.

Fix: every compiled-function check now uses the function's namespace
environment explicitly.

## C++11 NOTEs

R 4.6 reports explicit C++11 requests as obsolete.

Fix:

- remove `SystemRequirements: C++11`;
- remove `CXX_STD = CXX11` from `src/Makevars` and `src/Makevars.win`.

The scientific C++ file is unchanged.

## R-code NOTE

R CMD check reported ordinary unqualified functions plus historical calls to
dead-pool functions.

Fix:

- import `aggregate`, `runif`, `setNames` from `stats`;
- import `head`, `tail`, `type.convert` from `utils`;
- define internal dead-pool stubs that stop with a clear unsupported-beta
  message.

Dead pools remain outside the beta scope. No dead-pool implementation is added.

## Reproducibility

The replacement `87_build_installable_package_beta2.R` included with this patch
contains the same fixes so a future clean build does not reintroduce them.
