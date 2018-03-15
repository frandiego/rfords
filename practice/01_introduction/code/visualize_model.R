# clean R environment
rm(list = ls());gc()
# set working directory
setwd('practice/01_introduction/')
source('code/functions/transform_movies.R')

library(data.table)
library(stringr)
library(ggplot2)
library(gridExtra)
# MODEL VARIABLES ---------------------------------------------------------

y = 'vote_average'
x = c(
  'vote_count',
  'popularity',
  'original_language',
  'release_year',
  'budget',
  'revenue',
  'runtime',
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

# IMPORT DATA -------------------------------------------------------------

########## IMPORT DATA
# READ A CSV
df <- fread('data/movies.csv')

# SPLIT INTO TRAIN AND TEST
train <- df[!release_year%in%c(2018,2017)]
ttrain <- transform_movies(train)[vote_count>0]

test  <- df[release_year%in%c(2018,2017)]
ttest <- transform_movies(test)[vote_count>0]


# VISUALIZATION 1 ----------------------------------------------------------


y <- 'vote_average'
production_country <- c('production_us','production_gb','production_fr',
                        'production_ca','production_es','production_in')
ttrain[,c(y,production_country),with=F] %>%
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

#### INTERPRETATION
# A FILM FROM USA OR CANADA HAS LOWER RAING ON AVERAGE, SO THE FEATURE
# 'production_us' OR 'producttion_ca' IS GOING TO HAVE A NEGATIVE IMPACT IN THE
# FORECASTING MODEL FOR THE AVERAGE RAGIN.
# ON THE OTHER HAND, A FILM FROM GREAT BRETAIN WILL HAVE A  POSITIVE IMPACT


# VISUALIZATION 2 ----------------------------------------------------------


ttrain[,c(y,x),with=F] %>% map_lgl(~uniqueN(.)<20) %>% which() %>% names -> factors
factors <- setdiff(factors,production_country)

ttrain[,c(factors,y),with=F] %>% melt(id.vars = y) %>%
  .[,.(vote_average=mean(vote_average)),by=c('variable','value')] %>%
  .[,vote_average := vote_average - mean(ttrain$vote_average)] %>%
  .[,value := ifelse(is.na(as.numeric(value)),value,as.numeric(value))] %>%
  setorderv(c('variable','value')) %>%
  .[,sign := sign(vote_average)] %>%
  ggplot(aes(value,vote_average,fill=factor(sign))) +
  geom_bar(stat='identity') +
  facet_wrap(~variable,scales='free',ncol = 5) +
  theme_minimal()+
  theme(legend.position = 'none', plot.title = element_text(hjust = 0.5))+
  labs(title='contribution to the average rating')
#### INTERPRETATION
#' THE FACT OF BELONGING TO A COLLECTION HAS A NEGATIVE IMPACT
#' THE FACTO OF HAVING A HOMEPAGE AS A POSITIVE IMPACT,
#' THE AVERAGE RATING INCFREASE AS THE POPULARITY INCREASE
#' WE CAN ALSO SEE THAT THE VOTE_COUNT (THE NUMBER OF PEOPLE WHO HAS VOTE)
#' HAS A POSITIVE BIAS.

# VISUALIZATION 3 ----------------------------------------------------------

ttrain[,c(y,c('popularity','runtime','budget','revenue','vote_count')), with=F]%>%
  melt(id.vars = y) %>%
  ggplot(aes(value,vote_average)) +
  facet_wrap(~variable,scales = 'free',ncol=1) +
  geom_point(alpha=0.2)+
  geom_smooth()+
  ylim(c(4,NA))
#### INTERPRETATION
#' WE CAN SE A SMOOTH POSITIVE RELATION BETWEE RUNTIME AVERAGE RATING AND
#' BETWEEN VOUTE_COUNT AND AVERAGE RATING



# MODEL -------------------------------------------------------------------


# remove vote_count_hist (we take vote_count)
# same thing for vote_count_quant and popularity_quant
# same reaseon for budget_quant

formula <- as.formula(paste0(y,'~',paste0(x,collapse = '+')))
rf <- ranger::ranger(formula,ttrain,importance = 'impurity')
pr <- predict(rf,ttest)
rf$variable.importance %>% sort(T)

dt_res <- data.table(prediction = pr$predictions,
                     actual = ttest$vote_average,
                     vote_count = ttest$vote_count,
                     title = ttest$title)
dt_res[,res := actual-prediction]
sum_resid_2 = dt_res[,res**2] %>% sum
sum_resid_2/nrow(dt_res)
# PERFORMANCE VISUALIZATION
ggplot(dplyr::filter(dt_res,vote_count>0),aes(prediction,actual,size=vote_count)) +
  geom_point(alpha=0.7) +
  geom_smooth()+
  labs(title = 'performace \nthere is a smooth positive corrlation\nthe correlation is higher as the vote_count grows')+
  theme_minimal()+
  theme(plot.title = element_text(hjust=0.5), legend.position = 'bottom')
#' THE CORRELATION GROWS AS THE VOTE COUNT (SIZE OF THE CIRLCES) GROWS
#' THERE IS A SMOOTH CORRELATION BETWEEN PREDICTION AND ACTUAL VALUE OF AVERAGE RATING
#' WHE THE NUMBER OF POEPLE WHO HAS VOTE GROWS (SIZE OF CIRCLES) IT ALSO GROWS THE AVERAGE
#' RATING AND POSTIVE CORRELATION BETWEEN ACTUAL AND PREDICTED VALUE IS HIGHER

# ERROR VISUALIZATION
ggplot(dplyr::filter(dt_res,vote_count>0),aes(prediction,res)) +
  geom_point(aes(size=vote_count),alpha=0.5)+
  geom_line(alpha=0.7) +
  geom_hline(aes(yintercept=0),color='red')+
  labs(title = paste0('error \n the error is closer to 0 as the vote_count grows \nsum of square error: ',round(sum_resid_2)))+
  theme_minimal()+
  theme(plot.title = element_text(hjust=0.5), legend.position = 'bottom')

#' THE CORRELATION GROWS AS THE VOTE COUNT (SIZE OF THE CIRLCES) GROWS
#' DECREASE THE ERROR (NEARER TO 0 LINE)


#' AVOID OVERFITING BY REDUCING NUMBER OF VARIABLES
rf$variable.importance %>% sort(T) %>% head(15)

#' vote_count_hist is removed because we have chosen in the first option the vote_count
#' vote_count_quant is removed for the same reason
#' release_year is removed becuase this is a variable that split train and test

x_f <- c('vote_count','runtime','popularity','budget','revenue',
       'release_month','production_companies_number','spoken_languages')

formula <- as.formula(paste0(y,'~',paste0(x_f,collapse = '+')))
rf <- ranger::ranger(formula,ttrain,importance = 'impurity')
pr <- predict(rf,ttest)
rf$variable.importance %>% sort(T)


dt_res <- data.table(prediction = pr$predictions,
                     actual = ttest$vote_average,
                     vote_count = ttest$vote_count,
                     title = ttest$title,
                     year = ttest$release_year)
dt_res[,res := actual-prediction]
dt_res$res**2 %>% sum/nrow(dt_res)

# PERFORMANCE VISUALIZATION
ggplot(dplyr::filter(dt_res,vote_count>0),aes(prediction,actual,size=vote_count)) +
  geom_point(alpha=0.7) +
  geom_smooth()+
  labs(title = 'performace \nthere is a smooth positive corrlation\nthe correlation is higher as the vote_count grows')+
  theme_minimal()+
  theme(plot.title = element_text(hjust=0.5), legend.position = 'bottom')
# ERROR VISUALIZATION
ggplot(dplyr::filter(dt_res,vote_count>0),aes(prediction,res)) +
  geom_point(aes(size=vote_count),alpha=0.5)+
  geom_line(alpha=0.7) +
  geom_hline(aes(yintercept=0),color='red')+
  labs(title = paste0('error \n the error is closer to 0 as the vote_count grows \nsum of square error: ',round(sum_resid_2)))+
  theme_minimal()+
  theme(plot.title = element_text(hjust=0.5), legend.position = 'bottom')

#' AS WE CAN SEE, BY REDUDING THE NUMBER OF VARIABLES AND SELECTING THE MOST IMPORTANT ONES,
#' WE ARE IMPROVING THE MODEL BY REDUCING OVERFITTING
# https://www.geckoboard.com/learn/data-literacy/statistical-fallacies/overfitting/

# THE BEST FILMS ACCORDING TO PREDICTIONS

dev.off()
head(dt_res[order(-prediction)],10) %>% grid.table()
head(dt_res[year==2018][order(-prediction)],10) %>% grid.table()

