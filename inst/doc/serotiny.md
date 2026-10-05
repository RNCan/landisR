# Fire-triggered serotiny in landisR

## Overview

`landisR` supports both facultative and strict serotiny. The distinction is
important because a species can either retain ordinary sexual recruitment
between fires or require fire for natural seed recruitment.

The fire workflow is explicit:

1. identify mature serotinous parent cohorts in the fire footprint;
2. preserve those seed sources from the pre-fire state;
3. apply the fire impact to the forest state;
4. release and disperse serotinous seed;
5. evaluate post-fire establishment using SEP and sufficient light;
6. create age-1 cohorts where establishment succeeds.

This ordering means that a stand-replacing fire can kill a mature parent
cohort while its closed cones still provide the seed source for post-fire
recruitment.

## Species traits

Two columns control serotiny:

| Field | Values | Meaning |
| --- | --- | --- |
| `serotiny_type` | `none`, `facultative`, `strict` | whether fire-triggered recruitment exists and whether ordinary natural sexual recruitment remains available |
| `serotiny_dispersal` | `none`, `local`, `kernel` | whether fire-released seed remains in the source cell or uses the Ward dispersal kernel |

The valid combinations are:

| Type | Dispersal | Behavior |
| --- | --- | --- |
| `none` | `none` | no serotinous recruitment |
| `facultative` | `local` | ordinary seeding plus local post-fire recruitment |
| `facultative` | `kernel` | ordinary seeding plus post-fire Ward dispersal |
| `strict` | `local` | natural sexual recruitment only after fire and only in the source cell |
| `strict` | `kernel` | natural sexual recruitment only after fire, followed by Ward dispersal |

### LANDIS-II import defaults

When an imported LANDIS-II species has
`post_fire_regeneration = "serotiny"`, and the landisR-specific fields are
not supplied, landisR uses:

```r
serotiny_type      = "facultative"
serotiny_dispersal = "local"
```

This retains LANDIS-II-style behavior by default.

## Strict serotiny

For a strictly serotinous species, the ordinary natural sexual-recruitment
path is disabled. Mature trees can therefore be present, establishment
conditions can be favorable, and seed dispersal parameters can be non-zero,
but no natural seed cohort is created until a structured fire event occurs.

Strict serotiny does not prevent an external model or management operation
from explicitly adding cohorts. It only controls the natural sexual
recruitment pathway.

A typical configuration for jack pine is:

```r
i <- project$canonical$species$species == "PINU.BAN"

project$canonical$species$serotiny_type[i] <- "strict"
project$canonical$species$serotiny_dispersal[i] <- "kernel"
```

## Applying a fire

`landis_fire()` represents a fire as a structured event. The function itself
does not assume a particular fire-mortality model. The post-fire state is
supplied through `update`.

For a severe stand-replacing fire:

```r
sim <- landis_initialize(project, seed = 4357L)

burned_cells <- c(101L, 102L, 103L)

sim <- landis_fire(
  sim,
  cells = burned_cells,
  update = landis_update(clear_cells = burned_cells),
  severity = 5
)
```

The critical point is that mature seed sources are captured before
`clear_cells` is applied.

`severity` is currently retained as fire-event metadata. It does not yet
change cone opening, seed release, or establishment probability.

## Local versus kernel dispersal

### `local`

With `serotiny_dispersal = "local"`, seed is available only in burned cells
that contained a mature source before the fire.

### `kernel`

With `serotiny_dispersal = "kernel"`, fire-released seed uses the same Ward
dispersal machinery as ordinary seeding. A destination cell does not need to
have burned.

The Ward implementation also handles the coarse-grid case where dispersal
distances are shorter than raster resolution. For example, on a 250 m grid,
a species with `EffectiveSeedDistance = 10 m` and
`MaxSeedDistance = 30 m` can still reach the first cardinal neighboring
cells. This prevents raster resolution from completely suppressing
between-cell dispersal.

## Seed arrival is not establishment

Ward arrival is only one component of recruitment. For a species and
destination cell, the effective recruitment probability is conceptually:

```text
final probability = seed arrival x SEP x sufficient light
```

Therefore a seed can disperse outside the burned footprint without
establishing there.

In the real 6est validation used during beta.3 development, jack-pine seed
arrival was essentially 1 in three unburned recipient cells. Their shade
class was 5 and their sufficient-light probability for jack pine was 0.
Their final establishment probability was therefore 0, and none recruited
across 100 stochastic repetitions.

By contrast, burned cells had shade class 0 and sufficient-light probability
1. Their observed recruitment frequencies across repeated fires closely
followed their SEP values.

## Continuing succession

A cohort created by `landis_fire()` is an ordinary living cohort after
recruitment. Subsequent calls to `landis_step()` grow and age it using the
normal Biomass Succession engine.

```r
sim <- landis_step(sim)
sim <- landis_step(sim)
sim <- landis_step(sim)
```

With a 10-year timestep, a fire-created age-1 cohort is represented in the
normal timestep age classes as succession proceeds. Targeted real-landscape
validation followed fire-created jack-pine cohorts through 30 years of
subsequent succession.

## Deterministic diagnostic mode

For spatial-support testing, use:

```r
sim <- landis_fire(
  sim,
  cells = burned_cells,
  update = landis_update(clear_cells = burned_cells),
  stochastic = FALSE
)
```

In this mode, every destination with a positive final establishment
probability recruits. This is useful for diagnostics but should not be
interpreted as a normal stochastic simulation.

## Reproducibility

Stochastic fire recruitment uses the simulation RNG state. The state is
advanced after recruitment and remains part of the interactive simulation
object. Repeating the same fire from the same simulation state and RNG state
therefore reproduces the same recruitment outcome.

## Current scope

The current implementation includes strict and facultative serotiny,
pre-fire source capture, local and Ward-kernel post-fire dispersal,
post-fire SEP and light constraints, and reproducible stochastic recruitment.

Fire severity is not yet a biological modifier of serotinous cone opening or
seed release. More detailed fire-severity effects can be added later without
changing the current separation between fire impact, seed release, dispersal,
and establishment.
