# code to pre-process data of Crested Myna from ebird database


# loading libraries
library(auk)
library(dplyr)


# Crested Myna data file path
base_path <- "some_path/"
ac_path <- paste0(base_path, "ebd_cremyn_smp_relJul-2024.txt")

# Open file
ac_raw_data <- read_ebd(ac_path, unique = TRUE, rollup = TRUE)

# Inspecting dataset
colnames(ac_raw_data)

# Checking that all data corresponds to Crested Myna
unique(ac_raw_data$scientific_name)

# Countries
length(unique(ac_raw_data$country))
length(unique(ac_raw_data$country_code))
# the species was sightseeing in 24 countries

# Approved data
unique(ac_raw_data$approved) # All the data has being approved by eBird

# Select only relevant columns
ac_data <- ac_raw_data |>
  select("checklist_id", "latitude", "longitude", "country_code", "observation_date",
         "observation_count", "time_observations_started", "duration_minutes", 
         "country", "country_code", "state", "state_code", )

# Convert to dataframe
ac_df = as.data.frame(ac_data)

# Save as .csv
write.csv(x = ac_df, paste0(base_path, "crested_myna_records.csv"))
