#install.packages("googlesheets4")
library(googlesheets4)
library(tidyverse)

party_palet <- tibble(
  party = c("democrat", "republican"),
  party_color = c("#0015BC", "#E9141D"))


state_winners <- read_sheet("https://docs.google.com/spreadsheets/d/1nD4koMn6il7gqYKqjyK1VNG_CM6KiIe5ofpW-e7v5AY/edit#gid=0") %>%
  left_join(party_palet, by = c("state_winner" = "party")) %>% 
  mutate(same_party = case_when(potus_winner == state_winner ~ "TRUE",
                                TRUE ~ "FALSE"))



state_winners_2 <- state_winners %>% 
  mutate(same_party_fill_colour = case_when(same_party == "FALSE" ~ "#FFFFFF",
                                            TRUE ~ as.character(party_color)))


ggplot(state_winners_2, aes(year, state)) +
  geom_tile(aes(colour = state_winner, fill = same_party_fill_colour,
                width = 2.5, height = .5), size = 1) +
  scale_fill_identity() +
  scale_color_manual(values = c("#0015BC", "#E9141D"))
