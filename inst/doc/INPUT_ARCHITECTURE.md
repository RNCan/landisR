# Input architecture — beta.2-dev

LANDIS-II is an optional adapter, not a requirement.

Read the shared landscape with `landis_read()` and the separate Biomass
Succession configuration with `biomass_succession_read()`. Pass both to
`landis_initialize()` to create the initial forest state.

## Design rule

The frozen growth/Ward engine must never parse LANDIS-II files directly.

All sources are converted to the same canonical object. This keeps the engine
usable for experimental landscapes, synthetic designs, alternative disturbance
models, and future coupling with other models.

## Public entry points

### `landis_read()`
Imports the shared landscape from a LANDIS-II scenario. Its species and
ecoregion tables can be reused by different succession models.

### `landisR.succession.biomass::biomass_succession_read()`
Imports the Biomass Succession configuration and initial communities from
the same scenario. Pass the configuration and landscape to `landis_initialize()`.

### `landis_build()`
LANDIS-independent route. Accepts R tables representing the grid, initial
cohorts, species, ecoregions, dynamic growth parameters, shade/light tables,
and related succession parameters.

### `landis_from_canonical()`
Advanced route for an already prepared canonical object or canonical directory.

### `landis_run()`
The Biomass Succession project routes converge here. If the project exists only in memory,
`landis_run()` materializes a canonical cache automatically before calling the
frozen engine.

## Native format

The native format of landisR is the canonical object, not a LANDIS-II scenario.
LANDIS-II compatibility is one adapter around that format.
