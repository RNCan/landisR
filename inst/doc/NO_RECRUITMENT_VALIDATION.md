# Deterministic no-recruitment validation

This pair of scripts isolates deterministic Biomass Succession behavior from
stochastic establishment.

`82_prepare_no_recruitment_validation.R` sets the canonical dynamic SEP column
to zero everywhere, runs landisR for 30 years, and creates an independent
LANDIS-II case with the same dynamic table and `RandomNumberSeed 4357`.

The original LANDIS inputs are never modified.

After running `RUN_LANDIS_NO_RECRUITMENT.bat`, execute
`83_compare_no_recruitment_validation.R`.

The decisive result is whether all 76 combinations of:

- 17 species,
- TotalBiomass,
- AGE-MAX,

across years 0, 10, 20, and 30 are exact.

If 76/76 are exact, the deterministic growth/mortality pathway is externally
validated against LANDIS-II and the discrepancies in the ordinary baseline can
be isolated to stochastic recruitment/RNG behavior.
