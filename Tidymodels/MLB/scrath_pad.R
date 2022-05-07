# Load packages
library(tidyverse)
library(tidymodels)
library(scales)
library(ggforce)
library(ggthemes)


# Importing data
source("write_data.R")

mlb_data <- list.files("data", full.names = T) |> 
  map(., read_csv) |> 
  set_names(list.files("data"))


sea_branding <- mlb_data$team_names.csv |> 
  filter(team_abb == "SEA")

# Getting features and making new features that I think are relevant in trying to predict
# attendance to a Seattle Mariners game

outcomes <- mlb_data$outcomes.csv |> 
  left_join(mlb_data$team_names.csv |> 
              select(-c(contains("color"), full_team_name)), by = c("opp" = "team_abb")) |> 
  mutate(same_league = case_when(league_name == "AL" ~ 1,
                                 TRUE ~ 0),
         same_division = case_when(division == "AL West" ~ 1,
                                   TRUE ~ 0))
  select(gm_number, team, season, won_prev_game, same_league, same_division)



game_data <- mlb_data$game_data.csv |> 
  select(gm_number, season, team, month, day, weekday, day_night, weekend, attendance, away_home)



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




### tidymodels ###
# Exploratory Data Analysis
# General overview of attendance for Mariners games
model_data |> 
  filter(away_home == 'home') |> 
  mutate(across(season, as_factor)) |> 
  ggplot(aes(away_home_gm_number, attendance)) +
  geom_line(size = 0.8) +
  facet_wrap(~season) +
  scale_y_continuous(labels = number_format(scale = 1/1000, suffix = "K")) +
  labs(
    x = "",
    y = "Attendance for Game (1000k)",
    title = "Seattle Mariners Home Attendance From 2000-2019 and 2022",
    subtitle = "Does not include 2020 and 2021 due to the COVID-19 Pandemic"
  ) +
  theme(
    panel.grid = element_blank(),
    panel.background = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_text(color = "black", size = 8),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 16),
    strip.text = element_text(size = 12, face = "bold", colour = "white"),
    strip.background = element_rect(fill = sea_branding$secondary_color)
  )


# Average attendance
## Per season

model_data |> 
  filter(away_home == 'home') |> 
  group_by(team, season) |> 
  summarise(avg_season_attnd = mean(attendance, na.rm = T)) |> 
  ggplot(aes(as_factor(season), avg_season_attnd, group = 1)) +
  geom_line(size = 1.5, color = sea_branding$primary_color) +
  labs(
    x = "",
    y = "Average Season Attendance",
    title = "Seattle Mariners Average Season Attendance"
  ) +
  scale_y_continuous(labels = comma) +
  theme(
    panel.grid = element_blank(),
    panel.background = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_text(color = "black"),
    plot.title = element_text(size = 16)
  )
  



# Day of week
model_data |> 
  filter(away_home == 'home') |> 
  mutate(weekday = factor(weekday, levels = c("Monday", "Tuesday", "Wednesday",
                                              "Thursday", "Friday", "Saturday",
                                              "Sunday"))) |> 
  ggplot(aes(weekday, attendance, alpha = .5)) +
  geom_point() +
  geom_jitter(width = .25) +
  geom_boxplot(aes(fill = weekday)) +
  scale_y_continuous(labels = comma) +
  scale_fill_tableau() +
  labs(
    x = "",
    y = "Attendance",
    title = "Seattle Mariners Attendance By Day of Week"
  ) +
  theme(
    legend.position = "none",
    panel.grid = element_blank(),
    panel.background = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_text(color = "black"),
    plot.subtitle = element_text(size = 7.5),
    plot.title = element_text(size = 16)
  )


# Season win per v. attendance
model_data |> 
  filter(away_home == 'home') |> 
  ggplot(aes(win_per, attendance)) +
  geom_point()


