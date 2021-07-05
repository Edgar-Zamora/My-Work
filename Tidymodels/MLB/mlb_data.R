# Loading packages
library(polite)
library(rvest)
library(httr)
library(janitor)
library(tidyverse)
library(lubridate)
library(glue)
library(gt)
library(scales)
library(mlbstatsR)


# Helper function
## Cleans and transforms data to make it easy to work with

schedule_clean <- function(data) {
  
  {{data}} %>% 
    separate(w_l, c("wins", "losses"), sep = "-") %>% 
    mutate(home_away = case_when(str_detect(opponent, "[@]") ~ "Away",
                                 TRUE ~ "Home"),
           opponent = str_remove(opponent, "(@|vs)"),
           weekday = factor(str_extract(date, "[^,]*"),
                            levels = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")),
           day = str_extract(date, "[:digit:]+"),
           month = str_extract(date, "(?<=\\s)(.*?)(?=\\s)"),
           att = str_remove(att, ","),
           month = factor(match(month, month.abb),
                          levels = c("1", "2", "3", "4", "5", "6", "7",
                                     "8", "9", "10", "11", "12")),
           new_date = ymd(paste("2019",month,day)),
           win_lose = str_extract(result, "(W|L)"),
           extra_innings = case_when(str_detect(result, "F") ~ "1",
                                     TRUE ~ "0"),
           extra_innings_num = str_extract(result, "(?<=/).+"),
           home_runs = str_extract(result, "(?<=(W|L))(.*?)(?=-)"),
           away_run = str_extract(result, "(?<=-).+"),
           across(c(wins, losses), as.numeric),
           win_per = wins/(wins + losses),
           winning_pitcher = str_extract(win, "^[^\\s]*"),
           lossing_pitcher = str_extract(loss, "^[^\\s]*")
    )
  
  
}


# Since the Los Angeles Angles and Los Angeles Dodgers are both named Los Angeles, i need to use their official name
# to differentiate between them. 

full_team_names <- function(url1, url2) {
  
  first_half_teams <- url1 %>% 
    read_html() %>% 
    html_nodes(".tc+ span .AnchorLink") %>% 
    html_attr('href') %>% 
    as.tibble() %>% 
    mutate(team = str_to_title(str_extract(value, "([^/]+$)")),
           team = str_replace_all(team, "-", " "))  %>% 
    select(-value) 
  
  
  second_half_teams <- url2 %>% 
    read_html() %>% 
    html_nodes(".tc+ span .AnchorLink") %>% 
    html_attr('href') %>% 
    as.tibble() %>% 
    mutate(team = str_to_title(str_extract(value, "([^/]+$)")),
           team = str_replace_all(team, "-", " "))  %>% 
    select(-value) 
  
  
  
  full_season_teams <- first_half_teams %>% 
    bind_rows(second_half_teams) %>% 
    rowid_to_column()
  
  return(full_season_teams)
  
}

# Function to get schedule information

mlbscrapeR <- function(team, year){
  
  url1 <- glue("https://www.espn.com/mlb/team/schedule/_/name/{team}/season/{year}/seasontype/2/half/1")
  url2 <- glue("https://www.espn.com/mlb/team/schedule/_/name/{team}/season/{year}/seasontype/2/half/2")
  
  
  first_half <- url1 %>% 
    read_html() %>% 
    html_table() %>% 
    pluck(1) %>% 
    row_to_names(row_number = 1) 
  
  second_half <- url2 %>% 
    read_html() %>% 
    html_table() %>% 
    pluck(1) %>% 
    row_to_names(row_number = 1) 
  
  
  home_team <- url1 %>% 
    read_html() %>% 
    html_nodes(".headline__h1") %>% 
    html_text() %>% 
    as.tibble(.repair_names = "unique") %>% 
    mutate(team = str_extract(value, "(.*?)(?=\\sSch)")) %>% 
    select(-value)
  
  
  full_team_names <- full_team_names(url1, url2)
  
  
  mlb_data <- rbind(first_half, second_half) %>% 
    mutate(home_team = home_team$team,
           season_year = {{year}}) %>% 
    clean_names() %>%
    schedule_clean() %>% 
    rowid_to_column() %>% 
    left_join(full_team_names)
   
  return(mlb_data)
  
}



x <- mlbscrapeR("sea", 2018)


years <- c(2017, 2018, 2019)


x <- map2_df("sea", years, mlbscrapeR)



# Weekday Attendance
x %>% 
  filter(result != "Postponed",
         home_away == "Home") %>% 
  mutate(across(att, as.numeric)) %>% 
  ggplot(aes(weekday , att, fill = weekday)) +
  geom_boxplot() +
  geom_jitter(alpha = .5) +
  facet_wrap(~season_year)




team_info <- mlbstatsR::get_mlb_teams() %>% 
  mutate(name = case_when(name == "St. Louis Cardinals" ~ "St Louis Cardinals",
                          TRUE ~ name))

x %>% 
  filter(result != "Postponed",
         home_away == "Home") %>% 
  mutate(across(att, as.numeric)) %>% 
  left_join(team_info, by = c('team' = 'name')) %>% 
  ggplot(aes(division, att, fill = division)) +
  geom_boxplot()



x %>% 
  filter(result != "Postponed") %>% 
  mutate(across(att, as.numeric)) %>% 
  ggplot(aes(new_date, win_per, group = as.character(season_year), colour = as.character(season_year))) + 
  geom_line(size = 1)




