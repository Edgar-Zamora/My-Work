# Load Packages
library(janitor)
library(rvest)
library(polite)
library(tidyverse)
library(httr)
library(lubridate)
library(gt)
library(furrr)

# Source functions
source("funs/helper_funs.R")


# Position reference table
pos_xref <- tibble(
  pos = c("D", "C", "LW", "RW", "G"),
  pos_name = c("Defenseman", "Center", "Left Wing", "Right Wing",
               "Goalie")
)


# Bow to session
session <- bow("https://www.nhl.com/kraken/roster", force = TRUE)



# Scraping Kraken team roster
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


# Iterating through each element on the page and then building a data frame.
player_df <- map_dfc(categories, kraken_scrape) %>% 
  mutate(across(player, ~str_remove_all(str_squish(.), "^[A-Z].?\\s")),
         ht = str_sub(ht, start = 1, end = 3),
         born = as.Date(str_sub(born, start = 1, end = 8), "%m/%d/%y"),
         age = year(Sys.Date()) - year(born),
         myd_date = format(born, format = '%B %d, %Y'),
         team_role = str_remove_all(str_trim(str_extract(player, ".?[\\(].[\\)].?")), "[:punct:]"),
         team_role = case_when(team_role == "C" ~ "Captain",
                               team_role == "A" ~ "Alternate Captain",
                               TRUE ~ "None"),
         sh = case_when(sh == 'L' ~ "Left",
                        sh == 'R' ~ "Right",
                        TRUE ~ sh),
         player = str_remove(player, ".?[\\(].[\\)].?"),
         alpha_3_code = str_sub(birthplace, start = -3)) %>% 
  left_join(read_csv("data/alpha3_country_cds.csv") %>% 
              clean_names() %>% 
              select(country, alpha_3_code), by = "alpha_3_code") %>% 
  mutate(full_birthplace = str_replace(birthplace, str_sub(birthplace, start = -3), country)) %>% 
  filter(if_any(born, ~!is.na(.))) %>% 
  rowid_to_column() %>% 
  
  # Adding player image outside of function because of the need to get the attribute 
  # which is the image url
  left_join(scrape(session) %>% 
              html_elements(".player-photo") %>% 
              html_attr("src") %>% 
              as_tibble() %>% 
              rowid_to_column() %>% 
              rename(player_img_small = value), by = "rowid")




# Getting larger player images and combining with above df
# Running this will take some time
complete_player_df <- player_df %>% 
  select(rowid, player, player_img_small) %>% 
  separate(col = player, into = c("first_name", "last_name"), sep = " ") %>% 
  mutate(plyr_id = str_extract(str_sub(player_img_small, start = -11), ".*(?=\\.)"),
         across(c(first_name, last_name), str_to_lower),
         plyr_img_addr = paste0("https://www.nhl.com/player/", first_name, "-", last_name, "-", plyr_id),
         player_img_large = future_map(plyr_img_addr, kraken_imgs)) %>% 
  unnest(player_img_large) %>% 
  rename(player_img_large = value) %>% 
  right_join(player_df) %>% 
  select(-c(plyr_img_addr)) %>% 
  left_join(pos_xref, by = "pos")
  

# Writing player information to data folder
write_csv(complete_player_df, "data/seattle_kraken.csv")


#### get_season_stats
# Bow to session
#https://www.nhl.com/player/mark-giordano-8470966
# Making each players specific url to be able to get their season and career stats
player_urls <- complete_player_df %>% 
  transmute(player_url = paste0("https://www.nhl.com/player/", first_name, "-", last_name, "-", plyr_id),
            player_name = player)



player_url <- pluck(player_urls$player_url)
player_names <- pluck(player_urls$player_name)



kraken_player_stats <- furrr::future_map2(player_names, player_url, safely(kraken_stats)) %>% 
  set_names(player_names)


# Writing player stats to data folder
write_rds(kraken_player_stats, file = "data/kraken_player_stats.rds")


