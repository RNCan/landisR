# Planned LANDIS-II compatibility layer

The public package should accept a LANDIS-II project directory directly and convert
all supported inputs to a single canonical representation before simulation.

Planned public workflow:

```r
library(landisR)

project <- landis_read("path/to/LANDIS/project")

result <- landis_run(
  project,
  years = 130,
  seed = 4357
)

comparison <- landis_compare(
  result,
  landis_outputs = "path/to/LANDIS/outputs"
)
```

## Design rule

The frozen biological engine must not parse LANDIS-II files directly.
Parsing belongs in an adapter layer:

LANDIS-II inputs -> parser/validator -> canonical object -> frozen engine

This separation lets the package add or improve input compatibility without changing
growth or Ward calculations.

## First compatibility target

The first beta adapter should support the exact input set used by the 6est and
5 × 5 km validation projects. Unsupported LANDIS-II extensions/options should fail
with a clear message rather than being silently ignored.
