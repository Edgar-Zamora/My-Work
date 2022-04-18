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

# Creating crosses

years <- c(2010:2021)
mlb_teams <- c("SEA") #"ARI", "ATL", "BAL", "BOS", "CHC", "CHW", "CIN",
               #"CLE", "COL", "DET", "HOU", "KCR", "LAA", "LAD",
               #"MIN", "MIA", "MIL", "NYM", "NYY", "OAK", "PHI",
               #"PIT", "SDP", "SFG", "SEA", "STL", "TBR", "TEX",
               #"TOR", "WSN")

year_team <- crossing(years, mlb_teams)




# Database name: MLB Stats

# Table: OUTCOMES
# This table contains outcomes for each game with revelant info
get_outcome <- function(team, year) {
  
  url <- paste0("https://www.baseball-reference.com/teams/", team, "/", year, "-schedule-scores.shtml")
  session <- bow(url)

  
  scrape(session) %>% 
    html_element("table") %>% 
    html_table() %>%  
    clean_names() %>% 
    filter(tm != "Tm") %>% 
    select(gm_number, opp, w_l, r, ra, inn) %>% 
    mutate(
      walkoff = case_when(str_detect(w_l, "wo") ~ 1,
                          TRUE ~ 0),
      forfeit = case_when(str_detect(w_l, "&V") ~ 1,
                          TRUE ~ 0),
      w_l = str_remove_all(w_l, "-wo|&V"),
      inn = case_when(inn == "" ~ 0,
                      TRUE ~ as.numeric(inn)),
      extra_innings = case_when(inn >= 9 ~ 1,
                                TRUE ~ 0),
      team = team,
      year = year) %>% 
    rename(
      win_lose = w_l
    )
  
}


sea_outcomes <- map2_dfr(year_team$mlb_teams, year_team$years, get_outcome)



# Table: TEAM_NAMES
# This table will  contain information about each team including their
# official name, abbreviated name, team colors and other information.
get_team_names <- function() {
  
  mlbstatsR::get_mlb_teams() %>% 
  select(name, liga, division, team, primary, secondary) %>% 
  as_tibble() %>% 
  rename(
    full_team_name = name,
    league_name = liga,
    team_abb = team,
    primary_color = primary,
    secondary_color = secondary
  )
  
}

get_team_names()



# Table: GAME_DATA
# This table contains information regarding game data that does not pertain to the outcome. Things
# such as weekday (month, day), time, day or night etc.


get_game_data <- function(team, year) {
  
  url <- paste0("https://www.baseball-reference.com/teams/", team, "/", year, "-schedule-scores.shtml")
  session <- bow(url)
  
  
  scrape(session) %>% 
    html_element("table") %>% 
    html_table() %>%  
    clean_names() %>% 
    filter(tm != "Tm") %>% 
    separate(col = date, into = c('weekday', "month", "day"), sep = "\\s") %>% 
    mutate(across(weekday, ~str_remove_all(., "[:punct:]")),
           month = match(month, month.abb),
           date = ymd(paste0(year, "0", month, day)),
           weekend = case_when(weekday %in% c("Saturday, Sunday") & (weekday == "Friday" & time > "5:00") ~ 1,
                               TRUE ~ 0),
           attendance = as.numeric(str_remove_all(attendance, "[:punct:]")),
           year = year,
           team = team) %>% 
    select(gm_number, year, team, date, month, day, weekday, time, d_n, weekend, attendance) %>% 
    rename(
      day_night  = d_n,
      start_time = time
    )
    
}


get_game_data("SEA", 2019)


# Table: PITCHER_DATA




# TABLE: STANDINGS

