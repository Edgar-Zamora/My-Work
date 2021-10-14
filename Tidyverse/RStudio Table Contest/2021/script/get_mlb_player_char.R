# Loading packages
library(rvest)
library(measurements)
library(stringr)
library(tidyverse)
library(mlbstatsR)
library(here)
library(janitor)

# Helper functions
## Convert feet inches (6' 4") to cm to help find team averages
ft_inch <- function(str_ft_inch){
  elem <- as.integer(unlist(strsplit(str_ft_inch, "'")))
  inch <- elem[1]*12 + elem[2]
  return(conv_unit(inch, "inch", "cm"))
}


# Loading data
## Team Images from {mlbstatsR}
team_logos <- mlbstatsR::get_png_logos() %>% 
  select(-team_name) %>% 
  mutate(across(c(team_nickname), str_to_lower),
         full_name = case_when(full_name == 'St. Louis Cardinals' ~ "St Louis Cardinals",
                               TRUE ~ full_name)) %>% 
  rename(
    team_abbr = team_nickname,
    team_name = full_name
  )


## Creating urls for each team
team_urls <- mlbstatsR::get_mlb_teams() %>% 
  tibble() %>% 
  select(name, team) %>% 
  mutate(across(team, str_to_lower),
         team = case_when(team == 'sdp' ~ "sd", #correcting team abbr to match ESPN
                          team == 'sfg' ~ "sf",
                          team == "tbr" ~ "tb",
                          team == "wsn" ~ "wsh",
                          team == "kcr" ~ "kc",
                          TRUE ~ team),
         name = str_remove(name, "[.]"),
         url_team_name = str_replace_all(str_to_lower(name), " ", "-"),
         team_url = paste0(team,"/",url_team_name)) %>% 
  rename(
    team_name = name,
    team_abbr = team
  )


## Getting distinct urls for each team
urls <- team_urls %>% 
  distinct(team_url) %>% 
  pull()


# Creating function to allow sraping ESPN play characteristics
get_player_char <- function(url){
  
  urls <- glue::glue("https://www.espn.com/mlb/team/roster/_/name/{url}")
  
  
  player_img <- urls %>% 
    read_html() %>% 
    html_nodes(".silo img") %>% 
    html_attr("alt")
  
  
  df <- urls %>% 
    read_html() %>% 
    html_table() %>% 
    map(., clean_names) %>% 
    map_df(., rbind) %>%
    rename(
      wt_lbs = wt,
      bat_hand = bat,
      thw_hand = thw
    ) %>%
    separate(birth_place, into = c("city", "state_country"), sep = ", ") %>%
    mutate(team_name = str_extract(url, "[\\/].*"),
           gen_pos = case_when(str_detect(pos, "P") ~ "Pitcher",
                               pos == "C" ~ "Catcher",
                               pos == "DH" ~ "Disginated Hitter",
                               str_detect(pos, "F") ~ "Outfielder",
                               TRUE ~ "Infielder"),
           ht_cm = map_dbl(str_squish(str_remove(ht, "\"")), ft_inch),
           player_number = str_extract(name, "\\d+"),
           wt_lbs = as.numeric(str_trim(str_remove_all(wt_lbs, "[:alpha:]"))),
           name = str_remove_all(name, "\\d"),
           team_name = str_remove(team_name, "[\\/]"),
           team_name = str_to_title(str_replace_all(team_name, "-", " ")),
           x = player_img) %>%
    left_join(team_logos, by = "team_name")
  
  
  return(df)
  
}


# Mapping and saving data
all_mlb_players <- map_df(urls, get_player_char)

write_rds(all_mlb_players, here::here("Tidyverse", "RStudio Table Contest", "2021", "data", "mlb_player_char.rds"))

