#https://www.baseball-reference.com/teams/SEA/2021-schedule-scores.shtml

# Load packages
library(tidyverse)
library(janitor)
library(rvest)
library(polite)
library(lubridate)

# Bowing to webpage
session <- bow("https://www.baseball-reference.com")


# Reading table

mlb_team_schedule <- function(team, year) {
  
  team_url <- paste0('https://www.baseball-reference.com/teams/', {{team}}, "/", {{year}},"-schedule-scores.shtml")
  
  team_schedule <- read_html(team_url) %>% 
    html_element("table") %>% 
    html_table() %>% 
    clean_names() %>% 
    rename(
      day_night = d_n
    ) %>% 
    filter(str_detect(gm_number, "[:digit:]")) %>% 
    separate(col = date, into = c('weekday', 'date'), sep = ',') %>%  
    mutate(attendance = str_remove(attendance, ","),
           across(c(r, ra, attendance, c_li), as.numeric), 
           across(date, str_trim),
           home_away = case_when(x_2 == "@" ~ "Away",
                                 TRUE ~ "Home"),
           extra_innings = case_when(inn != "" ~ 1,
                                     TRUE ~ 0),
           games_back2 = case_when(str_detect(gb, "up") ~ as.numeric(str_extract(gb, "[:digit:].+")),
                                   gb == 'Tied' ~ 0,
                                   TRUE ~ as.numeric(gb) * -1),
           run_diff = r - ra,
           team = {{team}},
           double_header_gm = str_extract(date, "(?<=\\().*(?=\\))"),
           date = str_trim(str_remove(date, "\\(([^\\)]+)\\)")),
           double_header = case_when(is.na(double_header_gm) ~ 0,
                                     TRUE ~ 1),
           date =  as.Date(mdy(paste(date, {{year}})), "%Y%m%d"),
    ) %>% 
    select(-c(x, x_2)) %>% 
    rename(
      runs_for = r,
      runs_against = ra,
      games_back = gb
    )
  
  return(team_schedule)
  
}



