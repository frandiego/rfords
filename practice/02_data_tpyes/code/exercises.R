


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


# EXERCISE 1 TYPE OF VECTORS ---------------------------------------------------
# check the type of the vectors (variables starting with v_)
typeof(v_lgl)
typeof(v_int)
typeof(v_dbl)
typeof(v_chr)
#' typeof() function returns information of the internal typeof the object,
#' the name of its atomic class, or better said, the mode use to store data
#' In few words, it is the name of a lower-level object inherited from ours


# EXERCISE 2 CLASS OF VECTORS --------------------------------------------------
# check the class of the vectors (variables starting with v_)
class(v_lgl)
class(v_int)
class(v_dbl)
class(v_chr)

#' class() function returns name of the class from which our object
#' inherits its attributes. In few words, it is the name of the upper-level.

#' the name of the class object (upper-level object) ant the
#' name of the atomic class object (lower-level object) are often the same
#' but check it for the case of a double variable
class(v_lgl) == typeof(v_lgl)
class(v_int) == typeof(v_int)
class(v_dbl) == typeof(v_dbl)
class(v_chr) == typeof(v_chr)



# EXERCISE 3 UNDER THE HOOD OF A FACTOR ----------------------------------------
#' 1. Create a vector of 1000 elements, with integer numbers from 1 to 7
#'    (hint, you can do that making a sample with replacement using the
#'    sample function) and assign this vector to the varible week_days
#'    be sure that week_days in an integer vector
week_days <- as.integer(sample(x = 1:7, size = 1000, replace = T))

#' 2. Now create a vector of integer with the seven unique values of the
#'    week_days vector (hint, you can use colons notation) and assign this
#'    vector to the variable week_days_levels
week_days_levels <- sort(unique(week_days))

#' 3. Give names to the week_days_levels vector using the function names over
#'    the varible week_days_levels. You have create a seven element character
#'    vector with the names of weekdays (full names or abbreviations)
#'    be sure that 'Mon' is assign to 1, ... 'Sun' is assign to 7
names(week_days_levels) <- c('Mon','Tue','Wed','Thr','Fri','Sat','Sun')

#' 4. Now type week_days_levels[week_days] and voilà, you have a factor in front
#'    of you. Assign the resulting vector to the variable fct_week_days
fct_week_days <- week_days_levels[week_days]

#' 5. You can simulate the vector by typing names(fct_week_days)
#'    You can also simulate the levels of the vector by typing:
#'    names(week_days_levels[sort(unique(fct_week_days))])
names(fct_week_days)
names(week_days_levels[sort(unique(fct_week_days))])






