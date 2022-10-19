# Setting up workspace - Libraries

install.packages("tidyverse", repos = "http://cran.us.r-project.org")
install.packages("DataExplorer", repos = "http://cran.us.r-project.org")
install.packages("janitor", repos = "http://cran.us.r-project.org")
install.packages("lubridate",repos = "http://cran.us.r-project.org")
install.packages("stringr", dep=TRUE)
install.packages("RCurl")
install.packages("rlist")
install.packages("dplyr")
install.packages("geosphere",repos = "http://cran.us.r-project.org")

library(XML)
library(RCurl)
library(rlist)
library(rvest)
library(dplyr)
library(plyr)
library(readr)
library(geosphere)

# Setting sessioninfo for English

Sys.setlocale("LC_TIME", "English")


# Downloading files into directory

data_url <- "https://divvy-tripdata.s3.amazonaws.com"

files <- read_html(data_url) |> html_elements('key') |> html_text() |> url_absolute(data_url)

# Selecting data from 2021

files_2021 <- grep("2021", files, value = TRUE)

# Setting up directory for the files 

dir <- setwd("E://Data Analysis/Cursera Capstone Project/Source Data")

# Iterate and download

lapply(files_2021, function(files_2021) download.file(files_2021, file.path(dir, basename(files_2021))))

list.files()

# Unpacking data

## get all the zip files as one vector

zipped_files <- list.files(path = dir, pattern = ".*zip", full.names = TRUE)

## setting directory for unpacking

unpackdir <-"E:/Data Analysis/Cursera Capstone Project/Source Data/Unzipped Files"

## unzipping files

ldply(.data = zipped_files, .fun = unzip, exdir = unpackdir)

# Merging all the files

bike_rides_2021 <- list.files(path = unpackdir,                   # Identify all csv files in folder
                       pattern = "*.csv", full.names = TRUE) %>% 
  lapply(read_csv) %>%                                            # Store all files in list
  bind_rows                                                       # Combine data sets into one data set

# Removing any Duplicates 

bike_rides_2021 <- distinct(bike_rides_2021, ride_id, .keep_all=TRUE)

# Applying alias to the data frame for easier transformaiton going forward

all_data <- bike_rides_2021

# Adding additional columns/calculations

all_data$date <- as.Date(all_data$started_at)
all_data$month <- format(as.Date(all_data$date), "%m")
all_data$day <- format(as.Date(all_data$date), "%d")
all_data$year <- format(as.Date(all_data$date), "%Y")
all_data$weekday <- format(as.Date(all_data$date), "%A")
all_data$start_hour = format(as.POSIXct(all_data$started_at), "%H:%M")
all_data$end_hour = format(as.POSIXct(all_data$ended_at), "%H:%M")
all_data$rent_duration <- as.numeric(difftime(all_data$ended_at, all_data$started_at, units = "mins"))
all_data$rent_distance <- distHaversine(cbind(all_data$start_lng, all_data$start_lat), cbind(all_data$end_lng, all_data$end_lat))

#Data Structure review

str(all_data)

# Testing data and Data Cleanup

## Testing Cases:
  ### 1.Rent Duration <0 or NA
  ### 2.Rent Distance <0 or NA
  ### 3.Start Station is blank
  ### 4.End Station is blank

sum(all_data$rent_duration <0 , na.rm=TRUE)
sum(all_data$rent_duration ==0 , na.rm=TRUE)
sum(all_data$rent_distance <0 , na.rm=TRUE)
sum(all_data$rent_distance ==0 , na.rm=TRUE)
sum(all_data$start_station_name ==0 , na.rm=TRUE)
sum(all_data$end_station_name ==0 , na.rm=TRUE)

all_data_test <- filter(all_data, rent_distance ==0)


## Exploratory Data Analysis (EDA)

Summary <- head(bike_rides_2021,10)

Detailed_Summary <- glimpse(bike_rides_2021)

DataExplorer::create_report(bike_rides_2021)





