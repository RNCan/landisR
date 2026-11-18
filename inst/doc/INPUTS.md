# landisR beta.2 — Input specification

## General design

LANDIS-II is not the native data model of `landisR`. All input routes converge
to the same canonical project representation:

Import the shared LANDIS-II landscape and Biomass Succession configuration
with their respective readers, then combine them with `landis_initialize()`.
Biomass projects can also be built from R tables or opened from a canonical
input directory.

The scientific engine only consumes the canonical representation.

## R-native input route

`landis_build()` expects a collection of R `data.frame` objects plus scalar
simulation settings.

### `landscape`

This table has a strict schema:

| Column | Meaning |
|---|---|
| `cell_id` | Sequential cell identifier |
| `row` | Raster row in LANDIS row convention |
| `col` | Raster column |
| `ecoregion_map_code` | Numeric/map code of the ecoregion |
| `ecoregion` | Ecoregion name matching the ecoregion table |
| `active` | Whether the cell participates in succession |
| `community` | Initial-community map code; inactive cells must use 0 |

The grid must contain **every cell of the rectangular raster**, not only active
cells.

Cell indexing is:

```r
cell_id <- row + (col - 1L) * nrow
```

This column-major convention is part of the validated interface.

### `initial_cohorts`

For the validated `explicit_biomass` route:

| Column | Meaning |
|---|---|
| `map_code` | Initial-community code |
| `species` | Species identifier |
| `age` | Cohort age in years, >= 1 |
| `biomass` | Initial living biomass, >= 0 |

The tuple `(map_code, species, age)` must be unique.

Every active landscape cell must reference a valid community code.

### `dynamic`

Strict schema:

| Column | Meaning |
|---|---|
| `year` | First year to which the parameter row applies |
| `ecoregion` | Ecoregion identifier |
| `species` | Species identifier |
| `sep` | Species establishment probability parameter |
| `max_anpp` | Maximum ANPP |
| `max_biomass` | Maximum biomass |

The tuple `(year, ecoregion, species)` must be unique.

For the current beta validator, `sep` must be between 0 and 1. Climate tables
must cover every active ecoregion/species combination from the first applicable
year.

### `species`

Species-level ecological table used by succession and dispersal. It must follow
the validated canonical schema. Important fields used by the engine include the
species identifier, longevity/maturity information, shade tolerance and seed
dispersal distances.

Because the complete validated schema comes directly from the canonical
importer, run:

```r
source("scripts/89_generate_documentation_beta2.R")
```

to generate `docs/INPUT_SCHEMA_VALIDATED_5KM.md` from the actual validated
5 x 5 km project. That file lists the exact columns, R classes and example
values for every canonical table.

### `species_parameters`

Biomass Succession species parameters. The validated schema includes the
growth/mortality parameters needed by the living-biomass engine. Some
historical/dead-pool fields may remain in the canonical compatibility table even
though dead pools are outside beta scope.

Use the generated schema document for the exact current column set.

### `ecoregions`

At minimum, the canonical table maps:

- `map_code`;
- `ecoregion`;
- `active`.

Map codes and ecoregion names must agree with every row in `landscape`.

### `ecoregion_parameters`

Ecoregion-level Biomass Succession parameters. Exact columns are listed in the
generated schema.

### `shade`

Minimum-relative-biomass thresholds used to determine actual shade class.
Exact canonical layout is generated from the validated input set.

### `light`

Sufficient-light probabilities by species shade tolerance and actual shade
class. The engine expects probabilities for shade classes 0 through 5.

### `fire_reductions`

Retained in the canonical compatibility schema. Fire disturbance simulation is
not part of the frozen public beta scope yet, but the table remains required by
the current canonical representation.

### Scalar settings

`duration`
: Maximum supported simulation duration in years.

`cell_length`
: Cell side length in metres.

`timestep`
: Biomass Succession timestep. The external beta validation used 10 years.

`seeding_algorithm`
: Metadata corresponding to the imported succession configuration. The
validated simulation path uses Ward dispersal.

`community_codes`
: Optional vector of valid initial-community codes. If omitted,
`landis_build()` infers it from active landscape cells and the initial cohort
table.

## Canonical directory route

A canonical input directory has this structure:

```text
model_settings.csv

ecology/
  species.csv
  ecoregions.csv

succession/
  species_parameters.csv
  ecoregion_parameters.csv
  dynamic.csv
  shade.csv
  sufficient_light.csv
  fire_reductions.csv

initial/
  community_codes.csv
  cohorts.csv

landscape/
  grid.csv
```

`model_settings.csv` contains these keys:

```text
format
source_duration
cell_length
timestep
seeding_algorithm
spinup_cohorts
spinup_mortality_fraction
initial_mode
```

The current format identifier is:

```text
landisR52/canonical-inputs-v1
```

## LANDIS-II route

`landis_read()` reads the common landscape declared in `scenario.txt`.
It resolves the species file, ecoregion descriptions and ecoregion map
relative to the scenario file. Pass the landscape to the succession model
you intend to use.

`landisR.succession.biomass::biomass_succession_read()` reads the Biomass
Succession configuration and initial communities. Pass it together with
the landscape to `landis_initialize()`. The importer supports the LANDIS-II input structures used by the
validated 6est and 5 x 5 km projects.

## Current beta limitations

The scientifically validated public scope is intentionally narrower than every
development pathway present in the source code:

- explicit initial biomass is the recommended validated initialization mode;
- Ward 2019 is the externally validated dispersal path;
- dead biomass pools are not implemented in the public beta scope;
- disturbance extensions are not yet part of the frozen public beta;
- internal parallelism is intentionally absent;
- compact RDS state output is native; GeoTIFF export is a post-processing task.

These limitations should be expanded only after dedicated validation.
