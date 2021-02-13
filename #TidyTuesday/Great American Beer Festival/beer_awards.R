library(BBmisc)
library(tidyverse)
library(hablar)
library(sf)
library(rnaturalearth)
library(feather)
library(ggbump)
library(ggtext)
library(here)

# Original graphic : https://github.com/davidsjoberg/tidytuesday/blob/master/2020w17/2020w17_skript.R

beer_awards <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-10-20/beer_awards.csv')

#Building a dataframe with state abbreviations and their name. 
state_names <- tibble(
  state_name = state.name,
  state_abb = state.abb)

#Finding the top 10 states by the number of gold medals
top10_states_gold <- beer_awards %>% 
  filter(medal == "Gold") %>% 
  count(state, sort = T) %>% 
  slice(1:10) %>% 
  left_join(state_names, by = c("state" = "state_abb"))


sdf2 <- ne_states(country = 'united states of america') %>% 
  st_as_sf() %>% 
  filter(name %in% top10_states_gold$state_name)


ranking2 <- st_geometry(sdf2) %>% 
  st_point_on_surface() %>% 
  st_coordinates() %>% 
  as_tibble() %>% 
  bind_cols(tibble(state = sdf2$name,
                   xend = -62)) %>% 
  left_join(top10_states_gold, by = c("state" = "state_name")) %>%
  mutate(fine_cap = normalize(rank(n, ties.method = "first"), range(25, 50), method = 'range'),
         fine_cap_x = normalize(n, range = c(-60, -50), method = "range"))
  

#Creating graphic
plot <- ggplot() +
  geom_sf(data = sdf2, size = .3, fill = "transparent", color = "#FFFFF0") +
  geom_sigmoid(data = ranking2, 
               aes(x = X, y = Y, xend = xend , yend = fine_cap, group = state, color = n), 
               alpha = .6, smooth = 10, size = 1.5) +
  geom_segment(data = ranking2, 
               aes(x = -60,  y = fine_cap, xend = fine_cap_x, yend = fine_cap, color = n), alpha = .6, size = 1.5,
               lineend = "round") +
  geom_text(data = ranking2, aes(x = xend, y = fine_cap, label = paste0(state, " (",n,")")), hjust = 1, size = 3, nudge_y = .5, colour = "white") +
  geom_point(data = ranking2, 
             aes(x = X, y = Y, color = n), size = 4) +
  scale_fill_viridis_c(option = "viridis") +
  scale_color_viridis_c(option = "viridis") +
  theme_void() +
  labs(
    title =  "Getting The <span style = 'color:gold;'>Gold </span>: Top 10 States",
    subtitle = "The Professional Judge Panel awards gold, silver or bronze medals that are recognized around the 
    <br>world as symbols of brewing excellence. These awards are among the most 
    coveted in the industry <br>and heralded by the winning brewers in their national advertising.",
    caption = "Data: Great American Beer Festival | Viz: @Edgar_Zamora_") +
  theme(plot.margin = margin(.5, 1, .5, .5, "cm"),
        legend.position = "none",
        plot.background = element_rect(fill = "black"),
        plot.caption = element_text(color = "gray40"),
        plot.title = element_markdown(color = "white", size = 20, family = "American Typewriter"),
        plot.subtitle = element_markdown(color = "#BEBEBE", size = 8))


#Saving plot
ggsave(here("#TidyTuesday", "Great American Beer Festival", "beer_award.png"), width = 10, height = 8, units = c("in"))
