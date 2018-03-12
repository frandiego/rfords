str_format <- function(x,replacements = c('a','b'),prefix = '\\{',suffix = '\\}'){
  patterns <- paste0(prefix,seq_along(replacements),suffix)
  for(i in seq_along(patterns)){
    x <- gsub(pattern = patterns[i],replacement = replacements[i],x=x)
  }
  return(x)
}

paste_pipe <- function(str){
  return(paste(str,collapse = '|'))
  }
