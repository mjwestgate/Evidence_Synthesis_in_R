# code from C. Gray
get_pkg_docs <- function(pkg = "glue") {
  pkg_path <- list.files(
    system.file("help", package = pkg),
    pattern = "[.]rdb$",
    full.names = TRUE
  )
  data_raw <- tools:::fetchRdDB(tools::file_path_sans_ext(pkg_path))
  data_cleaned <- lapply(data_raw, help_file_to_list)
  return(data_cleaned)
}