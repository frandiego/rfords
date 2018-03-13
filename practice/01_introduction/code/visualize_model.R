# clean R environment
rm(list = ls());gc()
# set working directory
setwd('practice/01_introduction/')
source('code/functions/transform_movies.R')

########## IMPORT DATA
df <- fread('data/movies.csv')

train <- df[!release_year%in%c(2018,2017)]
ttrain <- transform_movies(train)[vote_count>0]

test  <- df[release_year%in%c(2018,2017)]
ttest <- transform_movies(test)[vote_count>0]

### VIZ 1
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


### VIZ 2
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


ttrain[,c(y,x),with=F] %>% map_lgl(~uniqueN(.)<20) %>% which() %>% names -> factors
factors <- setdiff(factors,production_country)

### VIZ 3
ttrain[,c(factors,y),with=F] %>% melt(id.vars = y) %>%
  .[,.(vote_average=mean(vote_average)),by=c('variable','value')] %>%
  .[,vote_average := vote_average - mean(ttrain$vote_average)] %>%
  .[,sign := sign(vote_average)] %>%
  setkeyv(c('variable','value')) %>%
  ggplot(aes(value,vote_average,fill=factor(sign))) +
  geom_bar(stat='identity') +
  facet_wrap(~variable,scales='free',ncol = 5) +
  theme_minimal()+
  theme(legend.position = 'none', plot.title = element_text(hjust = 0.5))+
  labs(title='contribution to the average rating')

### VIZ 4
ttrain[,c(y,c('popularity','runtime','budget','revenue','vote_count')), with=F]%>%
  melt(id.vars = y) %>%
  ggplot(aes(value,vote_average)) +
  facet_wrap(~variable,scales = 'free',ncol=1) +
  geom_point(alpha=0.2)+
  geom_smooth()+
  ylim(c(4,NA))



# remove vote_count_hist (we take vote_count)
# same thing for vote_count_quant and popularity_quant
# same reaseon for budget_quant

formula <- as.formula(paste0(y,'~',paste0(x,collapse = '+')))
rf <- ranger::ranger(formula,ttrain,importance = 'impurity')
pr <- predict(rf,ttest)
rf$variable.importance %>% sort(T)

dt_res <- data.table(prediction = pr$predictions,
                     actual = ttest$vote_average,
                     vote_count = ttest$vote_count)
ggplot(dplyr::filter(dt_res,vote_count>0),aes(prediction,actual,size=vote_count)) +
  geom_point(alpha=0.7) +
  geom_smooth()+
  labs(title = 'performace')+
  theme_minimal()+
  theme(plot.title = element_text(hjust=0.5), legend.position = 'bottom')

