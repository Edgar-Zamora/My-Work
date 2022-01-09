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
    geom_point(size = 3) +
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
    scale_x_reordered() +
    labs(
      x = "Avg Attendance",
      y = "",
      title = "",
      subtitle = "(#) = Number of games played"
    ) +
    theme(
      panel.grid = element_blank(),
      panel.background = element_blank(),
      axis.ticks = element_blank(),
      axis.text = element_text(colour = 'black', size = 8)
    )
  
  
}




## Monthly Attendance
monthly_attnd <- function(data, team, year){
  
  data %>% 
    filter(tm == {{team}},
           year == {{year}}) %>% 
    select(date, attendance, weekday) %>% 
    mutate(month = month(date)) %>% 
    left_join(monthxref, by = 'month') %>% 
    group_by(month_name) %>% 
    mutate(
      gms_in_month = n()
    ) %>% 
    ungroup() %>% 
    mutate(month_name = factor(month_name, 
                               levels = c("March", "April", "May",
                                          "June", "July", "August",
                                          'September', "October")),
           weekday = factor(weekday,
                            levels = c("Sunday", "Monday", "Tuesday", 
                                       "Wednesday", "Thursday", 'Friday',
                                       "Saturday"))) %>% 
    ggplot(aes(month_name, attendance)) +
    geom_jitter(aes(colour = weekday), width = .33) +
    geom_boxplot(fill = 'transparent', outlier.shape = NA) +
    scale_y_continuous("Avg. Monthly Attendance", labels = comma,
                       limits = c(0, 60000)) + #largest mlb stadium is 60K
    scale_x_discrete('') +
    scale_colour_tableau(name = "Weekday") +
    labs(
      title = paste0("<strong>", {{team}}, "</strong> Monthly Attendance for ", "<strong>", {{year}}, "</strong> Season")
    ) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(colour = "#F5F5F5"),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      panel.background = element_blank(),
      axis.ticks = element_blank(),
      axis.text = element_text(colour = 'black', size = 10),
      axis.title.y = element_text(colour = 'black', size = 12),
      plot.title = element_markdown(size = 16),
      legend.position = "bottom",
      legend.key = element_blank()
    ) +
    guides(color = guide_legend(nrow = 1))
  
}
  
