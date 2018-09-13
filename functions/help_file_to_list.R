help_file_to_list <- function(x){
  result <- unlist(strsplit(
    as.character(x),
    "\\\\[[:alnum:]]+\\{"
  ))

  # remove extra content
  exclude_text <- c("\n", "\t", "{", "}",
    "\\code", "\\item", "\\link"
  )
  keep_rows <- which(!(result %in% exclude_text))
  result <- result[keep_rows]

  # id tags
  tags_check <- grepl("^\\\\", result)
  tag_values <- cumsum(tags_check)
  entry_list <- split(result, tag_values)
  entry_list <- lapply(entry_list, function(a){
    n <- length(a)
    if(n == 1){
      return(c(a[1], NA))
    }
    if(n == 2){
      return(a)
    }
    if(n > 2){
      return(c(
        a[1],
        paste(a[c(2:length(a))], collapse = " ")
      ))
    }
  })

  # convert to data.frame
  entry_dframe <- as.data.frame(
    do.call(rbind, entry_list),
    stringsAsFactors = FALSE
  )
  colnames(entry_dframe) <- c("tag", "text")

  # clean up text
  entry_dframe$tag <- sub("^\\\\", "", entry_dframe$tag)
  entry_dframe$text <- gsub("\\n", "", entry_dframe$text)
  entry_dframe$text <- gsub("\\s+", " ", entry_dframe$text)

  # split by tag, collapse with "AND"
  # prevents multiple versions of same tag
  final_list <- split(entry_dframe$text, entry_dframe$tag)
  final_list <- lapply(final_list, function(a){
    if(length(a) > 1){
      return(
        paste(a, collapse = " AND ")
      )
    }else{
      return(a)
    }
  })

  # note this has been reordered by tag to be alphabetical
  return(
    final_list[unique(entry_dframe$tag)] # in correct order
  )
}