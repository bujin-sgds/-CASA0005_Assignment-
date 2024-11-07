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
library(here)

#------------------------------------------------------------------------------
# Part 1: Load the datasets 
#------------------------------------------------------------------------------

# Load the geographical data for the world countries
world_geo_data <- st_read(here::here('World_Countries_(Generalized)_9029012925078512962.geojson'))

# Load the Gender Inequality Index (GII) data using read_csv
gii_data <- read_csv(here::here('HDR23-24_Composite_indices_complete_time_series.csv'))

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
world_geo_data$iso3 <- countrycode(world_geo_data$ISO, origin = "iso2c", destination = "iso3c")

#------------------------------------------------------------------------------
# Part 3: Join the data and calculate the difference in GII
#------------------------------------------------------------------------------

# Join the data together using the ISO3 code
merged_data <- left_join(world_geo_data, country_gii_data, by = "iso3")

# Calculate the difference in GII between 2019 and 2010
merged_data$gii_difference <- merged_data$gii_2019 - merged_data$gii_2010

# Check the class of merged_data to ensure it's an sf object
class(merged_data)

#------------------------------------------------------------------------------
# Part 4: Visualize the GII data 
#------------------------------------------------------------------------------

# Check column names to ensure they are as expected
colnames(merged_data)

gii_2010_data <- merged_data %>%
  dplyr::select(gii_2010, geometry)
plot(gii_2010_data)

gii_2019_data <- merged_data %>%
  dplyr::select(gii_2019, geometry)
plot(gii_2019_data)

gii_diff_data <- merged_data %>%
  dplyr::select(gii_difference, geometry)
plot(gii_diff_data)
  
