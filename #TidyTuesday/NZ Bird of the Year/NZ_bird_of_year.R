#Libraries
library(tidyverse)
library(DT)
library(ggthemes)
library(waffle) #Needs to be 1.0 or above
#install.packages("waffle", repos = "https://cinc.rud.is")

#Import Data
nz_bird <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-11-19/nz_bird.csv")

#Place points
top5_votes <- nz_bird %>%
  filter(!is.na(vote_rank) & !is.na(bird_breed)) %>%
  count(bird_breed) %>%
  arrange(desc(n)) %>%
  top_n(5) %>%
  rename(total = n)

#Getting names of the top 5 bird breeds to filter
top5_names <- top5_votes$bird_breed

#Filter birds to top 5 and scaling the data by dividing into 25 to make 
#creating a waffle chart easier
top5_breakdown <- nz_bird %>%
  count(bird_breed, vote_rank) %>%
  filter(bird_breed %in% top5_names) %>%
  left_join(top5_votes, by = "bird_breed") %>%
  group_by(bird_breed) %>%
  mutate(n = n/25,
         vote_rank = as.factor(vote_rank)) %>%
  select(c(-total))

#Building Visualization
ggplot(top5_breakdown, aes(fill = fct_rev(vote_rank), values = rev(n))) +
  geom_waffle(color = "white", size = .3, flip = TRUE) +
  facet_wrap(~rev(bird_breed), nrow = 1, strip.position = "bottom",
             labeller = label_wrap_gen(width = 10)) + #will prevent overflow of labels
  scale_x_discrete() +
  scale_y_continuous(labels = function(x) x * 25, # make this multiplyer the same as n_rows
                     expand = c(0,0),
                     limits = c(0,50),
                     breaks = seq(0,50, by = 5)) +
  scale_fill_tableau(name = "1 sq = 25 votes",
                     labels = c("Vote 1", "Vote 2", "Vote 3", "Vote 4", "Vote 5")) +
  coord_equal() +
  labs(
    title = "Vote Rank Breakdown Among the Top 5 Bird Breeds",
    x = "Bird Breed",
    y = "Total Votes") +
  theme(panel.grid = element_blank(),
        plot.title = element_text(size = 16, hjust = .2),
        axis.ticks = element_blank(),
        panel.background = element_blank(),
        strip.background = element_blank())

top5_breakdown %>% 
  print(n = Inf)


