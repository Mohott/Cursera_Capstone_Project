Cursera_Project_Bike_Rides
================
Jakub Mortka
2022-10-19

# Setting up workspace - Libraries

install.packages(“tidyverse”, repos = “<http://cran.us.r-project.org>”)
install.packages(“DataExplorer”, repos =
“<http://cran.us.r-project.org>”) install.packages(“janitor”, repos =
“<http://cran.us.r-project.org>”) install.packages(“lubridate”,repos =
“<http://cran.us.r-project.org>”) install.packages(“stringr”, dep=TRUE)
install.packages(“RCurl”) install.packages(“rlist”)
install.packages(“dplyr”) install.packages(“geosphere”,repos =
“<http://cran.us.r-project.org>”)

library(XML) library(RCurl) library(rlist) library(rvest) library(dplyr)
library(plyr) library(readr) library(geosphere)

# Setting sessioninfo for English

Sys.setlocale(“LC_TIME”, “English”)

# Downloading files into directory

data_url \<- “<https://divvy-tripdata.s3.amazonaws.com>”

files \<- read_html(data_url) \|\> html_elements(‘key’) \|\> html_text()
\|\> url_absolute(data_url)

# Selecting data from 2021

files_2021 \<- grep(“2021”, files, value = TRUE)

# Setting up directory for the files

dir \<- setwd(“E://Data Analysis/Cursera Capstone Project/Source Data”)

# Iterate and download

lapply(files_2021, function(files_2021) download.file(files_2021,
file.path(dir, basename(files_2021))))

list.files()

# Unpacking data

## get all the zip files as one vector

zipped_files \<- list.files(path = dir, pattern = “.\*zip”, full.names =
TRUE)

## setting directory for unpacking

unpackdir \<-“E:/Data Analysis/Cursera Capstone Project/Source
Data/Unzipped Files”

## unzipping files

ldply(.data = zipped_files, .fun = unzip, exdir = unpackdir)

# Merging all the files

bike_rides_2021 \<- list.files(path = unpackdir, \# Identify all csv
files in folder pattern = “\*.csv”, full.names = TRUE) %\>%
lapply(read_csv) %\>% \# Store all files in list bind_rows \# Combine
data sets into one data set

# Removing any Duplicates

bike_rides_2021 \<- distinct(bike_rides_2021, ride_id, .keep_all=TRUE)

# Applying alias to the data frame for easier transformaiton going forward

all_data \<- bike_rides_2021

# Adding additional columns/calculations

all_data![date \<- as.Date(all_data](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;date%20%3C-%20as.Date%28all_data "date <- as.Date(all_data")started_at)
all_data![month \<- format(as.Date(all_data](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;month%20%3C-%20format%28as.Date%28all_data "month <- format(as.Date(all_data")date),
“%m”)
all_data![day \<- format(as.Date(all_data](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;day%20%3C-%20format%28as.Date%28all_data "day <- format(as.Date(all_data")date),
“%d”)
all_data![year \<- format(as.Date(all_data](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;year%20%3C-%20format%28as.Date%28all_data "year <- format(as.Date(all_data")date),
“%Y”)
all_data![weekday \<- format(as.Date(all_data](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;weekday%20%3C-%20format%28as.Date%28all_data "weekday <- format(as.Date(all_data")date),
“%A”)
all_data![start_hour = format(as.POSIXct(all_data](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;start_hour%20%3D%20format%28as.POSIXct%28all_data "start_hour = format(as.POSIXct(all_data")started_at),
“%H:%M”)
all_data![end_hour = format(as.POSIXct(all_data](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;end_hour%20%3D%20format%28as.POSIXct%28all_data "end_hour = format(as.POSIXct(all_data")ended_at),
“%H:%M”)
all_data![rent_duration \<- as.numeric(difftime(all_data](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;rent_duration%20%3C-%20as.numeric%28difftime%28all_data "rent_duration <- as.numeric(difftime(all_data")ended_at,
all_data![started_at, units = "mins")) all_data](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;started_at%2C%20units%20%3D%20%22mins%22%29%29%20all_data "started_at, units = "mins")) all_data")rent_distance
\<-
distHaversine(cbind(all_data![start_lng, all_data](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;start_lng%2C%20all_data "start_lng, all_data")start_lat),
cbind(all_data![end_lng, all_data](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;end_lng%2C%20all_data "end_lng, all_data")end_lat))

\#Making sure new attributes are numeric

all_data![rent_duration \<- as.numeric(all_data](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;rent_duration%20%3C-%20as.numeric%28all_data "rent_duration <- as.numeric(all_data")rent_duration)
all_data![rent_distance \<- as.numeric(all_data](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;rent_distance%20%3C-%20as.numeric%28all_data "rent_distance <- as.numeric(all_data")rent_distance)

\#Data Structure review

str(data_filtered)

# Testing data and Data Cleanup

## Testing Cases:

\### 1.Rent Duration \<0 or 0 \### 2.Rent Distance \<0 or 0 \### 3.Start
Station is blank \### 4.End Station is blank

sum(all_data![rent_duration \<0 , na.rm=TRUE) sum(all_data](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;rent_duration%20%3C0%20%2C%20na.rm%3DTRUE%29%20sum%28all_data "rent_duration <0 , na.rm=TRUE) sum(all_data")rent_duration
==0 , na.rm=TRUE)
sum(all_data![rent_distance \>0 , na.rm=TRUE) sum(all_data](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;rent_distance%20%3E0%20%2C%20na.rm%3DTRUE%29%20sum%28all_data "rent_distance >0 , na.rm=TRUE) sum(all_data")rent_distance
==0 , na.rm=TRUE)
sum(is.na(all_data![start_station_name)) sum(is.na(all_data](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;start_station_name%29%29%20sum%28is.na%28all_data "start_station_name)) sum(is.na(all_data")end_station_name))

## Filtering out all data meeting testing criteria

data_filtered \<- all_data %\>% filter(rent_duration \>0) %\>%
filter(rent_distance \>0) %\>% filter(!is.na(start_station_name)) %\>%
filter(!is.na(end_station_name))

## Selecting only necessary columns

data_for_extract \<- data_filtered\[
,c(“ride_id”,“rideable_type”,“started_at”,“ended_at”,“start_station_name”,“start_station_id”,“end_station_name”,“end_station_id”,“member_casual”,“date”,“month”,“day”,“year”,“weekday”,“start_hour”,“end_hour”,“rent_duration”,“rent_distance”)\]

## Extract to CSV

write.csv(data_for_extract,“E://Data Analysis/Cursera Capstone
Project/2021_Bike_Data.csv”, row.names = FALSE)
