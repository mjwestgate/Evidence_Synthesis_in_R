help_file_to_list <- function(x){
  result <- unlist(strsplit(
    as.character(x),
    "\\\\[[:alnum:]]+\\{"
  ))

  # remove extra content
  exclude_text <- c("\n", "\t", "{", "}")
  keep_rows <- which(!(result %in% exclude_text))
  result <- result[keep_rows]

  # id tags, using those given in:
  # https://cran.r-project.org/doc/manuals/R-exts.html#Documenting-functions
  # search for these in your script
  tags_check <- result %in% paste0("\\", help_tags())
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
  entry_dframe$tag <- sub("^\\\\", "", entry_dframe$tag) # leading slahes from tags
  entry_dframe$text <- clean_help_text(entry_dframe$text)

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


help_tags <- function(){
  c("name", "alias", "title", "description",
    "usage", "arguments", "details", "value",
    "references", "note", "author",
    "seealso", "examples", "keyword"
  )
}

clean_help_text <- function(x){
  x <- gsub("\\\\[[:alnum:]]+", "", x) # tags
  x <- gsub("\\n|\\t|\\{|\\}", "", x) # tabs, newline, brackets
  x <- gsub("\\s+", " ", x) # >1 space
  x <- gsub("^\\s|\\s$", "", x) # leading or trailing whitespace
  x <- gsub("\\s(?=[[:punct:]])", "", x, perl = TRUE) # spaces before punctuation
  return(x)
}