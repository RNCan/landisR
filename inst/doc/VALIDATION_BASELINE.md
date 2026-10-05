# Validation baseline for 0.1.0-beta.1

## Scientific equivalence already established

The development sequence established exact equivalence for the living-biomass engine
on focused and 5 × 5 km tests, including:

- initial cohort blocks;
- growth;
- maturity;
- Ward dispersal probabilities;
- recruitment;
- biomass snapshots.

The v3.10 and v3.11 Ward changes were benchmarked against the prior validated Ward
kernel with exact matrix identity.

## Frozen performance reference: 6est, baseline, 40 years

| Component | Seconds |
|---|---:|
| Growth | 52.28 |
| Ward | 32.85 |
| RNG | 6.37 |
| Rebuild | 3.60 |
| Core succession | 95.10 |
| Snapshots + checkpoints | 34.13 |
| Total wall clock | 160.30 |

The context cache reduced the total run from 227.67 s in v3.12 to 160.30 s in v3.13.

## Scope caveat

This beta reproduces the living-biomass succession functionality required by the
current research workflow. LANDIS-II dead woody debris and litter pools are not
implemented. Compact RDS snapshots are the native output; GeoTIFF export will be
a separate post-processing facility.
