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




##### 
# 
# 
# 
# x <- mlb_df %>% 
#   filter(team == "SEA",
#          year == "2018") %>% 
#   mutate(month = month(date)) %>% 
#   group_by(team, year, month) %>% 
#   mutate(monthly_c_li = mean(c_li, na.rm = T)) %>% 
#   ungroup() %>% 
#   select(team, year, weekday, date, attendance, month, monthly_c_li) %>% 
#   left_join(monthxref, by = "month") %>% 
#   mutate(month_name = factor(month_name, levels = c("March", "April", "May",
#                                                     "June", "July", "August",
#                                                     "September", "October")))
# 
# 
# 
# 
# x %>% 
#   ggplot(aes(month_name, attendance, group = month,
#              colour = month_name)) +
#   geom_boxplot(fill = "transparent") +
#   geom_point(alpha = .4, size = 2) +
#   geom_jitter(alpha = .4) +
#   scale_y_continuous(name = "Avg. Monthly Attendance") +
#   scale_x_discrete(name = "") +
#   theme(
#     panel.grid = element_blank(),
#     panel.background = element_blank(),
#     legend.position = "none"
#   )
  
