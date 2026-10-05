# Prototype API

## LANDIS-II project

```r
source("R/project_api.R")

project <- landis_read(
  "U:/path/to/LANDIS/scenario/folder",
  scenario = "scenario.txt"
)

result <- landis_run(
  project,
  duration = 60,
  seed = 4357,
  output_directory = "outputs/test_landis"
)
```

## Completely independent of LANDIS-II

```r
project <- landis_build(
  landscape = grid,
  species = species,
  species_parameters = species_parameters,
  ecoregions = ecoregions,
  ecoregion_parameters = ecoregion_parameters,
  dynamic = dynamic,
  initial_cohorts = cohorts,
  shade = shade,
  light = light,
  fire_reductions = fire_reductions,
  duration = 300,
  cell_length = 250,
  timestep = 10,
  initial_mode = "explicit_biomass",
  name = "experimental_landscape"
)

result <- landis_run(
  project,
  duration = 300,
  seed = 1234,
  output_directory = "outputs/experimental_landscape"
)
```

## Advanced canonical route

```r
project <- landis_from_canonical(
  "inputs_R/6est_complet_nodist",
  name = "6est"
)
```

The beta.2 API deliberately excludes dead pools.
