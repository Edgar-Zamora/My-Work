#Libraries
library(tidyverse)
library(waffle)
library(DT)
library(ggthemes)
install.packages("waffle", repos = "https://cinc.rud.is")

#Import Data
nz_bird <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-11-19/nz_bird.csv")

#Place points
top10_votes <- nz_bird %>%
  filter(!is.na(vote_rank) & !is.na(bird_breed)) %>%
  count(bird_breed) %>%
  arrange(desc(n)) %>%
  top_n(5) %>%
  rename(total = n)

top10_names <- top10_votes$bird_breed

rm(x)

x <- nz_bird %>%
  count(bird_breed, vote_rank) %>%
  filter(bird_breed %in% top10_names) %>%
  left_join(top10_votes, by = "bird_breed") %>%
  group_by(bird_breed) %>%
  mutate(percent =round((n/total*100),2),
         n = n/50) %>%
  select(c(-total, -percent))



ggplot(x, aes(fill = vote_rank, values = n)) +
  geom_waffle(color = "grey90", size = .25, n_rows = 10, flip = TRUE) +
  facet_wrap(~bird_breed, nrow = 1, strip.position = "bottom") +
  scale_x_discrete() +
  scale_y_continuous(labels = function(x) x * 50, # make this multiplyer the same as n_rows
                     expand = c(0,0),
                     limits = c(0,30),
                     breaks = seq(0,30, by = 5)) +
  scale_fill_tableau(name= "One square = 50 votes") +
  coord_equal() +
  labs(
    title = "Faceted Waffle Bar Chart",
    x = "Bird Breed",
    y = "Total Votes") +
  theme(panel.grid = element_blank(),
        axis.ticks = element_blank(),
        panel.background = element_blank(),
        strip.background = element_blank()) +
  guides(fill = guide_legend(reverse = TRUE))


