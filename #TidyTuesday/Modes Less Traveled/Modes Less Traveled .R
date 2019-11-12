#Packages
library(tidyverse)
library(statebins)
library(viridis)
library(scales)
options(scipen=999)

#Load Data
commute_mode <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-11-05/commute.csv")

#Compute total number of walkers per state
total_walking_num <- commute_mode %>% 
  filter(mode == "Walk" & !is.na(state_abb)) %>% 
  group_by(state_abb) %>% 
  summarize(walking_num = sum(n))

#Visualize total number of walkers per state using the statebins package
ggplot(total_walking_num, aes(state = state_abb, fill = log2(walking_num))) +
  geom_statebins(border_col="grey40", border_size = .2) +
  scale_fill_viridis(option = "magma", direction = -1, label = comma,
                     name = "") +
  labs(title = "Do you like walking to places?",
       subtitle = "Aggregate (log) number of walkers by state") +
  theme(panel.background = element_blank(),
        plot.subtitle = element_text(size = 8),
        legend.position = "right",
        axis.ticks = element_blank(), 
        axis.text = element_blank(),
        plot.title = element_text(size = 23.5)) +
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 8))
