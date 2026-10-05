# landisR

Development package corresponding to release label `0.1.0-beta.2`.

## Scope

- living biomass succession;
- Ward seed dispersal;
- stochastic establishment;
- compact RDS snapshots and checkpoints;
- LANDIS-II input adapter;
- R-native input construction;
- LANDIS-II output comparison;
- no dead biomass pools in the beta scope;
- no internal parallelism.

## Main API

```r
library(landisR)

project <- landis_read("D:/LANDIS/my_project")

sim <- landis_run(
  project,
  duration = 30,
  seed = 4357,
  output_directory = "outputs/my_run"
)
```

LANDIS-II is optional. R-native projects can be created with
`landis_build()`.

## Validation

The beta scientific scope passed exact deterministic validation against
LANDIS-II and a 20-replicate stochastic ensemble validation. See
`inst/validation/` in the source package.
