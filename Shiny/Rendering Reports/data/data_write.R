# Load packages
library(tidyverse)
library(janitor)
library(rvest)
library(polite)
library(lubridate)
library(furrr)


# Function Arguments
## MLB Teams
teams <- c("ATL", "PHI", "NYM", "MIA", "WSN", "TBR", "NYY", "BOS",
           "TOR", "BAL", "MIL", "STL", "CIN", "CHC", "PIT", "CHW",
           "CLE", "DET", "MIN", "SFG", "SDP", "COL", "ARI", "HOU",
           'SEA', "OAK", "LAA", "TEX", "KCR", "LAD")


## Years (exclude COVID-19 Season)
years <- c(2012:2019, 2021)




# Writing data for all teams and years
source("data/data_script.R")



# parallel processing with {furrr}
crossed_df <- crossing(teams, years)

data <- future_map2_dfr(crossed_df$teams, crossed_df$years, mlb_team_schedule)


write_csv(sample_df, "data/sample_df.csv")
