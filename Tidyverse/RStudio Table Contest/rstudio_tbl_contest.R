library(tidyverse)
library(spotifyr)
library(knitr)
library(ggtext)
library(gt)
library(glue)
library(extrafont)

# --------------------------------------------------------------
#https://developer.spotify.com/dashboard/
Sys.setenv(SPOTIFY_CLIENT_ID = '9d31a6fe89fc4bbda898cd726a12d593')
Sys.setenv(SPOTIFY_CLIENT_SECRET = '79c0d581fa314b999d6f747e380dd412')

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
  mutate(track_name = case_when(track_name == "LA CANCIÓN" ~ "LA CANCION",
                                track_name == "Si Veo a Tu Mamá" ~ "Si Veo a Tu Mama",
                                track_name == "La Difícil" ~ "La Dificil",
                                track_name == "Si Estuviésemos Juntos" ~ "	Si Estuviesemos Juntos",
                                track_name == "CANCIÓN CON YANDEL" ~ "CANCION CON YANDEL",
                   TRUE ~ track_name)) %>%
  unnest(album_images) %>%
  distinct(track_name, url, track_preview_url, valence, danceability, energy, popularity) %>% 
  group_by(track_name) %>%
  slice(1) %>%
  ungroup() %>% 
  arrange(-popularity) %>% 
  slice(1:10) %>% 
  mutate(track_preview_url = glue('<audio controlsList="nodownload" controls src="{track_preview_url}"></audio>')) %>%
  select(url, track_name, popularity, danceability, valence, energy,  track_preview_url) %>% 
  gt() %>% 
  fmt_markdown(columns = vars(track_preview_url)) %>%
  fmt_number(
    columns = vars(danceability, energy, valence),
    decimals = 2
  ) %>% 
  text_transform(
    locations = cells_body(vars(url)),
    fn = function(x){
      web_image(url = x, height = 80)
    }
  ) %>%
  cols_align(
    align = "center",
    columns = vars(track_name, danceability, valence, energy, popularity)
  ) %>%
  cols_width(
    vars(track_name) ~ px(300)
  ) %>% 
  cols_label(
    track_preview_url = md(" Lets Hear It &#127911;"),
    url = " ", 
    track_name = "Track Name",
    popularity = "Popularity",
    danceability = "Danceability",
    valence = "Valence",
    energy = "Energy"
  ) %>% 

  tab_spanner(
    label = md("Track Audio Features &#128191;"),
    columns = vars(danceability, energy, valence)
  ) %>% 
  tab_style(
    style = list(cell_text(font = "Againts", 
                           size = px(65), 
                           color = "white"),
                 cell_fill(color = "black")),
    locations = cells_title("title")
  ) %>% 
  tab_style(
    style = cell_text(
      font = "Colors Of Autumn",
      size = px(20)),
    locations = cells_body(vars(track_name))
  ) %>% 
  tab_style(
    style = cell_borders(
      sides = c("left", "right"),
      color = "black",
      weight = px(3)),
    locations = cells_body(columns = vars(popularity))
  ) %>% 
  tab_style(
    style = cell_borders(
      sides = c("bottom"),
      color = "black",
      weight = px(3)),
    locations = cells_column_labels(columns = everything())
    ) %>% 
  tab_style(
    style = cell_text(
      size = px(15)),
    locations = cells_body(vars(popularity, danceability, energy,
                     valence)) 
  ) %>% 
  tab_style(
    style = cell_text(
      weight = "bold",
      color = "#156594",
      size = px(17)
    ),
    locations = list(
      cells_body(columns=c(4), rows=c(6)),
      cells_body(columns=c(5), rows=c(5)),
      cells_body(columns=c(6), rows=c(8))
    )) %>% 
  tab_style(
    style = list(
      cell_borders(
        sides = c("top"),
        color = "white",
        weight = px(3))
      ),
    locations = cells_column_labels(columns = everything())
  ) %>% 
  tab_header(
    title = md("Bad Bunny <img src='https://1000marcas.net/wp-content/uploads/2020/01/Bad-Bunny-emblema.jpg' width='100' height='60' style='vertical-align:middle'> ")
  )  %>% 
  tab_footnote(
    footnote = "Popularity is calculated by algorithm and is based, in the most part, on the total number of plays the track has had and how recent those plays are.",
    locations = cells_column_labels(
      columns = vars(popularity))
  ) %>% 
  tab_options(
    table_body.hlines.color = "white",
    table.border.bottom.color = "white",
    table.border.bottom.width = px(3),
    data_row.padding = px(7),
    footnotes.font.size = px(11)
  ) %>% 
  tab_source_note(source_note = md("**Data**: Spotify Web API"))



  