mlbscrapR("SEA", '2021')

# Database name: MLB Stats

# Table: OUTCOMES
# This table contains outcomes for each game with revelant info
get_outcome <- function(team, year) {
  
  url <- paste0("https://www.baseball-reference.com/teams/", team, "/", year, "-schedule-scores.shtml")
  
  session <- bow(url)
  
  scrape(session) %>% 
    html_element("table") %>% 
    html_table() %>%  
    clean_names() %>% 
    filter(tm != "Tm") %>% 
    select(gm_number, opp, w_l, r, ra, inn) %>% 
    mutate(
      walkoff = case_when(str_detect(w_l, "wo") ~ 1,
                          TRUE ~ 0),
      forfeit = case_when(str_detect(w_l, "&V") ~ 1,
                          TRUE ~ 0),
      w_l = str_remove_all(w_l, "-wo|&V"),
      inn = case_when(inn == "" ~ 0,
                      TRUE ~ as.numeric(inn)),
      extra_innings = case_when(inn >= 9 ~ 1,
                                TRUE ~ 0)) %>% 
    rename(
      win_lose = w_l
    )
  
}


get_outcome("SEA", 2021)



# Table: TEAM_NAMES
# This table will  contain information about each team including their
# official name, abbreviated name, team colors and other information.
get_team_names <- function() {
  
  mlbstatsR::get_mlb_teams() %>% 
  select(name, liga, division, team, primary, secondary) %>% 
  as_tibble() %>% 
  rename(
    full_team_name = name,
    league_name = liga,
    team_abb = team,
    primary_color = primary,
    secondary_color = secondary
  )
  
}

get_team_names()
