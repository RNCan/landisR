# landisR beta.2 validation freeze

## Status

**Scientific validation supported for the beta scope.**

The validated scope is living-biomass Biomass Succession with Ward recruitment,
compact state outputs, no dead pools, and no internal parallelism.

## Input-route validation

Three independent input routes were shown to converge to the same canonical
representation and the same frozen engine:

- existing canonical inputs;
- R-native tables through `landis_build()`;
- original LANDIS-II inputs through `landis_read()`.

For the 5 x 5 km validation landscape, all routes produced exact matching
landisR trajectories when run with the same landisR RNG state.

## External deterministic validation against LANDIS-II

Recruitment was neutralized by setting SEP to zero in both engines.

Across years 0, 10, 20, and 30:

- 17 species biomass rasters;
- TotalBiomass;
- AGE-MAX.

Result: **76 / 76 exact comparisons.**

This externally validates the deterministic growth, mortality, aging,
competition, biomass accounting, and temporal stepping used by the beta engine.

## External stochastic validation against LANDIS-II

Twenty independent replicates were run in both engines.

The same numeric seed was not interpreted as a requirement for cell-by-cell RNG
identity across different software engines. Equivalence was evaluated at the
ensemble level.

Key results:

- initial state: 380 / 380 comparisons exact;
- 51 species x year biomass diagnostics after year 0;
- all 51 passed the standardized-mean-difference diagnostic;
- all 51 passed the occupancy diagnostic;
- all 51 passed the spatial-correlation diagnostic;
- 47 / 51 passed the simple variance-ratio band of 0.5 to 2;
- the four simple variance-ratio flags were the only practical-band failures;
- median absolute SMD: 0.008;
- maximum absolute SMD: 0.448;
- median ensemble spatial correlation: 0.9999;
- minimum ensemble spatial correlation: 0.9884.

TotalBiomass passed all practical diagnostics at years 10, 20, and 30:

| Year | Mean bias (%) | SMD | Spatial correlation |
| ---: | ---: | ---: | ---: |
| 10 | -0.0195 | -0.0957 | 0.99971 |
| 20 | -0.0340 | -0.1432 | 0.99931 |
| 30 | +0.0022 | +0.0106 | 0.99899 |

The four simple variance-ratio flags require interpretation as variance
diagnostics rather than as deterministic mismatches. Script
`86_finalize_beta2_validation.R` adds a Brown-Forsythe test and multiplicity
correction using the full 20-replicate run-level data.

## Change-control consequence

The scientific engine should remain frozen. A future engine change must rerun
the deterministic exact-validation suite and the stochastic ensemble suite.

The next development stage should focus on packaging, user-facing input
validation, documentation, comparison workflows, tests, and GitHub/CI rather
than further biological-engine tuning.
