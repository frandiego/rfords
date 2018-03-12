rm(list = ls());gc()
library(ranger)
#linux
#setwd('/home/frandiego/projects/ier/01_introduction/')
#mac
setwd("/wrk/ier/exercises/01_introduction/")
source('code/functions/transform_movies.R')
########## IMPORT DATA
df <- fread('data/movies.csv')

train <- df[!release_year%in%c(2017,2018)]
test  <- df[release_year%in%c(2017,2018)]
traint <- transform_movies(train)[vote_count>0]
testt <- transform_movies(test)[vote_count>0]
test$release_year


y = 'vote_average'
x = c(
  'vote_count',
  'video',
  'popularity',
  'original_language',
  'adult',
  'release_year',
  'budget',
  'revenue',
  'runtime',
  'status',
  'belongs_to_collection',
  'production_companies_number',
  'spoken_languages',
  'genre_n',
  'spoken_languages_n',
  'production_countries_n',
  'popularity_hist',
  'vote_count_hist',
  'budged_hist',
  'popularity_quant',
  'vote_count_quant',
  'budged_quant',
  'release_month',
  'production_us',
  'production_gb',
  'production_fr',
  'production_ca',
  'production_es',
  'production_in',
  'has_homepage'
)

formula <- as.formula(paste0(y,'~',paste0(x,collapse = '+')))

rf <- ranger::ranger(formula,traint,importance = 'impurity')
pr <- predict(rf,testt)
rf$variable.importance %>% sort(T)
plot(pr,testt$vote_average)



