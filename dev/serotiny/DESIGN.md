# Serotiny development plan

Target: landisR 0.1.0-beta.3-dev

## Goals

1. Preserve LANDIS-II-compatible facultative serotiny.
2. Add strict serotiny: natural sexual recruitment is impossible without fire.
3. Add post-fire seed dispersal from serotinous parent cohorts.
4. Preserve a local-only mode for LANDIS-II-compatible behavior.
5. Use the pre-fire state to identify mature serotinous seed sources.
6. Keep planting and vegetative reproduction conceptually separate.

## Proposed species traits

- `serotiny_type`: `none`, `facultative`, `strict`.
- `serotiny_dispersal`: `local`, `kernel`.

Default compatibility rules:

- species with LANDIS-II `post_fire_regeneration = serotiny` default to
  `serotiny_type = facultative` and `serotiny_dispersal = local` unless
  explicitly overridden in landisR input.
- all other species default to `serotiny_type = none`.

## Intended event order

1. Receive a structured fire event.
2. Inspect PRE-FIRE cohorts on burned source cells.
3. Identify mature serotinous parent cohorts.
4. Create a transient post-fire seed-source field.
5. Apply fire mortality/state change.
6. For local mode, expose seeds only to the source cell.
7. For kernel mode, disperse seeds using the species dispersal kernel
   and EffectiveSeedDistance / MaxSeedDistance.
8. Apply establishment/light constraints at destination cells.
9. Create new age-1 cohorts.

## Strict serotiny rule

For `serotiny_type = strict`, the ordinary sexual recruitment pathway is
disabled. A new cohort can arise naturally only from a fire-triggered
serotinous seed-release event. Planting is not considered natural recruitment
and remains allowed.

## First validation cases

- strict + no fire -> zero natural recruitment
- strict + fire + mature source -> possible recruitment
- strict + fire + immature source -> no recruitment
- kernel + destination within dispersal distance -> possible recruitment
- kernel + destination beyond MaxSeedDistance -> impossible
- local mode -> only source-cell serotinous recruitment
- facultative + no fire -> ordinary LANDIS-II-like seeding still works
- identical seed/RNG state -> reproducible post-fire recruitment
