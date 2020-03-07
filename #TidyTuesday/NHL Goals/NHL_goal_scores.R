#Packages
library(tidyverse)

#Loading data
season_goals <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-03/season_goals.csv')

#data exploration
xxx <- season_goals %>% 
  select(player, team, goals) %>% 
  group_by(player, team) %>% 
  summarise(total_goals = sum(goals)) %>% 
  ungroup()

top_15_scorers <- season_goals %>% 
  select(player, goals) %>% 
  group_by(player) %>% 
  summarise(career_goals = sum(goals)) %>% 
  arrange(desc(career_goals)) %>% 
  ungroup() %>% 
  top_n(15)

top_15_scorers %>% 
  left_join(xxx, by = "player") %>% 
  group_by(player, career_goals, team) %>%
  arrange(player, desc(total_goals)) %>% 
  print(n = 50)


  
  
  