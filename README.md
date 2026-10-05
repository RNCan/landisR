# landisR

**Release target:** `v0.1.0-beta.2`

`landisR` is a standalone R/Rcpp implementation of the living-biomass
succession processes validated against LANDIS-II Biomass Succession.

LANDIS-II is optional. Projects can be created from:

1. LANDIS-II inputs with `landis_read()`;
2. native R tables with `landis_build()`;
3. canonical landisR inputs with `landis_from_canonical()`.

## Minimal workflow

```r
library(landisR)

project <- landis_read(
  "D:/LANDIS/my_project",
  scenario = "scenario.txt"
)

sim <- landis_run(
  project,
  duration = 30,
  seed = 4357,
  output_directory = "outputs/my_run"
)
```

## Documentation

After installation:

```r
system.file("doc", package = "landisR")
```

Main documents:

- `QUICK_START.md`
- `INPUTS.md`
- `INPUT_SCHEMA_VALIDATED_5KM.md`
- `FUNCTION_REFERENCE.md`
- `VALIDATION.md`

## Validated beta scope

- living biomass;
- Ward 2019 dispersal;
- stochastic establishment;
- explicit initial biomass;
- compact RDS snapshots/checkpoints;
- no dead pools;
- no internal parallelism.

The scientific engine is frozen for beta.2.

## Getting started vignette

After installation:

```r
vignette("getting-started", package = "landisR")
```

<!-- landisR-github-beta2 -->

## Beta.2 status

`landisR` is an R/Rcpp forest succession framework whose first validated
growth engine reproduces LANDIS-II Biomass Succession 5.2 living-biomass
dynamics. The package also provides a step-by-step interactive API and a
generic coupling contract for external models.

Core coupling workflow:

```r
sim <- landis_initialize(project, seed = 4357)
sim <- landis_step(sim)
forest <- landis_state(sim, representation = "cohorts")

# external model returns landis_update(...)
update <- external_model(forest)

sim <- landis_apply(sim, update)
sim <- landis_step(sim)
```

`landis_modifier()` is optional. Full disturbance or process extensions can
return `landis_update()` directly.

See the package vignettes for getting started and model coupling, and
`validation/VALIDATION.md` for the current validation summary.

<!-- landisR-positioning-begin -->

## What is landisR?

`landisR` is an R/Rcpp framework for spatial forest succession simulation
and model coupling. Its current validated growth engine closely follows the
living-biomass dynamics of LANDIS-II Biomass Succession 5.2, while exposing
a native R interface that makes interactions with other models and existing
R tools a central part of the architecture.

The package is not limited to reproducing a single LANDIS-II extension.
It separates simulation orchestration, forest state, growth engines, and
external processes so that disturbance, management, climate, ecological,
or other models can interact with a running simulation through a generic
state/update contract.

```r
sim <- landis_initialize(project, seed = 4357)
sim <- landis_step(sim)

forest <- landis_state(
  sim,
  representation = "cohorts"
)

# Any external model may return landis_update(...)
update <- external_model(forest)

sim <- landis_apply(sim, update)
sim <- landis_step(sim)
```

`landis_modifier()` is an optional convenience layer. Full disturbance or
process extensions can interact directly through `landis_update()` and
`landis_apply()`.

The architecture is designed so that additional growth engines can be added
in the future without making external coupling models depend on Biomass
Succession 5.2 internals.

<!-- landisR-positioning-end -->
