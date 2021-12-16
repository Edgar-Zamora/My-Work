# Packages
library(tidyverse)
library(janitor)


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
mlb_2019 %>% 
  filter(team == 'NYY',
         home_away == 'Home') %>% 
  ggplot(aes(date, attendance, group = 1)) +
  geom_hline(yintercept = 41827) +
  geom_line() +
  scale_y_continuous(labels = scales::comma)



  
