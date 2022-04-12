# Loading packages
library(polite)
library(rvest)
library(httr)
library(janitor)
library(tidyverse)
library(lubridate)
library(glue)
library(gt)
library(scales)
library(mlbstatsR)


# Getting mlb attendance data
# https://www.baseball-reference.com/teams/SEA/2021-schedule-scores.shtml
# https://www.baseball-reference.com/teams/SEA/2020-schedule-scores.shtml
#'https://www.baseball-reference.com/teams/',{{team}}, '/' ,{{year}}, '-schedule-scores.shtml'


# #div_team_schedule


mlbscrapR <- function(team, year) {
  
  url <- paste0("https://www.baseball-reference.com/teams/", team, "/", year, "-schedule-scores.shtml")
  
  session <- bow(url)
  
  scrape(session) %>% 
  html_node("#div_team_schedule") %>% 
  html_table() %>% 
  clean_names() %>% 
  filter(tm != "Tm") %>% 
  mutate(away_home = case_when(x_2 == "@" ~ "away",
                               TRUE ~ "home"),
         walkoff = case_when(str_detect(w_l, "wo") ~ 1,
                             TRUE ~ 0),
         w_l = str_remove_all(w_l, "-wo"),
         mlb_season = year) %>% 
  select(-c(x, x_2))
}


years <- c(2011:2021)
mlb_teams <- c("LAA")


map2_df(mlb_teams, years, mlbscrapR)




