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
mariners_season <- read_html("https://www.baseball-reference.com/teams/SEA/2019-schedule-scores.shtml") %>% 
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
         #date =  format(mdy(paste(date, '2019')), "%m/%d/%Y"),
         home_away = case_when(x_2 == "@" ~ "Away",
                               TRUE ~ "Home"),
         extra_innings = case_when(inn != "" ~ 1,
                                   TRUE ~ 0),
         games_back2 = case_when(str_detect(gb, "up") ~ as.numeric(str_extract(gb, "[:digit:].+")),
                         gb == 'Tied' ~ 0,
                         TRUE ~ as.numeric(gb) * -1),
         run_diff = r - ra,
         ate =  format(mdy(paste(date, '2019')), "%m/%d/%Y")) %>% 

  select(-c(x, x_2)) %>% 
  rename(
    runs_for = r,
    runs_against = ra,
    games_back = gb
  )

