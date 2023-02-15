# lockfile-archive
Includes [renv.lock files](https://rstudio.github.io/renv/) to document the pik-piam R package environment at different points in time. Clone this repo and use e.g. `git checkout 2022-08-25` to get the lockfiles documenting the package environment on August 25 in 2022.

# How to update the lockfiles
The following is meant to be run regularly by a cronjob:
```
Rscript update_lockfiles.R
```
This will create `conservative.renv.lock`: a snapshot of all pik packages and their (optional) dependencies on the current system without renv. Then it will switch into an renv including all these packages, update all packages including from CRAN, and create a snapshot of that renv, which is called `eager.renv.lock`. Both lockfiles will be commited, a git tag with the current date is created, and pushed to this repo.
