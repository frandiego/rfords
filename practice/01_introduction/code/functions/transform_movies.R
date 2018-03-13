str_n_elements <- function(x,split){
  return(map_dbl(x,~nrow(str_match_all(.,split)[[1]])))
}

historize <- function(x,breaks='Sturges'){
  hist_  <- hist(x,plot = F,breaks = breaks)
  mids_ <- hist_$mids
  levels_ <- seq_along(hist_$breaks)
  ret_ <- map_int(x,~levels_[which.min(abs(.-mids_))])
  return(ret_)
}
quantilize <- function(x,n=4){
  q_ <- unname(quantile(x,seq(0,1,1/n)))
  levels_ <- seq_along(q_)
  ret_ <- map_int(x,~levels_[which.min(abs(.-q_))])
  return(ret_)
}

transform_movies <- function(df){

  df[,c('genre_n','spoken_languages_n','production_countries_n'):=
       map(.SD,~str_n_elements(x=.,split='\\|')),
     .SDcols = c('genre_ids','spoken_languages','production_countries')]

  df[,c('popularity_hist','vote_count_hist','budged_hist'):=
       map(.SD,historize),
     .SDcols = c('popularity','vote_count','budget')]

  df[,c('popularity_quant','vote_count_quant','budged_quant'):=
       map(.SD,quantilize),
     .SDcols = c('popularity','vote_count','budget')]

  df[,release_month := month(release_date)]

  prod_countries <- c('US','GB','FR','CA','ES','IN')
  for(cnt in prod_countries){
    df[,paste0('production_',tolower(cnt)) := grepl(cnt,production_countries)]
  }

  df[,has_homepage := ifelse(homepage=='',0,1)]
  # if runtime is na, replace with the mean
  df[is.na(runtime),runtime := mean(df$runtime,na.rm = T)]


  to_factor <-
    c(
      'video',
      'original_language',
      'adult',
      'release_year',
      'status',
      'belongs_to_collection',
      'production_companies_number',
      'popularity_hist',
      'vote_count_hist',
      'budged_hist',
      'popularity_quant',
      'vote_count_quant',
      'budged_quant',
      'release_month',
      'has_homepage',
      'production_us',
      'production_gb',
      'production_fr',
      'production_ca',
      'production_es',
      'production_in'
    )

  df[,c(to_factor) := map(.SD,as.factor),.SDcols = c(to_factor)]

  return(df)
}
