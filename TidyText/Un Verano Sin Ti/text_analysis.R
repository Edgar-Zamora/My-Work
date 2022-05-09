pace("get_lyrics", get_lyrics, "geniusr")

# Load packages 
library(tidyverse)
library(tidytext)
library(geniusr)
library(janitor)
library(dplyr)
library(xml2)
library(rvest)

# 

# Yv2MRm_WATVA45jTN7PLJHENJ0Scel8_OR3XFSywWK9nIx88nCv5r3Hoq6a7BVEH
# EJ0lf1HS6yVn_DZMa_ITXwsIp0EfS0Msl0lUndVr1gmGbFWH0OA9xJDShwV7hibAKVqkVeYwR0kJZLKexGMlFw
# 2QLr07m7XM9z1KLeex8jBIy1sj3njOoM3mpAOPUuAT-Ue5XTY_mi-vnG0O5KAANd


un_verano_sin_ti <- geniusr::get_album_tracklist_search(artist_name = "Bad Bunny",
                                                        album_name = "Un Verano Sin Ti") |> 
  mutate(across(song_title, ~str_remove_all(., "\\sby\\s.*")))



songs <- un_verano_sin_ti |> 
  pull(song_title)


song_meta <- map(songs, ~search_song(.)) |> 
  set_names(songs)



un_verano_sin_ti_df <- song_meta |> 
  map_df(~filter(., str_detect(artist_name, "Bad Bunny"))) |> 
  filter(!song_id %in% c("4606814", "4662262", "3039781", "7977261")) |> 
  distinct_all() |> 
  rename(song_title = song_name) |>
  inner_join(un_verano_sin_ti, by = c("song_title", "song_lyrics_url")) |> 
  select(song_id, song_number, song_title, song_lyrics_url, artist_id, artist_name)



song_id <- un_verano_sin_ti_df |> 
  pull(song_id)



safe_get_lyrics_id <- safely(get_lyrics_id)


z <- map(song_id, safe_get_lyrics_id) |> 
  
  
  
  z

x <- get_lyrics_id(7967967) |> 
  select(line, song_name, song_id)





x |> 
  rename(text = line)  |> 
  mutate(across(text, ~str_remove_all(., "[:punct:]")),
         line = row_number()) |> 
  select(song_name, line, text) |> 
  group_by(song_name) |> 
  unnest_tokens(word, text) |> 
  anti_join(stop_words) |> # only english words
  count(word) |> 
  slice_max(order_by = n, n = 10) |> 
  mutate(word = reorder_within(word, n, song_name)) |> 
  ggplot(aes(n, word)) +
  geom_col() +
  scale_y_reordered()
