# Beta.2 autonomous consolidation

This patch completes the next development step without changing the frozen
scientific engine.

## What changes

- Adds a root-aware bootstrap: `landisR.R`
- Copies the already validated support modules from the historical development
  workspace into the beta directory
- Includes the LANDIS-II parser/importer as an optional adapter
- Keeps dead pools outside the beta scope
- Adds a 60-year exact source-independence simulation test

## What does not change

`R/large52.R` and `src/growth52.cpp` are not overwritten by the consolidation
script.

## Run order

From R:

```r
source("scripts/77_consolidate_beta2_autonomous.R")
source("scripts/78_validate_simulation_routes_beta2.R")
```

The first script makes the beta self-contained. The second runs the same 5 km
landscape by two independent input routes and requires all compact snapshots to
be `identical()`.
