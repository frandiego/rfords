


# MISE EN PLACE ----------------------------------------------------------------
##### libraries
library(data.table)
library(dplyr)
##### vectors
v_lgl <- c(T,F)
v_int <- 1:10
v_dbl <- as.double(v_int)
v_chr <- c("double","quotes","are","preferred")


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

#' 6. To check that we have done everything ok, create a factor using week_days
#'    it must be an ordered vectors and use as labels the names of
#'    week_days_levels. Assign this factor to the variable fct_week_days_real
fct_week_days_real <- factor(week_days,
                             ordered = T,
                             levels = 1:7,
                             labels = c('Mon','Tue','Wed',
                                        'Thr','Fri','Sat','Sun'))

#' 7. Finally chechk that the names of fct_week_days has the same elements
#'    then fct_week_days_real coerced to be characters
#'    we can use the function all to evaluate if all element in a vector are T
all(as.character(fct_week_days_real) == names(fct_week_days))



# EXERCISE 4. BASIC MATRIX ALGEBRA ---------------------------------------------
#' 1.  create a (3,3) matrix that cointains the first 9 integers (1:9) filling
#'     data by columns, store this object in the variable max_x
#'     create a (3,3) matrix with the first 9 integers filing data by rows and
#'     store the object created in the varible max_y
#'     Finally print both of them
mat_x <- matrix(data=1:9, nrow = 3, ncol = 3, byrow = F)
mat_y <- matrix(data=1:9, nrow = 3, ncol = 3, byrow = T)
print(mat_x)
print(mat_y)

#' 2.  element-wise multiplication (mutiply the columns as if were scalars)
#'     spend 10 seconds to examine how it has been calculated
#'     store the resulted matrix in the variable mat_prod
mat_x * mat_y
mat_prod = mat_x * mat_y

#' 3. matrix multiplication (use the %*% operator to multiply two columns)
#'    spend 10 seconds to examine how it has been calculated
#'    remember 1x1 + 4x4 + 7x7 = 66
crossprod(mat_x,mat_y)
sum(mat_x[1,] * mat_y[1,]) == crossprod(mat_x,mat_y)[1,1]
sum(mat_x[1,] * mat_y[2,]) == crossprod(mat_x,mat_y)[2,1]
sum(mat_x[2,] * mat_y[1,]) == crossprod(mat_x,mat_y)[1,2]

#' 4. transpose one matrix and realise is the same than the other matrix
#'    (hint use the function t())
t(mat_y)
t(mat_y) == mat_x
all(t(mat_y)==mat_x)

#' 5. create a vector with the components of the principal diagonal of mat_x
#'    and realise that thi is equal to the components of the principal diagonal
#'    of mat_y. (hint use the function diag). store this vector in the variable
#'    diagonal
diagonal <- diag(mat_x)
all(diagonal == diag(mat_y))

#' 6. calcule the determinant of mat_prod, mat_x, mat_y
#'    when the determinant of a matrix is 0 it cannot be computed its inverse
#'    matrix. do you think you can create the inverse matrix of mat_y?
det(mat_x)
det(mat_y)
det(mat_prod)

#' 7. try to calculate the inverse matrix of mat_x and mat_y
#'    calculcate the inverse matrix of mat_prod and store it in mat_inv
#'    and proof that this inverse matrix is well calculated.

solve(mat_y)
solve(mat_x)
mat_inv <- solve(mat_prod)
all(mat_inv * mat_prod == mat_prod * mat_inv)



# EXERCISE 5. BASIC DATA.FRAME OPERATIONS --------------------------------------

#' 1. get iris dataset (the most famouse dataset ever, create by Ronald Fisher
#'    in 1936, it is constantly used to learn statistics, particularly,
#'    statistical classification and cluter analysis)
#'    So, grab the dataset and store it in a dataset called df
#'    (hint you can find it in datasets::iris)
df <- datasets::iris

#' 2.  convert it in a data.table and store it in a variable called dt
dt <- data.table(df)

#' 3.  change the name of the columns
#'     they have to he in lower cases and, nouns have to be singular
#'     and also replace dots by undeerscores
#'     (hint, you can use three functions names, colnames or setnames)
#'
new_names <- c('sepal_length','sepal_width','petal_length','petal_width','specie')
# this way is ok
colnames(dt) <- new_names
# but this on is better
colnames(dt) <- colnames(df) # just to learn a better way to change names
setnames(dt,old=colnames(dt),new=new_names)

#' 4 filter rows
#' Filter the data.table subseting rows where specie is setosa
#' (hint, use stackoverflow.com)

# data.frame syntax
dt[dt$specie == 'setosa']

# use subset function
subset(dt,subset = dt$specie == 'setosa')

# dplyr syntax (using filter funcion)
filter(dt,specie == 'setosa')

# data.table syntax (the easiest, best and most efficient)
dt[specie == 'setosa']


#' 5 filter rows and columns
#' Filter the data.table subseting rows where specie is setosa
#' and select sepal_length and petal_length columns
# (hint, use stackoverflow.com)

# data.frame syntax
dt[dt$specie == 'setosa',c('sepal_length','petal_length')]

# using sybset function
subset(dt,subset = dt$specie == 'setosa',
       select = c('sepal_length','petal_length'))

# dplyr syntax
filter(dt,specie == 'setosa') %>% select(c('sepal_length','petal_length'))

# data.table syntax
dt[specie == 'setosa',c('sepal_length','petal_length')]





