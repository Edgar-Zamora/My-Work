library(tidyverse)
library(spotifyr)
library(knitr)
library(ggtext)
library(gt)
library(glue)
library(extrafont)


# --------------------------------------------------------------
#https://developer.spotify.com/dashboard/
Sys.setenv(SPOTIFY_CLIENT_ID = '')
Sys.setenv(SPOTIFY_CLIENT_SECRET = '')

access_token <- get_spotify_access_token()


# --------------------------------------------------------------
track_info <- function(artist) {
  
  track_data <- get_artist_audio_features({{artist}}) %>%
    mutate(artist = {{artist}}) %>%
    tibble()
  
  return(track_data)
}


x <- track_info("Bad Bunny")


track_ids <- x %>% 
  pull(track_id)


track_popularity <- function(track_id) {
  
  get_track({{track_id}}) %>% 
    pluck("popularity") %>%
    tibble() %>%
    rename("popularity" = ".") %>% 
    mutate(track_id = {{track_id}})
  
}

track_popularity <- map_df(track_ids, track_popularity)


# --------------------------------------------------------------

x %>%
  left_join(track_popularity, by = "track_id") %>% 
  filter(album_name == "YHLQMDLG") %>%
  unnest(album_images) %>%
  distinct(track_name, url, track_preview_url, loudness, danceability, popularity) %>% 
  group_by(track_name) %>%
  slice(1) %>%
  ungroup() %>% 
  mutate(track_preview_url = glue('<audio controlsList="nodownload" controls src="{track_preview_url}"></audio>')) %>%
  gt() %>% 
  fmt_markdown(columns = vars(track_preview_url)) %>%
  text_transform(
    locations = cells_body(vars(url)),
    fn = function(x){
      web_image(url = x, height = 80)
    }
  ) %>%
  cols_label(
    track_preview_url = md(" Lets Hear It &#127911;"),
    url = " ", 
    track_name = "Track Name"
  ) %>% 
  tab_style(
    style = cell_text(font = "Againts", size = px(60), color = "white"),
    locations = cells_title()
  ) %>% 
  tab_style(
    style = cell_fill(color = "black"),
    locations = cells_title("title")
  ) %>% 
  tab_header(
    title = "Bad Bunny"
  ) 






  