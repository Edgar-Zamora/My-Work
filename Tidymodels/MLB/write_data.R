# Loading packages
library(polite)
library(rvest)
library(httr)
library(janitor)
library(tidyverse)
library(lubridate)
library(mlbstatsR)
library(furrr)


source("get_data.R")

# Year list

prev_seasons <- c(2000:2019)
current_season <- year(Sys.Date())


# Table: OUTCOMES
prev_outcomes <- map2_dfr("SEA", prev_seasons, get_outcome)
current_outcomes <- map2_dfr("SEA", current_season, get_outcome)

prev_outcomes |> 
  rbind(current_outcomes |> 
          filter(win_lose %in% c("W", "L"))) |> 
  write_csv("data/outcomes.csv")


# Table: TEAM_NAMES
team_names <- get_team_names()
write_csv(team_names, "data/team_names.csv")


# Table: GAME_DATA
prev_game_data <- map2_dfr("SEA", prev_seasons, get_game_data)
current_game_data <-  map2_dfr("SEA", current_season, get_game_data)

prev_game_data |> 
  rbind(current_game_data |> 
          filter(day_night %in% c("N", "D"))) |> 
  write_csv("data/game_data.csv")



# Table: PITCHER_DATA
prev_pitcher_data <- map2_dfr("SEA", prev_seasons, get_pitcher_data)
current_pitcher_data <- map2_dfr("SEA", current_season, get_pitcher_data)

prev_pitcher_data |> 
  rbind(current_pitcher_data |> 
          filter(away_home %in% c("away", "home"))) |> 
  write_csv("data/pitcher_data.csv")



# TABLE: STANDINGS
prev_standings <- map2_dfr("SEA", prev_seasons, get_standings)
current_standings <- map2_dfr("SEA", current_season, get_standings)
 
prev_standings |> 
  rbind(current_standings |> 
          filter(!is.na(wins))) |> 
  write_csv("data/standings.csv")



