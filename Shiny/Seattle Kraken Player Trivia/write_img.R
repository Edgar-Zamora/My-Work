# Load Packages
library(janitor)
library(tidyverse)
library(lubridate)
library(furrr)
library(magick)




# Reading Seattle Kraken data
read_csv("data/seattle_kraken.csv") %>% 
  select(player, player_img_large) %>% 
  group_by(player) %>% 
  group_map(~image_read(.x$player_img_large) %>% 
               image_write(., path = paste0("img/", .y$player, ".png"), format = "png"))
