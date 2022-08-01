# Load packages
library(tidyverse)
library(tidymodels)
library(scales)
library(ggforce)
library(ggthemes)
library(ggtext)
library(lubridate)

# Importing data
#source("write_data.R")
source("create_data.R")


sea_branding <- mlb_data$team_names.csv %>% 
  filter(team_abb == "SEA")


retired_teams <- tibble(
  full_team_name = c("Tampa Bay Devil Rays", "Los Angeles Angels of Anaheim", "Montreal Expos",
                     "Florida Marlins"),
  league_name = c("AL", "AL", "NL", "NL"),
  division = c("AL East", "AL West", "NL East", "NL East"),
  team_abb = c("TBD", "ANA", "MON", "FLA"),
  primary_color = c("#092C5C", "#003263", "#F03B40", "#00A3E0"),
  secondary_color = c("#8FBCE6", "#BA0021", "#02529C", "#EF3340"),
  logo = c("https://www.mlbstatic.com/team-logos/team-cap-on-light/139.svg",
           "https://www.mlbstatic.com/team-logos/team-cap-on-light/108.svg",
           "",
           "")
  )


## This will allow for the change the strip headers
## THIS IS NOT MT WORK. The solution comes from Claus Wilke who was answering a question on stackoverflow asked by Eric Green. 
## You can find the question and answer here: https://stackoverflow.com/questions/60332202/conditionally-fill-ggtext-text-boxes-in-facet-wrap/60345086#60345086

element_textbox_highlight <- function(..., 
                                      hi.labels = NULL, hi.fill = NULL,
                                      hi.col = NULL, hi.box.col = NULL,
                                      hi.labels2 = NULL, hi.fill2 = NULL,
                                      hi.col2 = NULL, hi.box.col2 = NULL) {
  structure(
    c(element_textbox(...),
      list(hi.labels = hi.labels, hi.fill = hi.fill, hi.col = hi.col, hi.box.col = hi.box.col,
           hi.labels2 = hi.labels2, hi.fill2 = hi.fill2, hi.col2 = hi.col2, hi.box.col2 = hi.box.col2)
    ),
    class = c("element_textbox_highlight", "element_textbox", "element_text", "element",
              "element_textbox_highlight", "element_textbox", "element_text", "element")
  )
}

element_grob.element_textbox_highlight <- function(element, label = "", ...) {
  if (label %in% element$hi.labels) {
    element$fill <- element$hi.fill %||% element$fill
    element$colour <- element$hi.col %||% element$colour
    element$box.colour <- element$hi.box.col %||% element$box.colour
  }
  if (label %in% element$hi.labels2) {
    element$fill <- element$hi.fill2 %||% element$fill
    element$colour <- element$hi.col2 %||% element$colour
    element$box.colour <- element$hi.box.col2 %||% element$box.colour
  }
  NextMethod()
}


### tidymodels ###
# Exploratory Data Analysis
# General overview of attendance for Mariners games
model_data %>% 
  filter(away_home == 'home') %>% 
  mutate(across(season, as_factor)) %>% 
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

model_data %>% 
  filter(away_home == 'home') %>% 
  group_by(team, season) %>% 
  summarise(avg_season_attnd = mean(attendance, na.rm = T)) %>% 
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
model_data %>% 
  filter(away_home == 'home') %>% 
  mutate(weekday = factor(weekday, levels = c("Monday", "Tuesday", "Wednesday",
                                              "Thursday", "Friday", "Saturday",
                                              "Sunday"))) %>% 
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
model_data %>% 
  filter(away_home == 'home') %>% 
  select(season, opp, attendance) %>% 
  mutate(opp = case_when(opp == "ANA" ~ "LAA",
                   opp == "TBD" ~ "TBR",
                   opp == 'FLA' ~ "MIA",
                   TRUE ~ opp)) %>% 
  left_join(mlb_data$team_names.csv %>% 
              rbind(retired_teams) %>% 
              select(-c(primary_color:logo)), by = c("opp" = "team_abb")) %>% 
  group_by(opp, league_name, division) %>% 
  summarise(
    num_games = n(),
    total_attendance = sum(attendance, na.rm = T),
    avg_opp_attendance = total_attendance/num_games
  ) %>% 
  ungroup() %>% 
  ggplot(aes(opp, avg_opp_attendance)) +
  geom_col(width = .80) +
  facet_wrap(vars(league_name, division), scales = "free_x") +
  scale_y_continuous(labels = number_format(scale = 1/1000, suffix = "K")) +
  labs(
    x = "",
    y = "Average Attendance",
    title = "Average Attendance Per MLB Team Since 2000",
    subtitle = "Average attendance is calculated by taking a sum of attendance and dividing by the number of games play"
  ) +
  theme(
    panel.grid = element_blank(),
    panel.background = element_blank(),
    axis.ticks = element_blank(),
    axis.text =  element_text(color = "black"),
    strip.background = element_blank(),
    plot.subtitle = element_text(size = 7.5),
    plot.title = element_text(size = 16),
    strip.text = element_textbox_highlight(
      size = 12,
      # unnamed set (all facet windows except named sets below)
      color = "black", fill = "white", box.color = "white",
      halign = 0.5, linetype = 1, r = unit(5, "pt"), width = unit(1, "npc"),
      padding = margin(2, 0, 1, 0), margin = margin(3, 3, 3, 3),
      # this is new relative to element_textbox():
      # first named set
      hi.labels = c("AL"),
      hi.fill = "#C0063B", hi.box.col = "white", hi.col = "white",
      # add second named set 
      hi.labels2 = c("NL"),
      hi.fill2 = "#01183F", hi.box.col2 = "white", hi.col2 = "white"
    )
  )


