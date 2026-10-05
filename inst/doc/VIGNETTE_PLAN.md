# Vignette plan for landisR beta.2

The first package vignette is:

```text
vignettes/getting-started.Rmd
```

It is intended to be the primary onboarding document for researchers using the
package.

It covers:

- what landisR is;
- installation;
- the three input routes;
- required R-native input tables;
- running a simulation;
- compact outputs;
- climate-sensitive inputs;
- LANDIS-II comparison;
- random seeds and stochastic equivalence;
- scientific validation;
- validated beta scope and limitations;
- reproducible project organization;
- links to the detailed schema and function documentation.

All code chunks are intentionally `eval = FALSE` for beta.2 because a portable
example dataset has not yet been bundled in `inst/extdata`. Once that dataset is
added, the vignette can be upgraded to execute a small end-to-end simulation
during vignette testing.

The next likely vignette after this one is:

```text
Migrating a LANDIS-II Biomass Succession project to landisR
```

followed by a more technical vignette describing the canonical input format.
