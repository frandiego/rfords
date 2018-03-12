# clean R environment
rm(list = ls());gc()
# set working directory
setwd('practice/01_introduction/')

library(data.table)

########## IMPORT DATA
df <- fread('data/movies.csv')

########## TAKE TRAIN DATA
train <- df[release_year!=2018]
train$release_year %>% table


########## TIDY DATA
##### remove variables without information
variables_to_remove <- c()
## poster_path is the path where the jpg image of the movie's poster is saved
## (same thing for backdrop_path variable)
head(train$poster_path,1)
head(train$backdrop_path,1)
variables_to_remove <- c(variables_to_remove,'poster_path','backdrop_path')

# there is no movie with the varible video = TRUE
prop.table(table(train$video))
variables_to_remove <- c(variables_to_remove,'video')

# there is no movie with variabel adult = TRUE
train$adult %>% table %>% prop.table
variables_to_remove <- c(variables_to_remove,'adult')

# remove some variables
train[,c(unique(variables_to_remove)) := NULL]

# the variable status is so unbalance because there is just one film (Wind River)
# that is not realeased yet. So we can remove the row or the column, but I think
# this is a data-error so I prefer to remove the column.
train[,prop.table(table(status))]
train[status=='Planned',unique(title)]
train[,status := NULL]

########## TRANSFORM DATA
# There are some variables that do not provide information 'per se', for example
# homepage but it couldb be a good to know if the film has a homepage or not, so
# the variable homepage can be transform into a boolean (True/False) variable

############ create variable number of genres
# get a sample
x <- head(train$genre_ids,10)
print(x)
# table and example
i <- x[2]
# one way
i_split <- strsplit(i,'\\|')
i_split
i_split_unlist <- unlist(i_split)
i_split_unlist
n_genres <- length(i_split_unlist)
n_genres
# now, using pipes
i %>% strsplit('\\|') %>% unlist() %>% length()

# another smarter way
# why don't we count the number of pipes |
i_split <- strsplit(i,'')
i_split
i_split_unlist <- unlist(i_split)
i_split_unlist
pipes_bool <- grepl('\\|',i_split_unlist)
pipes_bool
n_pipes <- sum(pipes_bool)
n_pipes
n_genres <- n_pipes + 1

n_genres <- i %>% strsplit('') %>% unlist() %>% grepl('\\|',.) %>% sum %>% +1

# but we can be smarter using regex
n_pipes_l <- stringr::str_match_all(i,'\\|')
n_pipes_l
n_pipes_l <- map(n_pipes_l,nrow)
n_pipes_l
n_genres_l <- map(n_pipes_l,~.+1)
n_genres_l

# now using pipelines
i %>% str_match_all('\\|') %>% map(nrow) %>% map(~.+1)

# but stringr have vectorized functions (functions that returns a list of results)
# so we cann apply it to all the vector at once
map(x,~nrow(stringr::str_match_all(.,'\\|')[[1]])+1)
# now we want doubles instaead of a list, we can use
# a list or we can be a little bit smarter
map_dbl(x,~nrow(stringr::str_match_all(.,'\\|')[[1]])+1)

# and now we can apply it to all the dataset
map_dbl(train$genre_ids,~nrow(stringr::str_match_all(.,'\\|')[[1]])+1)

# why don't we do it the data.table way??
train[,genre_n := map_dbl(genre_ids,~nrow(stringr::str_match_all(.,'\\|')[[1]])+1)]

# that's all ?? no shit happens, speciallly cleaning data
# we have some films withou a genre id ('') or genre name ('')
# how can a movie have no genre?
# so, in this situation we can give genre_n = 0
# df[genre_ids=='',genre_n:=0]
# but I prefer to apply the rational and keep it beeing 1
# they are only four movies

############ main genre
# we can assume that the genre id in the first positin is the main one
train[,genre_main_id:= map_int(strsplit(genre_ids,'\\|'),~as.integer(unlist(.)[1]))]
# and why don't we take the name of the main id
train[,genre_main_name := map_chr(strsplit(genre_names,'\\|'),~unlist(.)[1])]
# now we have to check that there is just one genre_name for each genre_main_id
train[,unique(genre_main_name),by=genre_main_id][order(genre_main_id)]
train$genre_main_name %>% table()

############ number of languanges
# we are going to use the same code used to create genre_n
# so we must make a funciton for it
str_n_elements <- function(x,split){
  return(map_dbl(x,~nrow(str_match_all(.,split)[[1]])))
}

train[,spoken_languages_n :=
        str_n_elements(spoken_languages,'\\|')+1]

############ number of production_countries
train[,production_countries_n :=
        str_n_elements(production_countries,'\\|')+1]


############ released_month
train[,release_month := month(release_date)]

############ popularity
train$popularity %>% hist()
############ popularity
historize <- function(x,breaks='Sturges'){
  hist_  <- hist(x,plot = F,breaks = breaks)
  mids_ <- hist_$mids
  levels_ <- seq_along(h$breaks)
  ret_ <- map_int(x,~levels_[which.min(abs(.-mids_))])
  return(ret_)
}
quantilize <- function(x,n=4){
  q_ <- unname(quantile(x,seq(0,1,1/n)))
  levels_ <- seq_along(q_)
  ret_ <- map_int(x,~levels_[which.min(abs(.-q_))])
  return(ret_)
}

train[,popularity_hist := historize(popularity)]
train[,popularity_quant := quantilize(popularity)]

############ value count
train[,c('vote_count_hist','vote_count_quant'):=
        invoke_map(list(historize,quantilize),x=vote_count)]
############ budget
train[,c('budget_hist','budget_quant'):=
        invoke_map(list(historize,quantilize),x=budget)]
############ production country
# we are going to explore this variable
train[,production_countries] %>%
  map(~strsplit(.,'\\|')) %>%
  map(unlist) %>%
  unlist() %>%
  table() %>%
  sort() %>%
  plot()
# so we want to know is is from use, from gb, from fr, from ca, from de
# from es or from in
train[,production_us := grepl('US',production_countries)]
train[,production_gb := grepl('GB',production_countries)]
train[,production_fr := grepl('FR',production_countries)]
train[,production_ca := grepl('CA',production_countries)]
train[,production_es := grepl('ES',production_countries)]
train[,production_in := grepl('IN',production_countries)]

############ homepage
# the homepage by itself give no information
head(train$homepage,2)
# but if the film has a homepage it may mean that this film have
# online presence
train[,has_homepage := ifelse(homepage=='',0,1)]


# make factors for all variables with at least 25 categories
to_factor <- names(which(map_lgl(map_int(train,uniqueN),~.<=25)))
train[,c(to_factor) := map(.SD,as.factor),.SDcols = c(to_factor)]

### I have create a function called transform (transform_movies.R) to apply
### the same function to train and test
















