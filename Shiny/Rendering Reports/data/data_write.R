# Load packages
library(tidyverse)
library(janitor)
library(rvest)
library(polite)
library(lubridate)


# Function Arguments
## MLB Teams
teams <- c("ATL", "PHI", "NYM", "MIA", "WSN", "TBR", "NYY", "BOS",
           "TOR", "BAL", "MIL", "STL", "CIN", "CHC", "PIT", "CHW",
           "CLE", "DET", "MIN", "SFG", "SDP", "COL", "ARI", "HOU",
           'SEA', "OAK", "LAA", "TEX", "KCR", "LAD")


## Years (exclude COVID-19 Season)
years <- c(2010:2019, 2021)




# Writing data for all teams and years
source("data/data_script.R")


sea <- map2_df("SEA", years, mlb_team_schedule)
nyy <- map2_df("NYY", years, mlb_team_schedule)


sample_df <- rbind(sea, nyy)


write_csv(sample_df, "data/sample_df.csv")
