# Beta refactor roadmap

## Phase 1 — Freeze
- [x] Freeze living growth
- [x] Freeze Ward
- [x] Freeze compact outputs
- [x] Freeze context cache
- [x] Record checksums and benchmark

## Phase 2 — Package boundary
- [ ] Convert current sourced modules into package-internal functions
- [ ] Remove historical v3.x names from production API
- [ ] Add package-level options and validation
- [ ] Add deterministic seed handling tests

## Phase 3 — LANDIS-II input adapter
- [ ] Inventory exact 6est LANDIS-II input files
- [ ] Implement `landis_read()`
- [ ] Validate required extension/version assumptions
- [ ] Convert LANDIS-II files to canonical landisR object
- [ ] Fail explicitly on unsupported features

## Phase 4 — Comparison workflow
- [ ] Implement `landis_compare()`
- [ ] Compare total biomass, species biomass, AGE-MAX
- [ ] Add exact/absolute/relative difference summaries
- [ ] Add optional spatial comparison outputs

## Phase 5 — Reproducible example
- [ ] Include/licence-check 5 × 5 km example inputs
- [ ] Include compact reference outputs
- [ ] Add automated 60-year equivalence regression test

## Phase 6 — GitHub beta
- [ ] Clean repository
- [ ] Add README and usage vignette
- [ ] Add CI checks
- [ ] Tag `v0.1.0-beta.1`


## Architecture decision — beta.2-dev
- [x] LANDIS-II made optional by design
- [x] Define `landisR_project`
- [x] Prototype `landis_from_canonical()`
- [x] Prototype `landis_build()` for R-native inputs
- [x] Prototype `landis_read()` as LANDIS-II adapter
- [x] Prototype `landis_write_canonical()`
- [x] Prototype `landis_run()` converging all input routes on the frozen engine
- [ ] Validate the beta.2 round-trip on the 5 × 5 km dataset
- [ ] Integrate legacy LANDIS parser modules inside the package namespace
- [ ] Add `landis_compare()`
