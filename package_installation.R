## check packages can be installed

# load required packages
library(devtools) # necessary for install_github
source("http://bioconductor.org/biocLite.R") # allow installation from bioconductor


## PACKAGE LIST

# load current dataset
packages <- read.csv("./Evidence_Synthesis_in_R/data/packages.csv",
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


## INSTALLATION

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
installed_packages <- as.character(
  installed.packages()[,"Package"]
)
packages$installed <- packages$package_name %in% installed_packages
missing_packages <- packages$package_name[!packages$installed


## DOCUMENTATION

# create function to manually load all functions - useful when testing
load_package_files <- function(path){
  file_names <- list.files(path = path)
  file_names <- file_names[which(file_names != "sysdata.rda")]
  if(length(file_names) == 0){stop("No files found in current directory")}
  invisible(lapply(file_names,
    function(a, x){source(paste0(x, a))},
    x = path
    ))
}

# run and test
load_package_files("./Evidence_Synthesis_in_R/functions/")

# what functions are present in a single package?
revtools_data <- get_pkg_docs("revtools")




