
imdb_cast <- function(id){
  url_base <- 'http://www.imdb.com/title/@id@/fullcredits?ref_=tt_cl_sm#cast'
  url_base %>% 
    gsub('@id@',id,.) %>% 
    read_html() %>% 
    html_nodes(css='#fullcredits_content .itemprop span') %>% 
    html_text()
}
#filmo-head-director

imdb_filmo <- function(id){
  url_base <- "http://www.imdb.com/name/@id@/"
  url_base %>% 
    gsub('@id@',id,.) %>% 
    read_html() %>% 
    html_nodes(css='.filmo-row') -> table
  
  
  map_table <- map(table,filmo_row)
  dt <- data.table(profession = map_chr(map_table,'profession'),
                   id = map_chr(map_table,'id'))
  return(dt)
}


filmo_row <- function(row){
  as.character(row) %>% 
    strsplit('=') %>% 
    unlist() %>% .[3] -> raw
  pos <- max(unlist(str_locate_all(raw,"\"")))
  letters_ <- unlist(strsplit(raw,''))[2:(pos-1)]
  hyphen <- which(letters_=='-')
  prof <- paste0(letters_[1:(hyphen-1)],collapse = '')
  id <- paste0(letters_[(hyphen+1):length(letters_)],collapse = '')
  return(list(profession=prof,id=id))
}

almodobar <- 'nm0000264'
jobs <- imdb_filmo(almodobar)
casts <- map(jobs[profession=='director',as.vector(id)],imdb_cast)

unlist(casts) %>% table() %>% sort(T) %>% head(10)