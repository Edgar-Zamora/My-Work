# Load packages
#devtools::install_github(repo = "saiemgilani/recruitR")
library(recruitR)
library(tidyverse)
library(gt)
library(fontawesome)
library(htmltools)
library(extrafont)
library(janitor)


# Bring in team info
cfb_team <- read_csv("team_info.csv") %>% 
  clean_names()


# Get most recent recruits
recruits <- cfbd_recruiting_player(year = 2022, recruit_type = "HighSchool") %>% 
  as_tibble() %>% 
  left_join(cfb_team, by = c("committed_to" = "school")) %>% 
  mutate(logos_0 = case_when(is.na(logos_0) ~ " ",
                             TRUE ~ logos_0))


# Star ratings
rating_stars <- function(rating, max_rating = 5) {
  rounded_rating <- floor(rating + 0.5)  # always round up
  
  stars <- lapply(seq_len(max_rating), function(i) {
    if (i <= rounded_rating) fontawesome::fa("star", fill= "#d4af37") else fontawesome::fa("star", fill= "grey")
  })
  
  label <- sprintf("%s out of %s", rating, max_rating)
  
  div_out <- div(title = label, "aria-label" = label, role = "img", stars)
  
  as.character(div_out) %>% 
    gt::html()
}


# Creating gt() table
recruit_tbl <- recruits %>% 
  slice(1:102) %>% 
  mutate(hometown = paste0(city, ", ", state_province, "<br>", school),
         rating_stars = map(stars, rating_stars),
         rating = rating * 100,
         ranking = paste0("<div class='rating-cont'><p>", ranking, "</p></div>")) %>% 
  select(ranking, name, position, hometown, height, weight,
         rating_stars, rating, logos_0, committed_to) %>% 
  gt() %>% 
  fmt_markdown(
    columns = c(hometown, ranking)
  ) %>% 
  cols_hide(
    columns = committed_to
  ) %>% 
  text_transform(
    locations = cells_body(
      columns = c(logos_0)
    ),
    fn = function(x) {
      paste0(web_image(
        url = x,
        height = 70
      ))
    }
  ) %>% 
  fmt_number(
    columns = c(height, rating),
    decimals = 1
  ) %>% 
  tab_style(
    style = cell_fill(
      color = "#DEDEDE"
      ),
    locations = cells_column_labels(
      columns = everything()
    )
  ) %>% 
  tab_style(
    style = cell_text(
      color = "black",
      size = px(35)
    ),
    locations = cells_title(
      groups = "title"
    )
  ) %>% 
  tab_footnote(
    footnote = "Player is uncommitted",
    locations = cells_body(
      columns = name,
      rows = is.na(committed_to)
    )
  ) %>% 
  cols_label(
    ranking = md("**RK**"),
    name = md("**PLAYER**"),
    position = md("**PS**"),
    hometown = md("**HOMETOWN**"),
    height = md("**HT**"),
    weight = md("**WT**"),
    rating_stars = md("**STARS**"),
    rating = md("**GRADE**"),
    logos_0 = md(" ")
  ) %>% 
  opt_css(
    css = '
    
    .gt_left:nth-child(1){
      background-color: #E6E6E6;
      vertical-align: middle;
      }
    
    .rating-cont p{
      text-align: center;
      color: #8A8A8A;
      font-size: 21px;
    }
    
    img+ p {
    float: right;
    }
    
    '
  ) %>% 
  tab_options(
    table.border.top.color = "white",
    table.border.bottom.color = "white",
    table.font.names = "Helvetica Neue Medium",
    table.font.size = px(15),
    footnotes.font.size = px(15)
  )




library(leaflet)
library(htmltools)
library(leaflet.extras)



x <- recruits %>% 
  mutate(across(c(hometown_info_latitude, hometown_info_longitude), as.numeric),
         committed_to = case_when(is.na(committed_to) ~ "Uncommitted",
                                  TRUE ~ committed_to),
         content = paste0("Player: <b>", name, "</b>",
                          "<br> Committed to:<b> ", committed_to, "</b>",
                          "<br> Ranking:<b> ", ranking, "</b>",
                          "<br> Position:<b> ", position, "</b>",
                          " <br>Hometown:<b> ",city, ", ", state_province, "<b>"))



initial_lat = -23.079


leaflet() %>% 
  addTiles() %>% 
  addMarkers(lng = x$hometown_info_longitude,
             lat = x$hometown_info_latitude,
             popup = x$content,
             clusterOptions = markerClusterOptions()) %>% 
  leaflet.extras::addResetMapButton() %>% 
  leaflet.extras::addFullscreenControl()


