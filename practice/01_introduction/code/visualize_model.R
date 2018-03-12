# clean R environment
rm(list = ls());gc()
# set working directory
setwd('practice/01_introduction/')
source('code/functions/transform_movies.R')
library(ranger)
library(ggplot2)

########## IMPORT DATA
df <- fread('data/movies.csv')

train <- df[!release_year%in%c(2018)]
ttrain <- transform_movies(train)[vote_count>0]

test  <- df[release_year%in%c(2018)]
ttest <- transform_movies(test)[vote_count>0]

### VIZ 1
ttrain[,c('vote_average','production_us','production_gb','production_fr',
          'production_ca','production_es','production_in'),with=F] %>%
  melt(id.vars = 'vote_average') %>%
  .[,.(vote_average=mean(vote_average)),by=c('variable','value')] %>%
  setkeyv(.,c('variable','value')) %>%
  .[,diff(vote_average),by='variable'] %>%
  setnames(.,'V1','contribution') %>%
  .[,sign := sign(contribution)] %>%
  ggplot(aes(variable,contribution,fill=factor(sign))) +
  geom_bar(stat='identity') +
  theme_minimal(base_size = 18)+
  labs(title='contribution to the average rating')+
  theme(legend.position = 'none', axis.title.x = element_blank(),
        plot.title  = element_text(hjust = 0.5))


# MODEL -------------------------------------------------------------------

y = 'vote_average'
x = c(
  'vote_count',
  'popularity',
  'original_language',
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

# remove vote_count_hist (we take vote_count)
# same thing for vote_count_quant and popularity_quant
# same reaseon for budget_quant


rf <- ranger::ranger(formula,ttrain,importance = 'impurity')
pr <- predict(rf,ttest)
rf$variable.importance %>% sort(T)
plot(pr$predictions[ttest$vote_count>=20],
                    ttest[ttest$vote_count>=20]$vote_average)



