#Packages
library(tidyverse)
library(glue)
library(extrafont)
library(ggrepel)
library(ggimage)

#Loading data
season_goals <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-03/season_goals.csv')

#Importing NHL font
font_import()
font_import(pattern = "NHL")
#Find NHL font here: https://fontmeme.com/fonts/nhl-font/

#data exploration
xxx <- season_goals %>% 
  select(player, team, goals) %>% 
  group_by(player, team) %>% 
  summarise(total_goals = sum(goals)) %>% 
  ungroup()

top_10_scorers <- season_goals %>% 
  select(player, goals) %>% 
  group_by(player) %>% 
  summarise(career_goals = sum(goals)) %>% 
  arrange(desc(career_goals)) %>% 
  ungroup() %>% 
  top_n(5)

top3_by_players <- top_10_scorers %>% 
  left_join(xxx, by = "player") %>% 
  group_by(player, career_goals, team) %>%
  arrange(player, desc(total_goals)) %>% 
  ungroup() %>% 
  group_by(player) %>% 
  top_n(3) %>% 
  mutate(top3_total_goals = sum(total_goals),
         perc = round(total_goals/top3_total_goals * 100, 2),
         colour = "black")


#plot
player_names_lab <- top3_by_players$player %>% 
  unique()

career_goals_lab <- top3_by_players$career_goals %>% 
  unique()

strip_labels <- glue('{player_names_lab} {career_goals_lab}')

###
plot <- top3_by_players %>% 
  #filter(player == "Bobby Hull") %>% 
  ggplot(aes(x= 2, y= perc, fill= team)) +
  geom_bar(stat = "identity", color = "white") +
  geom_text(aes(label = paste(team, "\n", paste0(round(perc, 1), "%"))), colour = "white",
            position = position_stack(vjust = .5), size = 3) +
  coord_polar(theta = "y", start = 0) +
  scale_fill_manual(values = top3_by_players$colour,
                    name = "NHL Teams",
                    labels = c("Black Hawks (CBH)", "Red Wings (DET)", "Oilers (EDM)", "Hartford Whalers (HSA)",
                               "Kings (LAK)", "New England \nWhalers (NEW)", "Rangers (NYR)", "Penguins (PIT)", 
                               "Maple Leafs (TOT)", "Jets (WNJ)", "Capitals (WSH)")) +
  annotate("text", x = 1, y = 1, label = "NHL |", size = 5, family = "NHL") +
  xlim(1, 2.5) +
  labs(title = "Where Did The Top 5 NHL Goals Scorers Make Their Goals",
       subtitle = "% of goals of top 3",
       x = "", y = "") +
  facet_wrap(~player) +
  theme(
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    legend.position = c(.85, .27),
    legend.key.size = unit(0, "line"),
    plot.title = element_text(size = 11),
    plot.subtitle = element_text(size = 8),
    plot.caption = element_text(size = 7, hjust = 1.2),
    panel.grid = element_blank(),
    panel.background = element_blank()) +
  guides(fill = guide_legend(nrow = 6, byrow = TRUE))

ggsave("nhlTidyTuesday.png", width = 9, height = 8, units = "in", plot = plot)


  