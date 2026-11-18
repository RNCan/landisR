# landisR beta.2 — Quick start

`landisR` manages the landscape and simulation. The examples below use the
Biomass Succession model supplied by `landisR.succession.biomass`. You can
prepare its inputs from a LANDIS-II scenario, an existing canonical cache,
or R tables.

## 1. Install

```r
install.packages(
  "landisR_0.1.0.9017.tar.gz",
  repos = NULL,
  type = "source"
)

install.packages(
  "landisR.succession.biomass_0.1.0.9008.tar.gz",
  repos = NULL,
  type = "source"
)

library(landisR)
```

A Windows source installation requires a working Rtools toolchain because the
package contains C++ code.

## 2. Route A — Existing LANDIS-II project

```r
landscape <- landis_read(
  "D:/LANDIS/my_project",
  scenario = "scenario.txt"
)
succession <- landisR.succession.biomass::biomass_succession_read("D:/LANDIS/my_project")
sim <- landis_initialize(landscape, succession = succession, seed = 4357L)
run <- landis_sim(sim, steps = 3L)
```

`landis_read()` and `biomass_succession_read()` import their inputs
independently. `landis_initialize()` creates the initial forest state.
To save the assembled inputs, call `landis_write_canonical(sim$project,
"outputs/import")`.

## 3. Route B — Existing canonical landisR inputs

```r
project <- landis_from_canonical(
  "inputs_R/my_project",
  name = "my_project"
)

sim <- landis_run(
  project,
  duration = 30,
  seed = 4357,
  output_directory = "outputs/my_project"
)
```

## 4. Route C — R-native inputs, no LANDIS-II files

```r
project <- landis_build(
  landscape = landscape,
  species = species,
  species_parameters = species_parameters,
  ecoregions = ecoregions,
  ecoregion_parameters = ecoregion_parameters,
  dynamic = dynamic,
  initial_cohorts = initial_cohorts,
  shade = shade,
  light = light,
  fire_reductions = fire_reductions,
  duration = 300,
  cell_length = 250,
  timestep = 10,
  initial_mode = "explicit_biomass",
  name = "experimental_landscape"
)

sim <- landis_run(
  project,
  duration = 300,
  seed = 1234,
  output_directory = "outputs/experimental_landscape"
)
```

This route is intended for synthetic landscapes, experimental designs, inputs
produced by other models, and future model coupling.

## 5. Compare with an existing LANDIS-II run

```r
comparison <- landis_compare(
  run = sim,
  landis_outputs = "D:/LANDIS/reference_run",
  project = project,
  years = c(0, 10, 20, 30)
)

print(comparison)
```

`terra` is required only for reading LANDIS-II TIFF outputs in
`landis_compare()`.

## Validated beta scope

The current beta is scientifically validated for:

- living biomass;
- 10-year Biomass Succession timestep in the validation suite;
- Ward seed dispersal, `ward2019`;
- stochastic establishment;
- explicit initial biomass;
- compact RDS snapshots/checkpoints;
- no internal parallelism.

Dead biomass pools are outside the beta scope.

The code contains some additional pathways retained from development, but they
should not be considered part of the validated public beta unless explicitly
identified as such in the documentation.
