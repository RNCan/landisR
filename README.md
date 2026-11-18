# landisR

The core manages the landscape grid, shared CSR cohort state, simulation
clock, extensions, and persistence. A standalone core can build and
advance a landscape created with `landis_build_landscape()` or imported
with `landis_read()`.

Install `landisR.succession.biomass` for living biomass growth, Ward
dispersal, establishment, and post-fire recruitment. Existing biomass
project and simulation functions load the engine when they need it.

## Main API

```r
library(landisR)

landscape <- landis_read("D:/LANDIS/my_project")
succession <- landisR.succession.biomass::biomass_succession_read("D:/LANDIS/my_project")
sim <- landis_initialize(landscape, succession = succession, seed = 4357L)
run <- landis_sim(sim, steps = 3L)
```

To run another model, use the shared landscape with an external succession
extension in `landis_sim()`. For projects built from R tables, use
`landis_build_landscape()` for a shared landscape or `landis_build()` for a
Biomass Succession project.

## Validation

The beta scientific scope passed exact deterministic validation against
LANDIS-II and a 20-replicate stochastic ensemble validation. See
`inst/validation/` in the source package.
