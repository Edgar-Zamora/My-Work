library(tidyverse)
library(janitor)
library(geofacet)
library(scales)

kids <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-15/kids.csv') %>% 
  left_join(tibble(
  state_abb = state.abb,
  state_name = state.name) %>% 
  add_row(state_abb = "DC", state_name = "District of Columbia"), by = c("state" = "state_name"))

state_spending <- kids %>% 
  filter(variable == "highered") %>% 
  group_by(state_abb, year) %>% 
  summarise(
    avg = round(mean(inf_adj_perchild), 2)) %>% 
  ungroup() %>% 
  group_by(state_abb) %>% 
  mutate(diff = avg - lag(avg, default = first(avg))) %>% 
  ungroup() %>% 
  mutate(
    spending_change = case_when(diff == 0 ~ "Same",
                       diff < 0 ~ "Decrease",
                       TRUE ~ "Increase"),
    spending_change = factor(spending_change, levels = c("Increase", "Same", "Decrease")))


state_spending %>% 
  #filter(state == "Washington") %>% 
  ggplot(aes(year, avg, group = state_abb, color = spending_change)) +
  geom_line(size = .8, key_glyph = "timeseries") +
  scale_color_manual(name = "Spending Change", values = c("#59A14F","#BAB0AC", "#E15759")) +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    x = NULL,
    y = "Adjusted for Inflation Per Child ($)"
  ) +
  theme(
    legend.key = element_blank(),
    panel.grid = element_blank(),
    panel.background = element_blank(),
    axis.ticks = element_blank(),
    axis.text.x = element_blank()
  ) +
  facet_geo(~state_abb, grid = "us_state_grid2")









