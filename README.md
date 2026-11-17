# landisR

The core manages the landscape grid, shared CSR cohort state, simulation
clock, extensions, and persistence. A standalone core can build and
advance a landscape created with `landis_build_landscape()`.

Install `landisR.succession.biomass` for living biomass growth, Ward
dispersal, establishment, and post-fire recruitment. Existing biomass
project and simulation functions load the engine when they need it.

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
