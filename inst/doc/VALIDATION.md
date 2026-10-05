# landisR beta.2 — Scientific validation

## Input-route equivalence

Three independent input routes were validated:

1. canonical directory via `landis_from_canonical()`;
2. R-native tables via `landis_build()`;
3. original LANDIS-II inputs via `landis_read()`.

The three routes generated the same canonical scientific inputs and exact
matching landisR trajectories on the 5 x 5 km validation landscape.

## Deterministic external equivalence

Recruitment was neutralized by setting SEP to zero in LANDIS-II and landisR.

Across years 0, 10, 20 and 30, comparisons included:

- 17 species biomass rasters;
- TotalBiomass;
- AGE-MAX.

Result:

```text
76 / 76 EXACT
```

## Stochastic external equivalence

Twenty independent replicates were run in both engines.

Result summary:

```text
Initial state              380 / 380 EXACT
Species SMD                 51 / 51 within diagnostic band
Species occupancy           51 / 51 within diagnostic band
Spatial structure           51 / 51 within diagnostic band
Simple variance ratio       47 / 51 within 0.5–2
Brown-Forsythe p < 0.05      0 / 51
Brown-Forsythe BH < 0.05     0 / 51
TotalBiomass                PASS at all evaluated years
AGE-MAX                     EXACT
```

The four simple variance-ratio flags were not accompanied by significant
Brown-Forsythe tests.

The beta conclusion is therefore:

```text
STOCHASTIC EQUIVALENCE SUPPORTED
SCIENTIFIC BETA VALIDATION SUPPORTED
```

This wording is deliberate. The practical diagnostic bands are validation
criteria for this beta test suite, not a universal formal definition of
ecological-model equivalence.

## Package regression

The installable package was compiled and installed using the standard R package
DLL mechanism rather than runtime `sourceCpp()`.

A 10-year package smoke test reproduced the validated beta exactly:

```text
snapshot 000      EXACT
snapshot 010      EXACT
biomass summary   EXACT
```

Future changes to the scientific engine must rerun the deterministic and
stochastic validation suites.
