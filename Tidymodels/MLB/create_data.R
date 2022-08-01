# Load packages
library(tidyverse)

# Load data
# Joining tables to create data that will be used to model
mlb_data <- list.files("data", full.names = T) |> 
  map(read_csv) |> 
  set_names(list.files("data"))


# Getting features and making new features that I think are relevant in trying to predict
# attendance to a Seattle Mariners game

outcomes <- mlb_data$outcomes.csv |> 
  left_join(mlb_data$team_names.csv |> 
              select(-c(contains("color"), full_team_name)), by = c("opp" = "team_abb")) |> 
  mutate(same_league = case_when(league_name == "AL" ~ 1,
                                 TRUE ~ 0),
         same_division = case_when(division == "AL West" ~ 1,
                                   TRUE ~ 0)) |> 
  select(gm_number, team, season, won_prev_game, same_league, same_division, opp, series_won)


game_data <- mlb_data$game_data.csv |> 
  mutate(openning_week = case_when(date <= date[gm_number = 1] + weeks(1) ~ 1,
                                   TRUE ~ 0),
         weekday = factor(weekday, levels = c("Monday", "Tuesday", "Wednesday",
                                              "Thursday", 'Friday', "Saturday",
                                              "Sunday"))) |> 
  select(gm_number, season, team, date, month, day, weekday, day_night, attendance, away_home,
         openning_week)


standings <- mlb_data$standings.csv |> 
  select(gm_number, team, season, division_rank, games_back, win_per, win_streak,
         losing_streak)

# Joining tables to create data that will be used to model
model_data <- outcomes |> 
  inner_join(game_data, by = c("gm_number", "team", "season")) |> 
  inner_join(standings, by = c("gm_number", 'team', 'season')) |> 
  group_by(team, season, away_home) |> 
  mutate(away_home_gm_number = row_number()) |> 
  ungroup()


# Avoiding loading  unnecessary data into the global environrment
rm(game_data)
rm(mlb_data)
rm(outcomes)
rm(standings)



