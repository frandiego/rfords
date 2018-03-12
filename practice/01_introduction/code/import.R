rm(list = ls());gc()
#linux
#setwd('/home/frandiego/projects/ier/01_introduction/')
#mac
setwd("/wrk/ier/exercises/01_introduction/")

# PARAMETERS
api_key = 'e1bde0d3a1ea6d4f51159a7c11832e72'
years = 2000:2018
top = 100
sort_by = 'popularity'
ascending = FALSE
ncores = 4
# HOW TO CREATE A TMDB API KEY
# https://www.themoviedb.org/talk/57c556b49251412158000b5b

# DEPENDENCIES ------------------------------------------------------------


# we need to have installed the libraries:
# libxml2-dev (Debian, Ubuntu, etc)
# libxml2-devel (Fedora, CentOS, RHEL)
# libxml2_dev (Solaris)

# libssl-dev (Debian, Ubuntu, etc)
# openssl-devel (Fedora, CentOS, RHEL)
# libssl_dev  (Solaris)
# openssl@1.1 (Max OSX)

# libcurl4-openssl-dev (Debian, Ubuntu, etc)
# libcurl-devel (Fedora, CentOS, RHEL)
# libcurl_dev (Solaris)





# PACKAGES ---------------------------------------------------------------
# install.packages("TMDb",dependencies = T)
# install.packages("data.table")
# install.packages('purrr')
# install.packages('doParallel')

packages <- c('TMDb','data.table','purrr','doParallel')
invisible(sapply(packages, function(x) library(x,character.only = T)))



# FUNCTIONS ---------------------------------------------------------------
paste_pipe <- function(str){return(paste(str,collapse = '|'))}
split_chunks <- function(x,n){
  return(split(x,ceiling(seq_along(x)/(length(x)/n))))
}

get_top_movies <- function(api_key,year,top = 50, sort_by='popularity',
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
  df <- df[order(get(sort_by),decreasing = !ascending )]
  df <- head(df,top)
  Sys.sleep(sleep)
  return(df)
}
get_top_movies_safe <- safely(get_top_movies)
get_movie_data <- function(api_key,id,sleep=0){
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
get_movie_data_safe <- safely(get_movie_data)



# CODE --------------------------------------------------------------------

# load movies information from a api called TMDb 
# https://www.themoviedb.org
# I have done using functional programming ('map' function from purrr package)
# and a self-made function  'get_top_movies' i can download the top 100 movies 
# by popularity per year. I store this data of a list of data frame (dfl)

########## MOVIES OVERALL DATA
dfl <- map(sort(unique(c(years))),
              ~get_top_movies_safe(api_key=api_key,
                             year=.,
                             top=top,
                             sort_by = sort_by,
                             ascending = ascending))
# but I have used a safe functino so I have to take results of the functions 
#and filter it
dfl <- map(dfl,'result')
dfl <- dfl[!map_lgl(dfl,is.null)]

# bind a list of data frames (dfl) in just one data frame (df)
# using the function 'rbindlist' from data.table
df <- rbindlist(dfl)

# calculate the release_year from the release_date with the function 
# 'year' from data.table package
# but release_date must be tranformed from character into Date format
df[,release_date := as.Date(release_date)]
df[,release_year := year(release_date)]

########## MOVIES DETAILED DATA
#### NOT ALL MOVIES HAVE DETAILED DATA
# there are 400 movies, so it will take 5 min (depends on the connection)
# again, I have used safely functions so I need to take the result of it
movies <- map(df$id,~get_movie_data_safe(api_key = api_key,id = .,sleep=1))


movies_result <- map(map_filter(movies,~!is.null(.['result'])),'result')

df_movies_detailed <- rbindlist(movies_result,fill = T)

df_movies_detailed$release_date %>% year %>% table
nrow(df_movies_detailed)


movies_result <- map(movies,'result')
movies_result <- movies_result[!map_lgl(movies_result,is.null)]
df_detailed <- rbindlist(movies_result,fill=T)

df_detailed <- df_detailed[,c('id',setdiff(colnames(df_detailed)
                                           ,colnames(df))),with=F]


# merge summary data (df) and datailed data (mv) and save it
df_movies <- merge(df,df_detailed,by='id')
fwrite(df_movies,'data/movies.csv')

df_movies$release_date %>% year %>% table