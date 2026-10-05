# Generic model coupling in landisR

## Design rule

`landisR` does not need to know whether an external process represents fire,
harvest, insects, competition, facilitation, climate, a machine-learning model,
or a full mechanistic extension.

The stable contract is:

```text
current landisR simulation
        |
        v
external process
        |
        v
landis_update()
        |
        v
landis_apply()
        |
        v
continue with landis_step()
```

`landis_modifier()` is optional. It is only a convenience wrapper for small or
medium R functions.

A full disturbance extension can ignore `landis_modifier()` completely.

## Capabilities

```r
caps <- landis_capabilities(sim)
caps
```

A process can declare requirements with stable string identifiers, for example:

```r
landis_supports(
  sim,
  c(
    "state.cohorts",
    "update.cohorts",
    "context.year"
  )
)
```

The first Biomass 5.2 capability registry includes state representations,
update channels, engine-specific inputs, and structural restrictions.

Capabilities describe the interface. They do not encode ecological meaning.

## Optional modifier wrapper

```r
interaction <- landis_modifier(
  name = "example_interaction",
  state = "biomass",
  requires = c(
    "state.biomass",
    "update.dynamic",
    "engine_input.sep"
  ),
  scope = "cell",
  fun = function(state, inputs, context) {

    dynamic <- inputs$dynamic

    # Arbitrary user science here.

    landis_update(
      dynamic = dynamic,
      dynamic_mode = "replace"
    )
  }
)

sim <- landis_apply(
  sim,
  interaction
)
```

The user function may request any subset of these named arguments:

```text
state
inputs
context
capabilities
simulation
```

A function accepting `...` receives all five.

Returning `NULL` means no change at this timestep. Returning anything other
than `NULL` or `landis_update()` is an error.

## Full extensions do not require modifiers

A perturbation package can expose its own API:

```r
fire_result <- landisFire::run(
  fire_model,
  forest = landis_state(
    sim,
    representation = "cohorts"
  ),
  weather = weather,
  year = sim$year
)

sim <- landis_apply(
  sim,
  fire_result
)
```

The only requirement is that `fire_result` is a valid `landisR_update`.

An extension can also provide a plain R function accepted directly by the
existing `landis_apply()` contract:

```r
fire_process <- function(simulation) {

  # Arbitrary external model.

  landis_update(
    cohorts = survivors,
    clear_cells = burned_out_cells
  )
}

sim <- landis_apply(
  sim,
  fire_process
)
```

This is why modifiers remain optional.

## No hard-coded biological process types

The core package does not define a biological ontology such as:

```text
fire
competition
facilitation
insects
harvest
```

Those labels belong to external scientific models.

Likewise, `SEP`, `maxANPP`, and `maxBiomass` are capabilities of the current
Biomass 5.2 engine, not universal landisR concepts.

A future growth engine can advertise a different capability set while keeping
the same external coupling contract.

## Structural restrictions in the current interactive beta

The current running-simulation contract still keeps these fixed:

```text
timestep
cell length
grid dimensions
active-cell set
species registry/order
```

These are explicit current limitations, not permanent design assumptions.
