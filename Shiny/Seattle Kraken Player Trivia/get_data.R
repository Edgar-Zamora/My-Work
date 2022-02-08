# Load Pkgs
library(janitor)
library(rvest)
library(polite)
library(tidyverse)
library(httr)
library(lubridate)
library(gt)


# Bow to session
session <- bow("https://www.nhl.com/kraken/roster", force = TRUE)



# Creating function to scrape data
kraken_scrape <- function(category) {
  
  scrape(session) %>% 
    html_elements({{category}}) %>% 
    html_text() %>% 
    as_tibble() %>% 
    row_to_names(row_number = 1) %>% 
    clean_names()
  
  
}

# Hometown: .hometown-col
# Birthplace: .birthdate-col
# Weight: .weight-col
# Height: .height-col
# Shooting hand: .shoots-col
# Position: .position-col
# Jersey #: .number-col
# Name: .name-col


# Make list of class names since using html_table() was not working
categories <- c(".hometown-col", ".birthdate-col", ".weight-col", ".height-col",
                ".shoots-col", ".position-col", ".number-col", ".name-col")


# Building table with Kraken player info
plyr_data <- map_dfc(categories, kraken_scrape) %>% 
  mutate(across(player, ~str_remove_all(str_squish(.), "^[A-Z].?\\s")),
         ht = str_sub(ht, start = 1, end = 3),
         born = as.Date(str_sub(born, start = 1, end = 8), "%m/%d/%y"),
         age = year(Sys.Date()) - year(born),
         team_role = str_remove_all(str_trim(str_extract(player, ".?[\\(].[\\)].?")), "[:punct:]"),
         team_role = case_when(team_role == "C" ~ "Captain",
                               team_role == "A" ~ "Alternate Captain",
                               TRUE ~ "None"),
         player = str_remove(player, ".?[\\(].[\\)].?")
  ) %>% 
  filter(across(born, ~!is.na(.))) %>% 
  rowid_to_column() %>% 
  left_join(scrape(session) %>% 
              html_elements(".player-photo") %>% 
              html_attr("src") %>% 
              as_tibble() %>% 
              rowid_to_column() %>% 
              rename(player_img_src = value), by = "rowid")


