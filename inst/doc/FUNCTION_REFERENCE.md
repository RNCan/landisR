# landisR beta.2 — Function reference

The public API deliberately stays small. Internal functions beginning with
`bs52_` are implementation details and are not part of the supported user API.

## `landis_read()`

```r
landis_read(
  source_directory,
  scenario = "scenario.txt",
  cache_directory = NULL,
  prefer_cells_csv = TRUE,
  name = NULL
)
```

Reads a supported LANDIS-II project and converts it to a `landisR_project`.

**Use when:** a LANDIS-II scenario already exists and you want to run the same
succession inputs in `landisR`.

**Returns:** a `landisR_project`.

**Important:** this is an input adapter. It does not execute LANDIS-II.

---

## `landis_build()`

```r
landis_build(
  landscape,
  species,
  species_parameters,
  ecoregions,
  ecoregion_parameters,
  dynamic,
  initial_cohorts,
  shade,
  light,
  fire_reductions,
  duration,
  cell_length,
  timestep = 10L,
  seeding_algorithm = "Ward",
  spinup_cohorts = FALSE,
  spinup_mortality_fraction = 0.05,
  initial_mode = c("explicit_biomass", "age_spinup"),
  community_codes = NULL,
  name = "custom_project"
)
```

Creates a project directly from R objects. LANDIS-II files are not required.

**Use when:** the landscape or ecological inputs come from R, GIS processing,
another model, a synthetic experiment, or a database.

**Validated beta recommendation:** use `initial_mode = "explicit_biomass"`.
The age-spinup pathway is retained from development but has not yet passed the
same complete package-level external validation suite.

---

## `landis_from_canonical()`

```r
landis_from_canonical(
  x,
  name = "canonical_project"
)
```

Creates a project from either:

- a canonical landisR input directory; or
- an already prepared canonical R list.

This is the lowest-level supported input route.

---

## `landis_write_canonical()`

```r
landis_write_canonical(
  project,
  directory,
  overwrite = FALSE
)
```

Writes a `landisR_project` to the canonical directory structure.

This is useful for reproducibility and for caching R-native inputs before
long simulations.

---

## `landis_run()`

```r
landis_run(
  project,
  duration = NULL,
  seed = 4357L,
  output_directory,
  output_years = NULL,
  climate = list(name = "baseline", dynamic_file = NULL),
  dispersal = "ward",
  ward_variant = "ward2019",
  checkpoint_every = 20L,
  snapshot_compression = "gzip1",
  checkpoint_compression = "gzip1",
  cache_directory = NULL,
  rng_chunk_cells = 100000L
)
```

Runs the frozen beta succession engine.

### Important arguments

`duration`
: Number of simulated years. It cannot exceed the duration supported by the
project inputs.

`seed`
: Random seed for **landisR**. The same numeric seed in LANDIS-II does not imply
the same random stream across engines.

`output_years`
: Years for compact state snapshots. They must align with the succession
timestep and include year 0.

`climate$dynamic_file`
: Optional alternative canonical dynamic-parameter CSV. If `NULL`, the dynamic
table stored in the project is used.

`dispersal`
: The validated beta uses `"ward"`.

`ward_variant`
: The externally validated beta uses `"ward2019"`.

### Outputs

The run directory contains compact state snapshots, checkpoints, biomass
summaries and performance diagnostics. Native TIFF production is intentionally
not part of the simulation hot path.

---

## `landis_compare()`

```r
landis_compare(
  run,
  landis_outputs,
  project,
  years = NULL,
  orientation = c("auto", "direct", "mirror_y"),
  include_age_max = TRUE,
  output_directory = NULL,
  max_discrepancies = 1000L
)
```

Compares compact `landisR` snapshots with LANDIS-II Biomass Succession raster
outputs.

The comparison can include:

- species biomass;
- `TotalBiomass`;
- `AGE-MAX`.

`orientation = "auto"` uses the exact year-zero state to determine whether
LANDIS-II raster rows need vertical mirroring.

This function requires the optional package `terra`.
