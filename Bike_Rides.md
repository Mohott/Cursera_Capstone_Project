Cursera_Project_Bike_Rides
================
Jakub Mortka
2022-10-19

## Setting up workspace - Libraries

``` r
install.packages("tidyverse", repos = "http://cran.us.r-project.org")
install.packages("DataExplorer", repos = "http://cran.us.r-project.org")
install.packages("janitor", repos = "http://cran.us.r-project.org")
install.packages("lubridate",repos = "http://cran.us.r-project.org")
install.packages("stringr", dep=TRUE)
install.packages("RCurl")
install.packages("rlist")
install.packages("dplyr")
install.packages("geosphere",repos = "http://cran.us.r-project.org")
```

``` r
library(XML)
library(RCurl)
library(rlist)
library(rvest)
library(dplyr)
library(plyr)
library(readr)
```

## Data Download

### Downloading files into directory

``` r
data_url <- "https://divvy-tripdata.s3.amazonaws.com"

files <- read_html(data_url) |> html_elements('key') |> html_text() |> url_absolute(data_url)
```

### Selecting data from 2021

``` r
files_2021 <- grep("2021", files, value = TRUE)
```

### Iterate and download

``` r
lapply(files_2021, function(files_2021) download.file(files_2021, file.path(dir, basename(files_2021))))

list.files()
```

## Unpacking data

### get all the zip files as one vector

``` r
zipped_files <- list.files(path = dir, pattern = ".*zip", full.names = TRUE)
```

### unzipping files

``` r
ldply(.data = zipped_files, .fun = unzip, exdir = unpackdir)
```

## Data Prep

### Merging all the files

``` r
bike_rides_2021 <- list.files(path = unpackdir,                   ### Identify all csv files in folder
                       pattern = "*.csv", full.names = TRUE) %>% 
  lapply(read_csv) %>%                                            ### Store all files in list
  bind_rows                                                       ### Combine data sets into one data set
```

### Removing any Duplicates

``` r
bike_rides_2021 <- distinct(bike_rides_2021, ride_id, .keep_all=TRUE)
```

### Applying alias to the data frame for easier transformaiton going forward

``` r
all_data <- bike_rides_2021
```

### Adding additional columns/calculations

``` r
all_data$date <- as.Date(all_data$started_at)
all_data$month <- format(as.Date(all_data$date), "%m")
all_data$day <- format(as.Date(all_data$date), "%d")
all_data$year <- format(as.Date(all_data$date), "%Y")
all_data$weekday <- format(as.Date(all_data$date), "%A")
all_data$start_hour = format(as.POSIXct(all_data$started_at), "%H:%M")
all_data$end_hour = format(as.POSIXct(all_data$ended_at), "%H:%M")
all_data$rent_duration <- as.numeric(difftime(all_data$ended_at, all_data$started_at, units = "mins"))
all_data$rent_distance <- distHaversine(cbind(all_data$start_lng, all_data$start_lat), cbind(all_data$end_lng, all_data$end_lat))
```

### Making sure new attributes are numeric

``` r
all_data$rent_duration <- as.numeric(all_data$rent_duration)
all_data$rent_distance <- as.numeric(all_data$rent_distance)
```

### Data Structure review

``` r
str(data_filtered)
```

### Testing data and Data Cleanup

### Testing Cases:

-   1.Rent Duration \<0 or 0
-   2.Rent Distance \<0 or 0
-   3.Start Station is blank
-   4.End Station is blank

``` r
sum(all_data$rent_duration <0 , na.rm=TRUE) ### Test case 1
sum(all_data$rent_duration ==0 , na.rm=TRUE) ### Test case 1
sum(all_data$rent_distance >0 , na.rm=TRUE)  ### Test case 2
sum(all_data$rent_distance ==0 , na.rm=TRUE) ### Test case 2
sum(is.na(all_data$start_station_name)) ### Test case 4
sum(is.na(all_data$end_station_name))   ### Test case 4
```

### Filtering out all data meeting testing criteria

``` r
data_filtered <- all_data %>%
  filter(rent_duration >0) %>% 
  filter(rent_distance >0) %>%
  filter(!is.na(start_station_name)) %>%
  filter(!is.na(end_station_name)) 
```

### Selecting only necessary columns

``` r
data_for_extract <- data_filtered[ ,c("ride_id","rideable_type","started_at","ended_at","start_station_name","start_station_id","end_station_name","end_station_id","member_casual","date","month","day","year","weekday","start_hour","end_hour","rent_duration","rent_distance")]
```

### Extract to CSV

``` r
write.csv(data_for_extract,"E://Data Analysis/Cursera Capstone Project/2021_Bike_Data.csv", row.names = FALSE)
```
