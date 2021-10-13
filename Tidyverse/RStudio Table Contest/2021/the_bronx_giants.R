# Load packages
library(rvest)
library(tidyr)
library(dplyr)
library(janitor)
library(rvest)
library(stringr)
library(glue)
library(purrr)
library(gt)
library(measurements)
library(mlbstatsR)
library(scales)
library(webshot)



# Helper functions
## Convert feet inches (6' 4") to cm to help find team averages
ft_inch <- function(str_ft_inch){
  elem <- as.integer(unlist(strsplit(str_ft_inch, "'")))
  inch <- elem[1]*12 + elem[2]
  return(conv_unit(inch, "inch", "cm"))
}



# Loading data
## team images
team_logos <- mlbstatsR::get_png_logos() %>% 
  select(-team_name) %>% 
  mutate(across(c(team_nickname), str_to_lower),
         full_name = case_when(full_name == 'St. Louis Cardinals' ~ "St Louis Cardinals",
                               TRUE ~ full_name)) %>% 
  rename(
    team_abbr = team_nickname,
    team_name = full_name
  )



team_urls <- mlbstatsR::get_mlb_teams() %>% 
  tibble() %>% 
  select(name, team) %>% 
  mutate(across(team, str_to_lower),
         team = case_when(team == 'sdp' ~ "sd",
                          team == 'sfg' ~ "sf",
                          team == "tbr" ~ "tb",
                          team == "wsn" ~ "wsh",
                          team == "kcr" ~ "kc",
                          TRUE ~ team),
         name = str_remove(name, "[.]"),
         url_team_name = str_replace_all(str_to_lower(name), " ", "-"),
         team_url = paste0(team,"/",url_team_name)) %>% 
  rename(
    team_name = name,
    team_abbr = team
  )
  


# Mapping through is to download player physical characteristics
urls <- team_urls %>% 
  distinct(team_url) %>% 
  pull()




get_player_char <- function(url){
  
  urls <- glue::glue("https://www.espn.com/mlb/team/roster/_/name/{url}")
  
  
  player_img <- urls %>% 
    read_html() %>% 
    html_nodes(".silo img") %>% 
    html_attr("alt")
  
  
  df <- urls %>% 
  read_html() %>% 
  html_table() %>% 
  map(., clean_names) %>% 
  map_df(., rbind) %>%
  rename(
    wt_lbs = wt,
    bat_hand = bat,
    thw_hand = thw
    ) %>%
  separate(birth_place, into = c("city", "state_country"), sep = ", ") %>%
  mutate(team_name = str_extract(url, "[\\/].*"),
         gen_pos = case_when(str_detect(pos, "P") ~ "Pitcher",
                             pos == "C" ~ "Catcher",
                             pos == "DH" ~ "Disginated Hitter",
                             str_detect(pos, "F") ~ "Outfielder",
                             TRUE ~ "Infielder"),
         ht_cm = map_dbl(str_squish(str_remove(ht, "\"")), ft_inch),
         player_number = str_extract(name, "\\d+"),
         wt_lbs = as.numeric(str_trim(str_remove_all(wt_lbs, "[:alpha:]"))),
         name = str_remove_all(name, "\\d"),
         team_name = str_remove(team_name, "[\\/]"),
         team_name = str_to_title(str_replace_all(team_name, "-", " ")),
         x = player_img) %>%
    left_join(team_logos, by = "team_name")
  
  
  return(df)
  
}


all_mlb_players <- map_df(urls, get_player_char)



# Max Players
## Weight
max_weight <- all_mlb_players %>% 
  group_by(team_name)  %>% 
  filter(wt_lbs == max(wt_lbs)) %>% 
  slice(1) %>% 
  ungroup() %>% 
  select(team_name, name, x, pos, wt_lbs, player_number) %>% 
  mutate(max_weight = paste0("<div style='display: flex; align-items:center;'><img src='", 
                             x, 
                             "' alt='", 
                             name, 
                             "'width=100 height=75 style='float:left'><div><span>",
                             name,
                             "</span><br><span><center><span style='color:#B4B4B4'>", 
                             pos, "</span>",
                             " | ", wt_lbs, 
                             " lbs </center></span</div></div>"))



## Height
max_ht <- all_mlb_players %>% 
  group_by(team_name) %>% 
  filter(ht_cm == max(ht_cm)) %>% 
  slice(1) %>% 
  ungroup() %>% 
  mutate(max_ht = paste0("<div style='display: flex; align-items:center;'><img src='", 
                         x, 
                         "' alt='", 
                         name, 
                         "'width=100 height=75 style='float:left'><div><span>",
                         name,
                         "</span><br><span><center><span style='color:#B4B4B4'>", 
                         pos, "</span>",
                         " | ",ht, 
                         "</center></span</div></div>")) %>% 
  select(team_name, max_ht)


