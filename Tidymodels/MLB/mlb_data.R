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


mlbscrapeR <- function(year){
  
  url1 <- glue("https://www.espn.com/mlb/team/schedule/_/name/sea/season/{year}/seasontype/2/half/1")
  url2 <- glue("https://www.espn.com/mlb/team/schedule/_/name/sea/season/{year}/seasontype/2/half/2")
  
  
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
  
  mlb_data <- rbind(first_half, second_half) 
  
  return(mlb_data)
  
}



x <- mlbscrapeR(2010)



z <- x %>% 
  clean_names() %>% 
  filter(att != "Postponed") %>% 
  select(-save) %>% 
  separate(w_l, c("wins", "losses"), sep = "-") %>% 
  mutate(home_away = case_when(str_detect(opponent, "[@]") ~ "Away",
                                          TRUE ~ "Home"),
         opponent = str_remove(opponent, "(@|vs)"),
         weekday = factor(str_extract(date, "[^,]*"),
                          levels = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")),
         day = str_extract(date, "[:digit:]+"),
         month = str_extract(date, "(?<=\\s)(.*?)(?=\\s)"),
         att = as.numeric(str_remove(att, ",")),
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



z %>% 
  filter(home_away == "Home") %>% 
  ggplot(aes(weekday, att)) +
  geom_boxplot(alpha = .2) +
  geom_jitter(alpha = .5, size = 2) +
  labs(
    x = "Weekday",
    y = "Game Attendance"
  ) +
  scale_y_continuous(
    limits = c(10000, 50000),
    labels = comma
  ) +
  theme(
    panel.grid = element_blank(),
    panel.background = element_blank(),
    axis.ticks = element_blank()
  )



