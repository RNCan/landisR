# landisR 0.1.0.9014

- Show the current year and extension in a single console progress bar for
  coupled runs. Add the `progress` argument to `landis_sim()`,
  `landis_step()`, and `landis_run()`.

# landisR 0.1.0.9013

- Optionally reuse a binary canonical input cache through landis_from_canonical().

# landisR 0.1.0-beta.2

- First scientifically validated beta package.
- Three equivalent input routes: LANDIS-II, canonical, and R-native tables.
- Exact deterministic LANDIS-II equivalence with recruitment disabled.
- Stochastic equivalence supported by a 20-replicate ensemble validation.
- Frozen C++ kernel: v3.11-ward-interior-fastpath.
- Dead pools remain outside beta scope.
