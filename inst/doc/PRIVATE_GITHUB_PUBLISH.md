# Publication du dépôt privé RNCan/landisR

Cible :

```text
RNCan/landisR
```

Visibilité initiale :

```text
private
```

Mainteneur :

```text
Yan Boulanger
yan.boulanger@rncan-nrcan.gc.ca
ORCID 0000-0001-6181-8509
```

La licence demeure volontairement à confirmer avant toute publication publique.

## 1. Finaliser les métadonnées

```r
setwd("U:/YBoulanger/LANDIS/LANDIS_R/landisR_0.1.0-beta.2-dev")

source("scripts/99_finalize_github_metadata_private.R")
source("scripts/98_check_github_repository.R")
```

Le second script doit finir par :

```text
R CMD check : SUCCESS
```

## 2. Initialiser Git localement

Dans :

```text
U:/YBoulanger/LANDIS/LANDIS_R/landisR_0.1.0-beta.2-dev/github/landisR
```

```bash
git init
git branch -M main
git add .
git commit -m "Initial private beta of landisR"
```

## 3. Créer le dépôt privé

Avec GitHub CLI et les droits nécessaires dans RNCan :

```bash
gh repo create RNCan/landisR --private --source . --remote origin --push
```

Sinon, créer d'abord un dépôt privé vide `RNCan/landisR` dans GitHub puis :

```bash
git remote add origin https://github.com/RNCan/landisR.git
git push -u origin main
```

## 4. Tag

Le tag prévu demeure :

```text
v0.1.0-beta.2
```

Il est raisonnable d'attendre la confirmation de la licence avant de figer ce
tag et de créer une release GitHub.
