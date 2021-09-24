# Loading packages
library(recruitR)
library(tidyverse)
library(gt)
library(fontawesome)
library(htmltools)
library(extrafont)
library(janitor)
library(here)


# Loading data for team logos
team_logos <- read_csv(here("data", "team_info.csv")) %>% 
  janitor::clean_names()


# Desired years
years <- c(2015:2022)


# Mapping through years and saving to data folder
cfb_team_data <- map_df(years, cfbd_recruiting_player) %>% 
  as_tibble() %>% 
  left_join(team_logos, by = c("committed_to" = "school")) %>%
  mutate(logos_0 = case_when(is.na(logos_0) ~ " ",
                             TRUE ~ logos_0))


cfb_recruit_summary <- cfb_team_data %>% 
  group_by(year, committed_to) %>% 
  summarise(
    commits = n(),
    top_300 = sum(ranking <= 300, na.rm = T),
    other_commits = sum(ranking >= 300, na.rm = T),
    five_star = sum(stars == 5),
    four_star = sum(stars == 4),
    three_star = sum(stars == 3)
  )


# Writing data
write_rds(cfb_team_data, here("data", "college_recruits_15_22.rds"))
write_rds(cfb_recruit_summary, here("data", "college_recruit_sum_15_22.rds"))
