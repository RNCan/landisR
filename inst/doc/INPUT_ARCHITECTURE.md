# Input architecture — beta.2-dev

LANDIS-II is an optional adapter, not a requirement.

```text
LANDIS-II project ---- landis_read() -----------\
R data.frames -------- landis_build() ------------> landisR_project
canonical inputs ----- landis_from_canonical() ---/
                                                |
                                                v
                                           landis_run()
                                                |
                                                v
                                      frozen beta engine
```

## Design rule

The frozen growth/Ward engine must never parse LANDIS-II files directly.

All sources are converted to the same canonical object. This keeps the engine
usable for experimental landscapes, synthetic designs, alternative disturbance
models, and future coupling with other models.

## Public entry points

### `landis_read()`
Compatibility route for an existing LANDIS-II project. The existing LANDIS
importer is reused and cached.

### `landis_build()`
LANDIS-independent route. Accepts R tables representing the grid, initial
cohorts, species, ecoregions, dynamic growth parameters, shade/light tables,
and related succession parameters.

### `landis_from_canonical()`
Advanced route for an already prepared canonical object or canonical directory.

### `landis_run()`
All three routes converge here. If the project exists only in memory,
`landis_run()` materializes a canonical cache automatically before calling the
frozen engine.

## Native format

The native format of landisR is the canonical object, not a LANDIS-II scenario.
LANDIS-II compatibility is one adapter around that format.
