# landisR beta.2 — Exact validated input schema

This file is generated directly from the validated 5 x 5 km canonical
reference used in the beta scientific-validation suite.

Reference: `U:/YBoulanger/LANDIS/LANDIS_R/SimulationTest/landisR52_validation_multigraines_13/landisR52_validation_multigraines/inputs_R/6est_5km_nofire`

The schemas below describe the exact tables accepted by the validated
canonical workflow. They are more authoritative than hand-written examples.

## `model_settings.csv`

Rows in validation reference: **8**

| Column | R class | Missing values | Example values |
|---|---|---:|---|
| `key` | `character` | 0 | format; source_duration; cell_length |
| `value` | `character` | 0 | landisR52/canonical-inputs-v1; 30; 250 |

## `ecology/species.csv`

Rows in validation reference: **17**

| Column | R class | Missing values | Example values |
|---|---|---:|---|
| `species` | `character` | 0 | ABIE.BAL; ACER.RUB; ACER.SAH |
| `longevity` | `integer` | 0 | 150; 300; 250 |
| `maturity` | `integer` | 0 | 30; 10; 40 |
| `shade_tolerance` | `integer` | 0 | 5; 3; 2 |
| `fire_tolerance` | `integer` | 0 | 1; 2; 3 |
| `effective_seed_distance` | `integer` | 0 | 25; 100; 200 |
| `max_seed_distance` | `integer` | 0 | 160; 200; 400 |
| `vegetative_probability` | `numeric` | 0 | 0; 0.5; 0.1 |
| `min_sprout_age` | `integer` | 0 | 0; 10; 20 |
| `max_sprout_age` | `integer` | 0 | 0; 100; 60 |
| `post_fire_regeneration` | `character` | 0 | none; resprout; serotiny |

## `ecology/ecoregions.csv`

Rows in validation reference: **230**

| Column | R class | Missing values | Example values |
|---|---|---:|---|
| `active` | `character` | 0 | no; yes |
| `map_code` | `integer` | 0 | 0; 1; 2 |
| `ecoregion` | `character` | 0 | none; 1; 2 |
| `description` | `character` | 0 | non active cells; No description |

## `succession/species_parameters.csv`

Rows in validation reference: **17**

| Column | R class | Missing values | Example values |
|---|---|---:|---|
| `species` | `character` | 0 | ABIE.BAL; ACER.RUB; ACER.SAH |
| `leaf_longevity` | `integer` | 0 | 3; 1; 2 |
| `woody_decay` | `numeric` | 0 | 0.062; 0.08; 0.07 |
| `mortality_shape` | `numeric` | 0 | 21.235625565052; 20.3266304135323; 20.3188307285309 |
| `growth_shape` | `numeric` | 0 | 0.193670943379402; 0.160220310091972; 0.186014413833618 |
| `leaf_lignin` | `numeric` | 0 | 0.2; 0.1 |

## `succession/ecoregion_parameters.csv`

Rows in validation reference: **229**

| Column | R class | Missing values | Example values |
|---|---|---:|---|
| `ecoregion` | `integer` | 0 | 1; 2; 3 |
| `aet` | `integer` | 0 | 600 |

## `succession/dynamic.csv`

Rows in validation reference: **3,893**

| Column | R class | Missing values | Example values |
|---|---|---:|---|
| `year` | `integer` | 0 | 0 |
| `ecoregion` | `integer` | 0 | 1; 2; 3 |
| `species` | `character` | 0 | ABIE.BAL; ACER.RUB; ACER.SAH |
| `sep` | `numeric` | 0 | 0.606; 0; 0.709 |
| `max_anpp` | `integer` | 0 | 387; 0; 399 |
| `max_biomass` | `integer` | 0 | 2843; 0; 3366 |

## `succession/shade.csv`

Rows in validation reference: **5**

