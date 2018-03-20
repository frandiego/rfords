


# MISE EN PALCE ---------------------------------------------------------------

##### vectors
v_lgl <- c(T,F)
v_int <- 1:10
v_dbl <- as.double(v_int)
v_chr <- c("double","quotes","are","preferred")

##### factors
# ordered factor
f_mnt <- factor(c('Jan','Nov','Apr','Feb','May'),
                ordered = T,
                levels = month.abb)


# EXERCISE 1 ----------------------------------------------------------
# check the type of the vectors (variables starting with v_)
typeof(v_lgl)
typeof(v_int)
typeof(v_dbl)
typeof(v_chr)
#' typeof() function returns information of the internal typeof the object,
#' the name of its atomic class, or better said, the mode use to store data
#' In few words, it is the name of a lower-level object inherited from ours


# EXERCISE 2 ----------------------------------------------------------
# check the class of the vectors (variables starting with v_)
class(v_lgl)
class(v_int)
class(v_dbl)
class(v_chr)
#' class() function returns name of the class from which our object
#' inherits its attributes. In few words, it is the name of the upper-level.





