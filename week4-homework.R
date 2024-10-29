# Load all the necessary libraries
library(sf)
library(here)
library(terra)
library(dplyr)
library(ggplot2)
library(tmap)
library(tidyverse)
# install.packages('countrycode')
library(countrycode)

#------------------------------------------------------------------------------
# Part 1: Load the datasets 
#------------------------------------------------------------------------------

# Load the geographical data for the world countries
world_geo_data <- sf::st_read('World_Countries_(Generalized)_9029012925078512962.geojson')

# Load the Gender Inequality Index (GII) data using read_csv
gii_data <- read_csv('HDR23-24_Composite_indices_complete_time_series.csv')

#------------------------------------------------------------------------------
# Part 2: Tidy and filter the GII data
#------------------------------------------------------------------------------

# Define the columns of interest
columns_of_interest <- c('iso3', 'country', 'hdicode', 'gii_2010', 'gii_2019')

# Filter the data to keep only the columns we are interested in
gii_data_filtered <- gii_data %>% dplyr::select(all_of(columns_of_interest))

# Remove any rows with missing values
valid_gii_data <- gii_data_filtered %>% filter(!is.na(gii_2010)) %>% filter(!is.na(gii_2019))

# Remove rows that contain regional aggregations
country_gii_data <- valid_gii_data %>% filter(!is.na(hdicode))

# Use the countrycode package to get the iso3 code
world_geo_data["iso3"] <- countrycode(world_geo_data$ISO, origin = "iso2c", destination = "iso3c")

#------------------------------------------------------------------------------
# Part 3: Join the data and calculate the difference in GII
#------------------------------------------------------------------------------

# Join the data together using the ISO3 code
merged_data <- world_geo_data %>% left_join(country_gii_data, by = "iso3")
merged_data["gii_difference"] <- merged_data$gii_2019 - merged_data$gii_2010

#------------------------------------------------------------------------------
# Part 4: Visualize the GII data 
#------------------------------------------------------------------------------

# Create a simple plot to show the GII data for 2010
plot(merged_data %>% select(all_of(c("gii_2010", "geometry"))))

# Create a simple plot to show the GII data for 2019
plot(merged_data %>% select(all_of(c("gii_2019", "geometry"))))

# Create a simple plot to show the difference in GII data
plot(merged_data %>% select(all_of(c("gii_difference", "geometry"))))
