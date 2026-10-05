# Stochastic ensemble validation

The deterministic no-recruitment test established exact LANDIS-II vs landisR
equivalence. The remaining baseline differences are therefore evaluated as a
stochastic process rather than as same-seed cell identity.

This validation uses 20 independent replicates:

- seed 4357;
- seeds 1001 through 1019.

`84_prepare_stochastic_ensemble_validation.R` runs the landisR ensemble and
creates matching LANDIS-II cases plus a batch launcher.

`85_analyse_stochastic_ensemble_validation.R` compares the two ensembles using:

- exact year-zero state;
- landscape mean biomass distributions across replicates;
- between-replicate variability;
- occupancy fractions;
- spatial ensemble-mean maps;
- spatial occupancy-probability maps;
- Kolmogorov-Smirnov diagnostics on run-level landscape means.

The analysis also reports practical diagnostic bands:

- absolute standardized mean difference <= 0.5;
- variance ratio between 0.5 and 2;
- mean occupancy difference <= 0.05;
- spatial ensemble-mean correlation >= 0.95.

These bands are explicitly diagnostic. They are not yet declared a formal
biological equivalence criterion. The detailed output should be reviewed before
freezing the stochastic-validation standard for the package.
