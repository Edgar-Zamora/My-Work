# Packages
library(tidyverse)
library(janitor)
library(glue)
library(tidytext)
library(scales)


# Year data
teams <- c("ATL", "PHI", "NYM", "MIA", "WSN", "TBR", "NYY", "BOS",
           "TOR", "BAL", "MIL", "STL", "CIN", "CHC", "PIT", "CHW",
           "CLE", "DET", "MIN", "SFG", "SDP", "COL", "ARI", "HOU",
           'SEA', "OAK", "LAA", "TEX", "KCR", "LAD")
years <- c("2019")


mlb_2019 <- map2_df(teams, years, mlb_team_schedule)



# Report Data
## Annual Summaries
annual_facts <- mlb_2019 %>% 
  filter(home_away == "Home") %>% 
  group_by(team) %>% 
  summarise(
    avg_attendance = mean(attendance, na.rm = T),
    avg_runs_for = mean(runs_for, na.rm = T),
    avg_runs_against = mean(runs_against, na.rm = T)
  ) %>% 
  ungroup() %>% 
  mutate(
    attendance_rank = dense_rank(desc(avg_attendance)),
    runs_for_rank = dense_rank(desc(avg_runs_for)),
    runs_against_rank = dense_rank(desc(avg_runs_against))
  )


## Yearly Attendance
yearly_attnd <- function(team, year){
  
  mlb_2019 %>% 
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


yearly_attnd("LAD", year)



## Top 5 Opponents
x <- mlb_2019 %>% 
  filter(team == 'NYY') %>% 
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



x %>% 
  ungroup() %>% 
  mutate(opp = reorder_within(opp, avg_attendance, home_away)) %>% 
  ggplot(aes(avg_attendance, opp)) +
  geom_col() +
  geom_text(aes(label = paste0(comma(round(avg_attendance, 0)), " (", num_games,")")),
            hjust = 3, color = "white") +
  facet_grid(rows = vars(home_away), scales = "free_y") +
  scale_y_reordered()



  
