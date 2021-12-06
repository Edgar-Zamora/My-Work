# Loading packages
library(recruitR)
library(tidyverse)
library(gt)
library(fontawesome)
library(htmltools)
library(extrafont)
library(janitor)
library(here)
library(cfbfastR)



### College Football Recruit data

# Loading data for team logos
team_logos <- read_csv(here("Shiny", "College Football Recruits", "data", "team_info.csv")) %>% 
  janitor::clean_names()


# Desired years
years <- c(2010:2020)


# Mapping through years to get cfb draft picks
cfb_team_data <- map_df(years, cfbd_recruiting_player) %>% 
  tibble() %>% 
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


# Writing cfb data
write_rds(cfb_team_data, here("Shiny", "College Football Recruits", "data", "college_recruits_10_22.rds"))
write_rds(cfb_recruit_summary, here("Shiny", "College Football Recruits", "data", "college_recruit_sum_10_22.rds"))





### College Football Player Draft Data

# Desired years
nfl_draft_yrs <- c(2010:2021)


# Mapping through years to get nfl draft picks
draft_picks <- map_df(nfl_draft_yrs,cfbd_draft_picks) %>% 
  tibble() %>% 
  rename(
    draft_year = year
  )

# Writing draft pick data
write_rds(draft_picks, here("Shiny", "College Football Recruits", "data", "nfl_draft_picks_10_21.rds"))


