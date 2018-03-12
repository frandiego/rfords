# clean R environment
rm(list = ls());gc()

# set working directory
setwd('practice/01_introduction/')

#' we are going to download movies data from an API called TMDb
#' you must create you own APIKEY
#' some asked how here https://www.themoviedb.org/talk/57c556b49251412158000b5b

#########################   PARAMETERS
#' the api_key is like a password for the API to know who you are.
api_key = 'e1bde0d3a1ea6d4f51159a7c11832e72'
#' we want take data since 2000
years = 2000:2018
#' and we want to take to top 100 films by its popularity
top = 100
sort_by = 'popularity'
ascending = FALSE



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
library(data.table)
library(purrr)
library(TMDb)
# CODE --------------------------------------------------------------------

# load movies information from a api called TMDb
# https://www.themoviedb.org
# I have done using functional programming ('map' function from purrr package)
# and a self-made function  'get_top_movies' i can download the top 100 movies
# by popularity per year. I store this data of a list of data frame (dfl)

########## MOVIES SUMMARY DATA
# create a safe API acces.
tmdb_get_top_movies_safe <- safely(rfords::tmdb_get_top_movies)
dfl <- map(sort(unique(c(years))),
              ~tmdb_get_top_movies_safe(api_key=api_key,
                             year=.,
                             top=top,
                             sort_by = sort_by,
                             ascending = ascending),
           sleep=0.5)
# but I have used a safe function so I have to take results of the functions
# and filter it

dfl <- rfords::map_filter_result(dfl,'result')
# bind a list of data frames (dfl) in just one data frame (df)
# using the function 'rbindlist' from data.table
df <- rbindlist(dfl)
df$release_date %>% year %>% table

# calculate the release_year from the release_date with the function
# 'year' from data.table package
# but release_date must be tranformed from character into Date format
df[,release_date := as.Date(release_date)]
df[,release_year := year(release_date)]
fwrite(df,'data/movies_summary.csv')

########## MOVIES DETAILED DATA
#### NOT ALL MOVIES HAVE DETAILED DATA
# there are 400 movies, so it will take 5 min (depends on the connection)
# again, I have used safely functions so I need to take the result of it
tmdb_get_movie_data_safe <- safely(rfords::tmdb_get_movie_data)
movies <- map(df$id,~tmdb_get_movie_data_safe(api_key = api_key,id = .,sleep=0.5))
# again a have use a safe function so I need to take the result list and
# filter out errors.
movies_filtered <- rfords::map_filter_result(movies,'result')
# bind movies_filtered list in a data.frame
df_movies_detailed <- rbindlist(movies_filtered,fill = T)

# make some numbers and save the result
df_movies_detailed$release_date %>% year %>% table
nrow(df_movies_detailed)
fwrite(df_movies_detailed,'data/movies_detailed.csv')

# I just take the information which is not in the summary data.frame (df)
df_movies_detailed_filtered <- df_movies_detailed[,
                                c('id',setdiff(colnames(df_movies_detailed),
                                               colnames(df))),with=F]
# merge summary data (df) and datailed data (mv) and save it
df_movies <- merge(df,df_movies_detailed_filtered,by='id')
fwrite(df_movies,'data/movies.csv')

df_movies$release_date %>% year %>% table
