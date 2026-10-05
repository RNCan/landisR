# GitHub publication plan

Target organization: `RNCan`

Suggested repository name: `landisR`

The RNCan organization already hosts public scientific/software repositories,
including an R repository (`BioSimClient_R`). This preparation script creates a
clean repository tree from the checked package source rather than publishing the
entire development directory.

## Run locally

```r
setwd("U:/YBoulanger/LANDIS/LANDIS_R/landisR_0.1.0-beta.2-dev")

source("scripts/97_prepare_github_repository.R")
source("scripts/98_check_github_repository.R")
```

The repository candidate will be created at:

```text
U:/YBoulanger/LANDIS/LANDIS_R/landisR_0.1.0-beta.2-dev/github/landisR
```

No `git init`, commit, remote creation, or push is performed by these scripts.

Before a public release, confirm:

1. repository visibility;
2. final software license;
3. maintainer email in DESCRIPTION.

The intended first Git tag is:

```text
v0.1.0-beta.2
```
