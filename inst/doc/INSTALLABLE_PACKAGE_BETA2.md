# First installable landisR package

This step converts the validated beta development tree into a standard R source
package.

## Versioning

R package version:

```text
0.1.0.9002
```

Human-facing beta release label:

```text
v0.1.0-beta.2
```

The numeric R package version avoids ambiguity with R package version parsing.
The Git tag can still use the beta label.

## Important architectural change

The development tree compiles `src/growth52.cpp` at runtime with
`Rcpp::sourceCpp()`.

An installed R package must not do that. `Rcpp::compileAttributes()` creates
standard package wrappers and R installs a compiled DLL. A package-only runtime
bridge overrides the development loader so it verifies and uses the compiled
DLL directly.

`R/large52.R` and `src/growth52.cpp` themselves remain byte-identical to the
validated beta freeze.

## Workflow

Run:

```r
source("scripts/87_build_installable_package_beta2.R")
```

Then:

```r
source("scripts/88_install_smoke_test_beta2.R")
```

The smoke test installs the new package into an isolated local library and
requires its 0-year and 10-year compact snapshots to be exactly identical to the
already validated beta.2 reference.

Only after this test passes should the source package be considered the first
installable beta artifact.
