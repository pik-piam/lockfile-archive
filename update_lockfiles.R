packagesUrl <- "https://pik-piam.r-universe.dev/src/contrib/PACKAGES"
pikPiamPackages <- sub("^Package: ", "", grep("^Package: ", readLines(packagesUrl), value = TRUE))

# all pik piam packages and their (optional) dependencies, no optional dependencies of dependencies though
packages <- unique(c(pikPiamPackages,
                     unlist(tools::package_dependencies(pikPiamPackages, which = "all", recursive = "strong"))))
packages <- setdiff(packages, "sr15data") # TODO remove when sr15data is gone or installable

# record global package environment, usually pik-piam packages are up-to-date and
# CRAN packages are updated only when required by pik-piam packages
renv::snapshot(lockfile = "conservative.renv.lock", packages = packages, prompt = FALSE)

# install packages into an renv, update all and create lockfile
callr::r(function(packages) {
  renv::load() # callr overwrites the .libPaths the renv .Rprofile has set, so load again
  renv::hydrate(packages = packages)
  # TODO remove "exclude" when these packages can be built
  renv::update(exclude = c("units", "stars"))
  renv::snapshot(lockfile = "../eager.renv.lock", packages = packages)
  # remove obsolete packages/dependencies
  renv::restore(lockfile = "../eager.renv.lock", clean = TRUE)
}, list(packages), wd = "eager_renv", spinner = FALSE, show = TRUE)

today <- format(Sys.time(), "%Y-%m-%d")
addedFiles <- gert::git_add(c("conservative.renv.lock", "eager.renv.lock"))
if (nrow(addedFiles) > 0) {
  gert::git_commit(today)
  gert::git_push()
}
gert::git_tag_create(today, "")
gert::git_tag_push(today)
