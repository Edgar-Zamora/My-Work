#Loading Packages
library(tidyverse)
library(scales)
library(ggimage)
library(ggrepel)

#Loading Data
standings <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-02-04/standings.csv')
nfl_divisions <- read_csv('NFL Divisions.csv') #created this myself

#Assigning colour of superbowl winners
sb_winner_colour <- "#FFD700"
sb_loser_colour <- "grey90"

#Filtering to those teams that have "Won the Superbowl"
superbowl_teams <- standings %>% 
  select(sb_winner, team_name) %>% 
  filter(sb_winner == "Won Superbowl") %>% 
  select(-sb_winner) %>% 
  unique()

#Joining standings data with division data to get the conference for each team
nfl_sb_winners <- standings %>% 
  left_join(nfl_divisions, by = "team_name") %>% 
  select(team, team_name, year, points_differential, sb_winner, conference, division, colour) %>% 
  group_by(team, team_name, year) %>% 
  arrange(team, desc(year)) %>% 
  ungroup() %>% 
  filter(team_name %in% superbowl_teams$team_name)

#Assiging hex colors to each team
team_colour <- xxx %>% 
  select(team_name, colour, conference) %>%
  unique() %>% 
  arrange(team_name)

#Creating graphic
ggplot(nfl_sb_winners, aes(year, points_differential, label = team_name)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_line(aes(group = team_name, colour = team_name), size = 1.2, key_glyph = "timeseries") +
  geom_point(colour = if_else(xxx$sb_winner == "Won Superbowl", sb_winner_colour, sb_loser_colour), 
             shape = 21 , fill = "white", size = 4.3, stroke = 1.7, show.legend = FALSE) +
  labs(x = "NFL Season",
      y = "Point Differential",
      title = "Point Differential For Each Superbowl Winner By Conference") +
  scale_colour_manual(name = "Team Name",
                      values = team_colour$colour) +
  scale_x_continuous(breaks = seq(2000,2019, by = 3)) +
  theme(
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    panel.background = element_rect(colour = "black", fill = "#FAFAFA"),
    legend.position = "bottom",
    legend.key = element_blank(),
    legend.text = element_text(size = 10),
    plot.title = element_text(size = 18)
  ) +
  facet_grid(rows = vars(conference)) +
  guides(colour = guide_legend(nrow=2, byrow=TRUE))


#saving graphic
ggsave("nfl_sb_winners.png", width = 14, height = 8)



