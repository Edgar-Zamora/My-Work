# Load packages
library(googledrive)
library(googlesheets4)
library(tidyverse)
library(tidyverse)
library(polite)
library(janitor)
library(rvest)
library(lubridate)

# Get funs
source("get_data.R")

# Get data latest game day and check against date
latest_game_data <- get_game_data("SEA", 2022) |> 
  group_by(season, team) |> 
  filter(date == Sys.Date())
  

# read_sheet("1vBmH7cWlWmz9zVb49vSbp0WuRpEE830TwlVq2B7tfX0")
  


# Get data every night that is not old


# Append rows to googlesheets