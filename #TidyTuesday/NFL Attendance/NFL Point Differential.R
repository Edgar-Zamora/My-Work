#Loading Packages
library(tidyverse)
library(scales)

#Loading packages
standings <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-02-04/standings.csv')

#
xxx <- standings %>% 
  select(team, team_name, year, points_differential, sb_winner) %>% 
  group_by(team, team_name, year) %>% 
  arrange(team, desc(year)) %>% 
  filter(team_name %in% c("49ers", "Seahawks", "Rams", "Cardinals")) %>% 
  mutate(sb_winner_colour = if_else(sb_winner == "Won Superbowl", "green", "red")) %>% 
  ungroup()

ggplot(xxx, aes(year, points_differential)) +
  geom_line(aes(group = team), size = .9) +
  geom_point(aes(colour = sb_winner_colour), 
             shape = 21 , fill = "white", size = 2.5, stroke = 1.5, show.legend = FALSE)

