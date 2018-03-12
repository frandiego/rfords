map_filter <- function(.x,.f){
  .x[map_lgl(.x,.f)]
}
