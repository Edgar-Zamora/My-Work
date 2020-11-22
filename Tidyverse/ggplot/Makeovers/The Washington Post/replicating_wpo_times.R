#install.packages("googlesheets4")
library(googlesheets4)
library(tidyverse)
library(extrafont)
library(here)

party_palet <- tibble(
  party = c("democrat", "republican"),
  party_color = c("#0015BC", "#E9141D"))




state_winners <- read_sheet("https://docs.google.com/spreadsheets/d/1nD4koMn6il7gqYKqjyK1VNG_CM6KiIe5ofpW-e7v5AY/edit#gid=0") %>%
  left_join(party_palet, by = c("state_winner" = "party")) %>% 
  mutate(same_party = case_when(potus_winner == state_winner ~ "TRUE",
                                TRUE ~ "FALSE")) %>% 
  mutate(same_party_fill_colour = case_when(same_party == "FALSE" ~ "#FFFFFF",
                                            TRUE ~ as.character(party_color)),
         state = factor(state, levels = c("Ohio", "Nev.", "Fla.", "Mo.", "N.M.",
                                          "Ill.", "Ky.", "Tenn.", "Calif.", "Mont.")))





state_winners_plot <- ggplot(state_winners, aes(year, fct_rev(state))) +
  geom_tile(aes(colour = state_winner, fill = same_party_fill_colour,
                width = 2.5, height = .5), size = 1) +
  scale_x_continuous(position = "top") +
  scale_fill_identity() +
  scale_color_manual(values = c("#0015BC", "#E9141D")) +
  labs(
    title = "Ohio's streak of voting \nfor the winner is over",
    subtitle = "Election results in states most likely \nto pick the winner since 1960"
  ) +
  theme(
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    axis.text.y = element_text(size =  13, colour = "black"),
    axis.text.x = element_text(size = 13, colour = "black"),
    panel.grid = element_blank(),
    plot.title = element_text(size = 25, face = "bold"),
    plot.subtitle = element_text(family = "Helvetica Light", size = 15),
    panel.background = element_blank(),
    legend.position = "none"
  )


ggsave("replicated.png")








