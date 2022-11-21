message("-------------------\n", format(Sys.time(), "%Y-%m-%dT%H%M%S"))
# not using gert for pull/push because of authentication problems in the cron job
system2("git", "pull")
piamPackages <- lucode2::piamPackages()

# all pik piam packages and their (optional) dependencies, no optional dependencies of dependencies though
packages <- unique(c(piamPackages,
                     unlist(tools::package_dependencies(piamPackages, which = "all", recursive = "strong"))))

# record global package environment, usually pik-piam packages are up-to-date and
# CRAN packages are updated only when required by pik-piam packages
renv::snapshot(lockfile = "conservative.renv.lock", packages = packages, prompt = FALSE)

# install packages into an renv, update all and create lockfile
invisible(callr::r(function(packages) {
  renv::load() # callr overwrites the .libPaths the renv .Rprofile has set, so load again
  renv::hydrate(packages = packages)
  renv::update()
  renv::snapshot(lockfile = "../eager.renv.lock", packages = packages)
  # remove obsolete packages/dependencies
  renv::restore(lockfile = "../eager.renv.lock", clean = TRUE)
}, list(packages), wd = "eager_renv", spinner = FALSE, show = TRUE))

today <- format(Sys.time(), "%Y-%m-%d")
gitStatus <- gert::git_add(c("conservative.renv.lock", "eager.renv.lock"))
if (any(grepl("^(conservative|eager)\\.renv\\.lock$", gitStatus[["file"]]))) {
  gert::git_commit(today)
  system2("git", "push")
}
gert::git_tag_create(today, "")
system2("git", c("push", "--tags"))
invisible(NULL) # prevent useless log message
