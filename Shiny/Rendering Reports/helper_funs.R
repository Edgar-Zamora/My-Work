# Packages
library(tidyverse)
library(janitor)
library(glue)
library(tidytext)
library(scales)
library(ggchicklet)



## Yearly Attendance
yearly_attnd <- function(data, team, year){
  
  data %>% 
    filter(team == {{team}}) %>% 
    mutate(month = month(date)) %>% 
    ggplot(aes(date, attendance)) +
    geom_line(size = .75) +
    geom_point(aes(color = home_away), size = 3) +
    scale_color_manual(values = c("#c8d0d9", "#1170aa"),
                       name = 'Home or Away?') +
    scale_y_continuous(labels = scales::comma) +
    scale_x_date(date_labels = "%b %d",
                 date_breaks = "2 weeks") +
    labs(
      x = "",
      y = "Game Attendance",
      title = glue("{year} {team} Attendance")
    )
  
  
}



## Top 5 Opponents
top_5_games <- function(data, team) {
  
  df <- data %>% 
    filter(team == {{team}}) %>% 
    select(opp, attendance, home_away) %>% 
    group_by(home_away, opp) %>% 
    summarise(
      avg_attendance = mean(attendance, na.rm = T),
      num_games = n()
    ) %>% 
    ungroup() %>% 
    group_by(home_away) %>% 
    arrange(desc(avg_attendance)) %>% 
    slice(1:5)
  
  
  df %>% 
    ungroup() %>% 
    mutate(opp = reorder_within(opp, avg_attendance, home_away),
           home_away = factor(home_away, levels = c("Home", "Away"))) %>% 
    ggplot(aes(opp, avg_attendance)) +
    geom_chicklet(radius = grid::unit(15, "pt")) +
    coord_flip() +
    geom_text(aes(label = paste0(comma(round(avg_attendance, 0)), " (", num_games,")")),
              hjust = 1.2, color = "white") +
    facet_grid(rows = vars(home_away), scales = "free_y") +
    scale_x_reordered() +
    labs(
      x = "Avg Attendance",
      y = "",
      title = "Top 5 Home & Away Avg Attendance",
      subtitle = "(#) = Number of games played"
    ) +
    theme(
      panel.grid = element_blank(),
      panel.background = element_blank(),
      axis.ticks = element_blank(),
      axis.text = element_text(colour = 'black', size = 8)
    )
  
  
}

  
