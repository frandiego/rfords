# CLEAN THE ENVIRONMENT AND COLLECT THE GARBAGE
rm(list = ls())
gc()


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


# EXERCISE 2 CLASS OF VECTORS --------------------------------------------------
# check the class of the vectors (variables starting with v_)


# EXERCISE 3 UNDER THE HOOD OF A FACTOR ----------------------------------------



#' 1. Create a vector of 1000 elements, with integer numbers from 1 to 7
#'    (hint, you can do that making a sample with replacement using the
#'    sample function) and assign this vector to the varible week_days
#'    be sure that week_days in an integer vector



#' 2. Now create a vector of integer with the seven unique values of the
#'    week_days vector (hint, you can use colons notation) and assign this
#'    vector to the variable week_days_levels

#' 3. Give names to the week_days_levels vector using the function names over
#'    the varible week_days_levels. You have create a seven element character
#'    vector with the names of weekdays (full names or abbreviations)
#'    be sure that 'Mon' is assign to 1, ... 'Sun' is assign to 7



#' 4. Now type week_days_levels[week_days] and voilà, you have a factor in front
#'    of you. Assign the resulting vector to the variable fct_week_days



#' 5. You can simulate the vector by typing names(fct_week_days)
#'    You can also simulate the levels of the vector by typing:
#'    names(week_days_levels[sort(unique(fct_week_days))])



#' 6. To check that we have done everything ok, create a factor using week_days
#'    it must be an ordered vectors and use as labels the names of
#'    week_days_levels. Assign this factor to the variable fct_week_days_real



#' 7. Finally chechk that the names of fct_week_days has the same elements
#'    then fct_week_days_real coerced to be characters
#'    we can use the function all to evaluate if all element in a vector are T



# EXERCISE 4. BASIC MATRIX ALGEBRA ---------------------------------------------



#' 1.  create a (3,3) matrix that cointains the first 9 integers (1:9) filling
#'     data by columns, store this object in the variable max_x
#'     create a (3,3) matrix with the first 9 integers filing data by rows and
#'     store the object created in the varible max_y
#'     Finally print both of them



#' 2.  element-wise multiplication (mutiply the columns as if were scalars)
#'     spend 10 seconds to examine how it has been calculated
#'     store the resulted matrix in the variable mat_prod



#' 3. matrix multiplication (use the %*% operator to multiply two columns)
#'    spend 10 seconds to examine how it has been calculated
#'    remember 1x1 + 4x4 + 7x7 = 66



#' 4. transpose one matrix and realise is the same than the other matrix
#'    (hint use the function t())



#' 5. create a vector with the components of the principal diagonal of mat_x
#'    and realise that thi is equal to the components of the principal diagonal
#'    of mat_y. (hint use the function diag). store this vector in the variable
#'    diagonal



#' 6. calcule the determinant of mat_prod, mat_x, mat_y
#'    when the determinant of a matrix is 0 it cannot be computed its inverse
#'    matrix. do you think you can create the inverse matrix of mat_y?



#' 7. try to calculate the inverse matrix of mat_x and mat_y
#'    calculcate the inverse matrix of mat_prod and store it in mat_inv
#'    and proof that this inverse matrix is well calculated.



# EXERCISE 5. BASIC DATA.FRAME OPERATIONS --------------------------------------



#' 1. get iris dataset (the most famouse dataset ever, create by Ronald Fisher
#'    in 1936, it is constantly used to learn statistics, particularly,
#'    statistical classification and cluter analysis)
#'    So, grab the dataset and store it in a dataset called df
#'    (hint you can find it in datasets::iris)



#' 2.  convert it in a data.table and store it in a variable called dt



#' 3.  change the name of the columns
#'     they have to he in lower cases and, nouns have to be singular
#'     and also replace dots by undeerscores
#'     (hint, you can use three functions names, colnames or setnames)
#'



#' 4 filter rows
#' Filter the data.table subseting rows where specie is setosa
#' (hint, use stackoverflow.com)



#' 5 filter rows and columns
#' Filter the data.table subseting rows where specie is setosa
#' and select sepal_length and petal_length columns
# (hint, use stackoverflow.com)





