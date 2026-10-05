# Scientific and API validation

The beta.2 release was validated on Windows with R 4.6.0.

## Package gate

- Final local `R CMD check`: **Status: OK**.
- Public persistence/state/map APIs are present in the source package.

## Scientific engine

- Deterministic LANDIS-II comparisons passed for the validated cases.
- Stochastic validation supported equivalence for the tested cases.
- The Biomass Succession scientific kernel remained frozen during the beta.2 API/package freeze.

## Interactive and coupling API

- `landis_run()` supports automatic run persistence.
- `landis_load_run()` reloads a saved run descriptor.
- `landis_state()` supports saved `landisR_run` objects.
- `landis_map()` provides rapid mapping of biomass/state outputs.
- Stepwise execution preserves the simulation RNG state in the validated workflow.
- External updates can be applied between succession steps through the interactive API.

## Performance observation

- On one 6est benchmark used during development, the same simulation took about
  16 minutes with landisR versus 159 minutes with LANDIS-II, approximately a
  10x speed-up. This is a single benchmark, not a general performance guarantee.

Large validation datasets and simulation outputs are intentionally not committed.
