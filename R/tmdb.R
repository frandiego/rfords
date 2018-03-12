tmdb_get_top_movies <- function(api_key,year,top = 50, sort_by='popularity',
                                ascending=FALSE,
                                sleep=0){
  sort_by_ <- paste0(sort_by,ifelse(ascending,'.asc','.desc'))

  first_page <- TMDb::discover_movie(api_key = api_key,
                                     page = 1,
                                     primary_release_year =  as.character(year),
                                     sort_by = sort_by_)

  n_movies_per_page <- nrow(first_page$results)
  n_pages <- top/n_movies_per_page
  dfl <- map(2:n_pages,~discover_movie(api_key = api_key,
                                       page = .,
                                       primary_release_year = as.character(year),
                                       sort_by = sort_by_))
  df <- rbindlist(map(dfl,'results'))
  df <- rbindlist(list(first_page$results,df))
  setorderv(df,'popularity',order=ifelse(ascending,1,-1))
  df <- head(df,top)
  Sys.sleep(sleep)
  return(df)
}
tmdb_get_movie_data <- function(api_key,id,sleep=0){
  movie <- TMDb::movie(api_key = api_key,id = id)
  columns_lgl <- map_lgl(movie,~typeof(.)!='list')
  row <- as.data.table(movie[columns_lgl])
  if(is.null(movie$belongs_to_collection)){
    row$belongs_to_collection = F
    row$collection_id = NA
    row$collection_name = NA
  }else{
    row$belongs_to_collection = T
    row$collection_id = movie$belongs_to_collection$id
    row$collection_name = movie$belongs_to_collection$name
  }
  row$genre_names <- paste0(movie$genres$name,collapse = '|')
  row$production_companies_ids <- paste_pipe(movie$production_companies$id)
  row$production_companies_number <- length(movie$production_companies$id)
  row$production_companies_name <- paste_pipe(movie$production_companies$name)
  row$production_countries <- paste_pipe(movie$production_countries$iso_3166_1)
  row$spoken_languages <- paste_pipe(movie$spoken_languages$iso_639_1)
  Sys.sleep(sleep)
  return(row)
}
