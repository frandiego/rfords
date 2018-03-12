map_filter <- function(.x,.f){
  .x[map_lgl(.x,.f)]
}

map_filter_result <- function(.x,name='result'){
  map(map_filter(.x,~!is.null(.[[name]])),name)
}

