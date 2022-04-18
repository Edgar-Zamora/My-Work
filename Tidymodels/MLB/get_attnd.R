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
library(furrr)

set.seed(1234)


# Getting mlb attendance data

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

year_team <- crossing(years, mlb_teams)

x <- furrr::future_map2_dfr(year_team$mlb_teams, year_team$years, mlbscrapR)



