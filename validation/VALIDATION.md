# Scientific and API validation

The current beta was validated on Windows with R 4.6.0.

## Scientific engine

- Deterministic LANDIS-II comparison: 76 / 76 exact.
- Stochastic ensemble: stochastic equivalence supported.
- Biomass Succession scientific kernel frozen after validation.

## Interactive API

- `landis_run()` versus three successive `landis_step()` calls: exact.
- Interactive RNG state versus uninterrupted run: exact.
- Cohort export and unchanged re-feed: exact.
- Dynamic-input update preserves the current forest state.
- Targeted cohort intervention affects the target and preserves other cells.

## Generic coupling API

- Capability registry: pass.
- No-op modifier trajectory and RNG: exact.
- Direct external extension without `landis_modifier()`: exact.
- Missing capability requirements are rejected.
- State/context delivery to modifiers: pass.
- Dynamic update preserves current state and RNG.

The full development validation outputs and large reference inputs are not
committed to this repository.
