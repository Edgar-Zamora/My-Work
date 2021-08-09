library(shiny)
library(tidyverse)
library(nycflights13)
library(viridis)
library(ggthemes)
library(lubridate)
library(shinyWidgets)
library(extrafont)
library(ggtext)
library(glue)
library(rmarkdown)



merged_df <- flights %>% 
  left_join(airports %>% 
              rename(dest_airport = name), by = c("dest" = "faa")) %>% 
  right_join(airlines %>% 
               rename(carrier_name = name), by = "carrier") %>% 
  mutate(date = mdy(paste(month, day, year, sep = "/")),
         delayed = case_when(dep_delay < 0 ~ "Yes",
                             TRUE ~ "No"))



daily_flights_tbl <- function(data){
  
  carrier_name <- unique({{data}}$carrier_name)
  
  {{data}} %>% 
    mutate(across(c(month, day), as.factor)) %>% 
    count(month, day) %>% 
    ggplot(aes(month, fct_rev(day), fill = n)) +
    geom_tile() +
    geom_text(aes(label = n), size = 4) +
    scale_fill_viridis(name = "Number of \nFlights") +
    scale_x_discrete(position = "top") +
    labs(
      x = "Month",
      y = "Day",
      title = paste("Number of Daily Flights For <i style='color:blue'>", carrier_name, "</i>")
    ) +
    theme(
      axis.ticks = element_blank(),
      axis.title =  element_text(size = 15),
      panel.grid = element_blank(),
      panel.background = element_blank(),
      plot.title = element_markdown(family = "Bebas Neue", size = 21),
      text = element_text(colour = "black", family = "Bebas Neue")
    )
}



merged_df %>% 
  count(carrier_name)


