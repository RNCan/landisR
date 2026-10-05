# Contributing

This repository contains a scientifically validated succession engine and a
generic model-coupling API.

Changes to the scientific Biomass Succession 5.2 engine require re-running
the deterministic and stochastic scientific validation gates.

Changes to the interactive or generic coupling API require re-running the
interactive and generic coupling validation gates.

Please keep external biological processes outside the core whenever they can
communicate through `landis_update()` and `landis_apply()`.

Do not commit large simulation outputs, local validation datasets, compiled
objects, credentials, tokens, or machine-specific paths.