| Column | R class | Missing values | Example values |
|---|---|---:|---|
| `shade` | `integer` | 0 | 1; 2; 3 |
| `1` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `2` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `3` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `4` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `5` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `6` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `7` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `8` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `9` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `10` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `11` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `12` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `13` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `14` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `15` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `16` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `17` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `18` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `19` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `20` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `21` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `22` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `23` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `24` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `25` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `26` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `27` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `28` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `29` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `30` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `31` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `32` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `33` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `34` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `35` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `36` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `37` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `38` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `39` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `40` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `41` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `42` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `43` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `44` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `45` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `46` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `47` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `48` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `49` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `50` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `57` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `58` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `64` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `65` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `66` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `67` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `68` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `69` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `70` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `72` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `74` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `75` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `76` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `77` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `78` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `79` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `80` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `81` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `82` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `83` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `84` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `85` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `86` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `87` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `92` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `95` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `96` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `97` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `98` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `100` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `101` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `102` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `103` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `104` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `105` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `106` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `107` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `108` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `109` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `110` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `111` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `113` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `114` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `115` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `116` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `117` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `123` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `131` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `132` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `136` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `138` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `139` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `140` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `141` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `143` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `144` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `151` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `155` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `156` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `157` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `161` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `165` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `174` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `194` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `206` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `207` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `208` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `209` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `210` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `216` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `219` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `223` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `233` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `237` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `241` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `248` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `250` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `252` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `253` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `260` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `270` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `271` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `272` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `273` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `275` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `276` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `277` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `278` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `279` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `280` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `282` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `286` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `287` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `295` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `301` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1001` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1002` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1003` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1004` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1005` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1006` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1007` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1008` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1009` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1010` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1011` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1012` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1013` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1014` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1017` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1018` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1019` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1020` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1021` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1023` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1024` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1027` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1028` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1029` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1030` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1031` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1032` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1034` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1036` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1039` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1040` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1041` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1042` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1043` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1044` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1048` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1050` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1064` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1065` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1066` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1068` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1069` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1075` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1076` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1077` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1078` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1080` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1083` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1084` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1085` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1086` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1087` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1092` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1095` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1096` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1103` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1104` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1106` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1107` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1110` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1111` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1113` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1114` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1115` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1116` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1117` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1126` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1136` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1139` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1141` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1144` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1156` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1174` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1207` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1208` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1209` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1210` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1216` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1219` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1271` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1272` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1273` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1280` | `numeric` | 0 | 0.2; 0.4; 0.5 |
| `1286` | `numeric` | 0 | 0.2; 0.4; 0.5 |

## `succession/sufficient_light.csv`

Rows in validation reference: **5**

| Column | R class | Missing values | Example values |
|---|---|---:|---|
| `shade_tolerance` | `integer` | 0 | 1; 2; 3 |
| `shade_0` | `integer` | 0 | 1 |
| `shade_1` | `numeric` | 0 | 0.5; 1 |
| `shade_2` | `numeric` | 0 | 0; 0.5; 1 |
| `shade_3` | `numeric` | 0 | 0; 0.5; 1 |
| `shade_4` | `numeric` | 0 | 0; 0.5; 1 |
| `shade_5` | `integer` | 0 | 0; 1 |

## `succession/fire_reductions.csv`

Rows in validation reference: **5**

| Column | R class | Missing values | Example values |
|---|---|---:|---|
| `severity` | `integer` | 0 | 1; 2; 3 |
| `wood_reduction` | `integer` | 0 | 0 |
| `litter_reduction` | `numeric` | 0 | 0.5; 0.75 |

## `initial/community_codes.csv`

Rows in validation reference: **177**

| Column | R class | Missing values | Example values |
|---|---|---:|---|
| `map_code` | `integer` | 0 | 0; 274; 6573 |

## `initial/cohorts.csv`

Rows in validation reference: **1,731**

| Column | R class | Missing values | Example values |
|---|---|---:|---|
| `map_code` | `integer` | 0 | 274; 6573; 7146 |
| `species` | `character` | 0 | ABIE.BAL; PICE.MAR; PICE.GLA |
| `age` | `integer` | 0 | 40; 70; 80 |
| `biomass` | `integer` | 0 | 635; 139; 190 |

## `landscape/grid.csv`

Rows in validation reference: **400**

| Column | R class | Missing values | Example values |
|---|---|---:|---|
| `cell_id` | `integer` | 0 | 1; 2; 3 |
| `row` | `integer` | 0 | 1; 2; 3 |
| `col` | `integer` | 0 | 1; 2; 3 |
| `ecoregion_map_code` | `integer` | 0 | 216; 0; 271 |
| `ecoregion` | `character` | 0 | 216; none; 271 |
| `active` | `logical` | 0 | TRUE; FALSE |
| `community` | `integer` | 0 | 67281; 63621; 33969 |

## Structural constraints enforced by the beta

- `landscape/grid.csv` is a complete rectangular grid.
- `cell_id` is sequential from 1 to `nrow * ncol`.
- `cell_id = row + (col - 1) * nrow`.
- inactive cells use `community = 0`.
- active cells reference known ecoregions and initial communities.
- `(map_code, species, age)` is unique in initial cohorts.
- `(year, ecoregion, species)` is unique in the dynamic table.
- the validated explicit-biomass route requires finite biomass >= 0.
- the validated dynamic table requires SEP between 0 and 1.

Generated by `scripts/89_generate_documentation_beta2.R`.
