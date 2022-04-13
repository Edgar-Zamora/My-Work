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
    html_element("table") %>% 
    html_table() %>%  
    clean_names() %>% 
    filter(tm != "Tm") %>%
    separate(col = date, into = c('weekday', "month", "day"), sep = "\\s") %>%
    mutate(away_home = case_when(x_2 == "@" ~ "away",
                                 TRUE ~ "home"),
           walkoff = case_when(str_detect(w_l, "wo") ~ 1,
                               TRUE ~ 0),
           forfeit = case_when(str_detect(w_l, "&V") ~ 1,
                               TRUE ~ 0),
           w_l = str_remove_all(w_l, "-wo|&V"),
           extra_innings = case_when(inn == "" ~ 1,
                                     TRUE ~ 0),
           mlb_season = year,
           across(attendance, parse_number),
           across(weekday, ~str_remove_all(., "[:punct:]")),
           month = match(month, month.abb),
           date = ymd(paste0(year, "0", month, day)),
           mlb_team = team) %>%
    select(-c(x, x_2)) %>%
    rename(
      win_lose = w_l,
      innings = inn,
      win_lose_record = w_l_2,
      day_night = d_n
    )
}


years <- c(2011:2021)
mlb_teams <- c("ARI", "ATL", "BAL", "BOS", "CHC", "CHW", "CIN",
               "CLE", "COL", "DET", "HOU", "KCR", "LAA", "LAD",
               "MIN", "MIA", "MIL", "NYM", "NYY", "OAK", "PHI",
               "PIT", "SDP", "SFG", "SEA", "STL", "TBR", "TEX",
               "TOR", "WSN")


x <- map2(mlb_teams, years, mlbscrapR)



