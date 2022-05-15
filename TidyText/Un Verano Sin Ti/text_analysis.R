# Load packages 
library(tidyverse)
library(tidytext)
library(geniusr)
library(janitor)
library(dplyr)
library(xml2)
library(rvest)


source("helper_fun.R")

# Spanish stop words
span_stop_words <- read_csv("stop_words_spanish.txt", col_names = c("word"))


un_verano_sin_ti <- geniusr::get_album_tracklist_search(artist_name = "Bad Bunny",
                                                        album_name = "Un Verano Sin Ti")


songs <- un_verano_sin_ti |> 
  pull(song_title)


song_meta <- map(songs, ~search_song(.)) |> 
  set_names(songs)



un_verano_sin_ti_df <- song_meta |> 
  map_df(~filter(., str_detect(artist_name, "Bad Bunny"))) |> 
  filter(!song_id %in% c("3039781", "4606814", "4662262")) |> 
  distinct_all() |> 
  rename(song_title = song_name) |>
  mutate(song_number = row_number()) |> 
  select(song_id, song_number, song_title, song_lyrics_url, artist_id, artist_name)


song_id <- un_verano_sin_ti_df |> 
  pull(song_id)



song_lyrics <- map_df(song_id, get_lyrics_id)



song_lyrics |> 
  rename(text = line)  |> 
  mutate(across(text, ~str_remove_all(., "[:punct:]")),
         line = row_number(),
         text= stringi::stri_trans_general(text, 
                                            id = 'Latin-ASCII')) |> 
  select(line, text) |> 
  #group_by(song_name) |> 
  unnest_tokens(word, text) |> 
  anti_join(stop_words) |> # English words
  anti_join(span_stop_words) |> #Spanish words
  filter(!word %in% c("ey", "eh", "tu", "ah", "te", "pa")) |> 
  count(word) |> 
  slice_max(order_by = n, n = 15) |> 
  #mutate(word = reorder_within(word, n, song_name)) |> 
  ggplot(aes(n, word)) +
  geom_col() +
  scale_y_reordered() #+
  # facet_wrap(~song_name, scales = "free_y")
 

