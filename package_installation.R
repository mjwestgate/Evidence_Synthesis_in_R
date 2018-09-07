## check packages can be installed

# load required packages
library(devtools) # necessary for install_github
source("http://bioconductor.org/biocLite.R") # allow installation from bioconductor


# load current dataset
packages <- read.csv("./data/packages.csv",
  stringsAsFactors = FALSE)
packages <- packages[which(packages$screening_passed), ]


# check which packages are installed on the current device
installed_packages <- as.character(
  installed.packages()[,"Package"]
)
install_check <- packages$package_name %in% installed_packages
# packages$package_name[!install_check] # installed
missing_packages <- packages$package_name[!install_check] # not installed


# determine which repository each package is stored in
packages$repo <- NA
packages$repo[
  which(
    grepl("cran.r-project.org", packages$package_url)
  )] <- "CRAN"
packages$repo[
  which(
    grepl("github.com", packages$package_url)
  )] <- "GitHub"
packages$repo[
  which(
    grepl("bioconductor.org", packages$package_url)
  )] <- "Bioconductor"
# how many in each repo?
# sort(xtabs(~ packages$repo))


# install missing packages
invisible(lapply(missing_packages,
  function(a, data){
    row <- which(data$package_name == a)
    switch(data$repo[row],
      "CRAN" = {
        install.packages(a)
      },
      "GitHub" = {
        devtools::install_github(data$url[row])
      },
      "Bioconductor" = {
        biocLite(a)
      }
    )
  },
  data = packages
))


# re-run check to see whether all packages were installed
packages$installed <- packages$package_name %in% installed_packages
missing_packages <- packages$package_name[!packages$installed]