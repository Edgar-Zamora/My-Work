# Library packages
library(tidyverse)
library(xml2)
library(polite)
library(rvest)
library(janitor)
library(reactable)


# Link to wikipedia page with rosters
wc_squads_url <- 'https://en.wikipedia.org/wiki/2022_FIFA_World_Cup_squads'


# Be polite
session <- bow(wc_squads_url, force = TRUE)

team_names <- scrape(session) |> 
  html_nodes('h2+ h3 , .plainrowheaders+ h3') |> 
  html_text()


squads <- scrape(session) |> 
  html_table()

squads <- squads[1:32] |> 
  set_names(team_names) |> 
  map(~clean_names(., case = 'snake')) |> 
  bind_rows(.id = 'groups') |> 
  rename(team_name = groups) |> 
  mutate(age = as.numeric(str_remove(str_sub(date_of_birth_age, -3), "\\)")),
         captain = ifelse(str_detect(player, "captain"), 1, 0),
         player = str_trim(str_remove(player, "\\(captain\\)"))) |> 
  select(-c(no, pos, date_of_birth_age)) 


# Average Age
avg_age <- squads |> 
  group_by(team_name) |> 
  summarise(avg_age = round(mean(age, na.rm = TRUE), digits = 0))

# Top Scorer
top_goals <- squads |> 
  group_by(team_name) |> 
  slice_max(n = 1, order_by = goals) |> 
  select(-c(caps, club, age)) |> 
  print(n = Inf)

# Top Caps
top_caps <- squads |> 
  group_by(team_name) |> 
  slice_max(n = 1, order_by = caps) |> 
  select(-c(goals, club, age)) |> 
  print(n = Inf)

# Top club represented
team_league <- read_csv("~/Downloads/team_league.csv")

dometic_plyrs <- squads |> 
  left_join(team_league, by = c("club")) |> 
  mutate(same_county_league = if_else(league == team_name, 1, 0)) |> 
  group_by(team_name) |> 
  summarise(
    total_players = n(),
    domestic_league = sum(same_county_league),
    percent_domestic = round(domestic_league/total_players * 100, 1)
  )




