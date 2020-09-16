library(tidyverse)
library(janitor)
library(geofacet)
library(scales)

kids <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-15/kids.csv')


top_5_spending_areas <- kids %>%
  group_by(state, variable) %>% 
  summarise(
    var_spending = sum(raw),
  ) %>% 
  ungroup() %>% 
  group_by(state) %>%
  mutate(total_state_spending = sum(var_spending, na.rm = T),
         percent_var_total = var_spending/total_state_spending * 100) %>%
  top_n(5, percent_var_total) %>%
  ungroup()



top_5_spending_areas %>% 
  filter(state == "Washington") %>% 
  ggplot(aes(percent_var_total, "", fill = variable)) +
  geom_col() +
  scale_x_continuous(limits = c(0, 100)) 
facet_geo(~state, grid = "us_state_grid2") +
  labs(
    y = NULL,
    x = NULL,
    title = "Show Me the Money (or lack of)",
    subtitle = "Top 5 spending areas for each state from x to x") +
  theme(
    axis.ticks = element_blank(),
    strip.text.x = element_text(size = 6))

