# CLEAN THE ENVIRONMENT AND COLLECT THE GARBAGE
rm(list = ls())
gc()

#### set working directory
dir_rfords <- '/wrk/ier/rfords/'
setwd(dir_rfords)

##### load packages
rfords::load_packages(c('data.table','readr','haven'))

##### current working directory
getwd()

##### change working directory
#' create a varaible with the dersired workind directory
#' it can be used the funciton file.path() that
pth_wd = file.path(getwd(),'practice/03_import/')
setwd(pth_wd)


# DOWNLOADING MOVIELENS DATASET -------------------------------------------
url <- "http://files.grouplens.org/datasets/movielens/"
dataset_small <- "ml-latest-small"
dataset_full <- "ml-latest"
data_folder <- "data"
archive_type <- ".zip"

# Choose dataset version
# if you want to cholse the samll one just change the variable name
dataset <- dataset_full
dataset_zip <- paste0(dataset, archive_type)

# create data_folder path if it does not exist
if(!dir.exists(data_folder)){
  dir.create(data_folder,recursive = T)
}
# download the data and unzip it

if (!file.exists(file.path(data_folder, dataset_zip))) {
  download.file(paste0(url, dataset_zip), file.path(data_folder, dataset_zip))
}
unzip(file.path(data_folder, dataset_zip), exdir = data_folder, overwrite = F)
# display the unzipped files
list.files(data_folder, recursive=T)
# remove zip file
file.remove(file.path(data_folder, dataset_zip))



# TIME TEST --------------------------------------------------------------------
#' loading a 0.497GB csv file
fln_movielens_ratings <- './data/ml-latest/ratings.csv'
system.time(dt <- read.csv(fln_movielens_ratings), gcFirst = T)
system.time(dt <- readr::read_csv(fln_movielens_ratings), gcFirst = T)
system.time(dt <- data.table::fread(fln_movielens_ratings), gcFirst = T)
#' writing a 0.497GB csv file
fln_export_test <- './data/movielens/ratings_export_test.csv'
system.time(write.csv(dt,fln_export_test))
system.time(readr::write_csv(dt,fln_export_test))
system.time(fwrite(dt,fln_export_test))
file.remove(fln_export_test)


#  READING TEXT FILES: DELIMITER-SEPARATED- VALUES  ----------------------------
setwd('./data/iris/')
# csv
read.csv('iris.csv')
read_csv('iris.csv')
fread('iris.csv')
# hsv
read.csv('iris.hsv',sep='^')
read_delim('iris.hsv',delim ='^')
fread('iris.hsv',sep ='^')
# psv
read.csv('iris.psv',sep='|')
read_delim('.iris.psv',delim ='|')
fread('iris.psv',sep ='|')
# tsv
read.csv('iris.tsv',sep='\t')
read_tsv('iris.tsv')
fread('iris.tsv',sep ='\t')
# READING SAS,SPSS AND STATA FILE FORMAT DATA   --------------------------------
# sas sas7bdat file
read_sas('iris.sas7bdat')
# sas xpt file
read_xpt('iris.xpt')
# stata dta file
read_dta('iris.dta')
# spss sav file
read_sav('iris.sav')


# EXPORTING DATA ----------------------------------------------------------

### WRITE
dt <- fread('iris.csv')
# create export folder to save data
if(!dir.exists('export')){
  dir.create('export')
}

# csv files
write.csv(dt,'export/iris.csv')
write_csv(dt,'export/iris.csv')
fwrite(dt,'export/iris.csv')
# stata dta file
write_dta(dt,'export/iris.dta')
# sas sas7bdat file
write_sas(dt,'export/iris.sas7bdat')
# sas xpt file
write_xpt(dt,'export/iris.xpt')
# spss sav file
write_sav(dt,'export/iris.sav')

#  remove files inside export folder and then remove export folder
# list files inside export folder
list.files('export')
# create filenames for each file inside export folder
file.path('export',list.files('export'))
# remove the files inside export folder
file.remove(file.path('export',list.files('export')))
# finaly remove export folder
file.remove('export')





