create_function_df <- function(pkg_names){

  # error avoidance
  if(class(pkg_names) != "character"){
    pkg_names <- as.character(pkg_names)
  }

  # run imprt for all packages
  pkg_list <- lapply(pkg_names, function(a){
    x <- list_to_df(
      get_pkg_docs(a),
      cols = help_tags()
    )
    colnames(x)[1] <- "function_name"
    return(x)
  })
  names(pkg_list) <- pkg_names

  n_list <- lapply(pkg_list, nrow)
  name_list <-lapply(names(n_list), function(a, n){
    rep(a, n[[a]])
  }, n = n_list)

  pkg_df <- data.frame(
    package_name = do.call(c, name_list),
    do.call(rbind, pkg_list),
    stringsAsFactors = FALSE
  )

}