## Max Age
max_age <- all_mlb_players %>%
  group_by(team_name) %>% 
  filter(age == max(age)) %>% 
  slice(1) %>% 
  ungroup() %>% 
  mutate(max_age =  paste0("<div style='display: flex; align-items:center;'><img src='", 
                           x, 
                           "' alt='", 
                           name, 
                           "'width=100 height=75 style='float:left'><div><span>",
                           name,
                           "</span><br><span><center><span style='color:#B4B4B4'>", 
                           pos, "</span>",
                           " | ", age, 
                           "</center></span</div></div>")) %>% 
  select(team_name, max_age)






# Prepping data
gt_data <- all_mlb_players %>% 
  mutate(team_name_gt = paste0("<div style='display: flex; align-items:center;'><img src='", 
                               logologodefault, 
                               "' alt='", 
                               team_name, 
                               "'width=50 height=50 style='float:left'><div><span>&nbsp;&nbsp;",
                               team_name,
                               "</span><br><span></span</div></div>")) %>% 
  group_by(team_name, team_name_gt) %>% 
  summarise(
    avg_age = mean(age),
    avg_ht = mean(ht_cm),
    avg_weight = mean(wt_lbs)
  ) %>% 
  left_join(max_age, by = "team_name") %>% 
  left_join(max_ht, by = 'team_name') %>% 
  left_join(max_weight, by = "team_name") %>% 
  ungroup() %>% 
  select(team_name_gt, starts_with("avg"), max_age, max_ht, max_weight)
  

# Tablizing
mlb_gaints <- gt_data %>% 
  gt() %>% 
  fmt_markdown(
    columns = c(team_name_gt, starts_with("max"))
  ) %>% 
  fmt_number(
    columns = c(starts_with("avg")),
    decimals = 0
  ) %>% 
  
  # Formating Columns
  cols_label(
    team_name_gt = ' ',
    avg_age = "Age",
    avg_ht = "Height (cm)",
    avg_weight = "Weight (lbs)",
    max_age = "Age",
    max_ht = "Height (ft)",
    max_weight = "Weight (lbs)",
  ) %>% 
  cols_align(
    columns = c(starts_with("avg"), starts_with("max")),
    align = "center"
  ) %>% 
  cols_width(
    team_name_gt ~ px(300),
    starts_with("avg") ~ px(75),
    starts_with("max") ~ px(250)
  ) %>% 
  tab_header(
    title = "MLB's Biggest Teams"
  ) %>% 
  tab_spanner(
    label = "Team Averages",
    columns = c(starts_with("avg"))
  ) %>% 
  tab_spanner(
    label = "Top Players From Team",
    columns = c(starts_with("max"))
  ) %>% 
  
  # Styling specific cells
  tab_style(
    style = list(
      cell_borders(
        sides = "left",
        color = "black",
        weight = px(6)
      )
    ),
    locations = list(
      cells_body(
        columns = c(max_age)
      )
    )
  ) %>% 
  tab_style(
    style = list(
      cell_text(size = px(22))
    ),
    locations = cells_body(
      columns = c(team_name_gt)
    )
  ) %>% 
  tab_style(
    style = list(
      cell_text(size = px(18))
    ),
    locations = cells_body(
      columns = starts_with("avg")
    )
  ) %>% 
  
  # General table options
  tab_options(
    table.border.top.color = "white",
    table.border.bottom.color = "white",
    heading.title.font.size = px(30),
  ) %>% 
  opt_table_font(
    font = c(
      "DIN Condensed"
    )
  ) %>% 
  
  # Footnotes
  tab_footnote(
    footnote = "When there was a tie I considered age and height. This is my decision and arbitrary.",
    locations = cells_column_spanners(
      spanners = "Top Players From Team"
    )
  ) %>% 
  tab_footnote(
    footnote = md("Using *cm* instead of *ft* allows one to see the distribution better."),
    locations = cells_column_labels(
      columns = avg_ht
    )
  ) %>% 
  
  # Coloring team averages with darker being a higher value
  data_color(
    columns = starts_with("avg"),
    colors = col_numeric(
      palette = c("#F2EDDC", "#DCE5BA", "#AED898", "#77CA7F", "#35AEAB"),
      domain = NULL
    )
  )


# Writing table
gtsave(mlb_gaints, here::here("Tidyverse", "RStudio Table Contest", "2021", "MLB's Biggest Teams.pdf"))
