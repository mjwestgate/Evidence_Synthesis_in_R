list_to_df <- function(
  x, # a list to be converted
  cols = NULL #  an optional list of column names
){

  if(is.null(cols)){
    cols <- unique(unlist(lapply(x, names)))
  }

	x_list <- lapply(x, function(a, cols){
		result <- lapply(cols, function(b, lookup){
			if(any(names(lookup) == b)){
				lookup[[b]]
			}else{
        NA
      }
		},
    lookup = a)
		names(result) <- cols
		return(as.data.frame(result, stringsAsFactors=FALSE))
		},
  cols = cols)

	x_dframe <- data.frame(
		label = names(x_list),
		do.call(rbind, x_list),
		stringsAsFactors = FALSE)
	rownames(x_dframe) <- NULL

	return(x_dframe)
}