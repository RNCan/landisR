# `landis_compare()` beta.2

This patch adds the first public LANDIS-II output comparison function.

It compares compact landisR snapshots against standard Biomass Succession TIFF
outputs:

- every species biomass raster;
- `TotalBiomass`;
- `AGE-MAX`.

Because LANDIS validation TIFFs may have no useful georeferencing and may be
vertically mirrored, the function does not trust geospatial metadata. It first
checks raster dimensions and then determines Y orientation from **all year-zero
species plus TotalBiomass**. One orientation must reproduce the initial state
exactly before later years are compared.

Outputs:

- `orientation_audit.csv`
- `comparison_summary.csv`
- `largest_discrepancies.csv` when differences exist

This is the transition from input-route validation to actual LANDIS-II output
equivalence testing.
