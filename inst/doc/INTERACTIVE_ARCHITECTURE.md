# Interactive landisR architecture

## Goal

The public orchestration layer should allow a simulation to stop at every
succession timestep, expose its current forest state, accept compatible changes
from almost any external model, and continue from the modified state.

The validated Biomass Succession 5.2 engine remains frozen. The new API is a
layer around that engine.

```text
landisR_project
      |
      v
landis_initialize()
      |
      v
landisR_simulation (year t)
      |
      +---- landis_state() ----> external fire / harvest / insect /
      |                          climate / management / other model
      |                                      |
      |                                      v
      |                               landis_update()
      |                                      |
      +<----------- landis_apply() <----------+
      |
      v
landis_step()
      |
      v
landisR_simulation (year t + timestep)
```

## Public functions

```r
landis_growth_biomass52()
landis_initialize()
landis_step()
landis_state()
landis_update()
landis_apply()
```

`landis_run()` remains available as the simple production workflow. This
candidate API does not modify `landis_run()` yet.

## Common forest-state contract

External models should not manipulate the internal CSR state.

The portable cohort representation is:

```text
cell_id
row
col
ecoregion
species
age
biomass
```

For large landscapes, `landis_state(..., representation = "compact")` keeps the
native compressed representation and
`landis_state(..., representation = "biomass")` provides a cell-level wide
biomass table.

## Cohort interventions

A cohort update has replacement semantics for the cells present in `cohorts`.

```r
forest <- landis_state(
  sim,
  representation = "cohorts",
  cells = burned_cells
)

forest$biomass <- floor(
  forest$biomass * survival_fraction
)

sim <- landis_apply(
  sim,
  landis_update(
    cohorts = forest,
    clear_cells = burned_cells,
    metadata = list(
      source = "fire_model"
    )
  )
)
```

`clear_cells` is needed when a disturbance leaves a cell with no living cohort.

## Parameter and environmental updates

Any complete canonical component can be replaced between timesteps:

```r
sim <- landis_apply(
  sim,
  landis_update(
    dynamic = new_dynamic_rows,
    dynamic_mode = "merge"
  )
)
```

The broadest interface is a canonical modifier:

```r
sim <- landis_apply(
  sim,
  landis_update(
    canonical = function(x) {
      x$dynamic <- climate_model(x$dynamic)
      x$species_parameters <- new_species_parameters
      x
    }
  )
)
```

The modified canonical object is validated before the simulation is allowed to
continue.

## Compatibility rules in the first interactive API

The first implementation intentionally keeps a small set of structural
invariants while allowing ecological inputs to change.

Can change between timesteps:

- living cohort biomass;
- cohort presence/absence;
- cohort ages;
- dynamic SEP;
- dynamic maxANPP;
- dynamic maxBiomass;
- species parameters, while retaining the same species registry;
- ecoregion parameters;
- shade/light tables;
- ecoregion assignments of existing active cells;
- seed-dispersal parameters through an updated species table;
- any other canonical component accepted by the canonical validator.

Not yet allowed between timesteps:

- succession timestep;
- cell size;
- raster dimensions;
- the active-cell set;
- species registry/order.

Those restrictions are architectural, not claims that the operations are
impossible. They can be relaxed later with dedicated migration rules.

## Cache/context rebuilding

The first implementation favors correctness over micro-optimization.

When ecological/project inputs change, landisR:

1. validates the new canonical project;
2. rebuilds the ecological/spatial context and Ward tables;
3. preserves the current living forest state;
4. remaps the current forest to the new ecological context;
5. preserves the succession RNG state;
6. continues from the same simulation year.

Later versions can implement dependency-aware cache invalidation so that, for
example, changing SEP does not require rebuilding Ward geometry.

## RNG continuity

The interactive simulation stores the Biomass Succession RNG state explicitly.
`landis_step()` resumes from that state at every timestep.

External models should use their own RNG streams. A future coupling API should
formalize separate RNG streams for succession, fire, insects, harvest and other
components.

## Growth-engine architecture

The orchestration layer is deliberately not named after Biomass Succession.

Beta.2 currently implements only:

```r
landis_growth_biomass52()
```

The longer-term model is:

```text
landisR orchestration
      |
      +-- biomass52
      +-- future PnET-style engine
      +-- future custom engine
```

A future engine may keep additional engine-specific state, such as foliage,
roots, LAI, soil water or carbon pools. External disturbance models should rely
on the common forest-state contract whenever possible rather than on
engine-specific internals.

No PnET implementation is included in this candidate API.
