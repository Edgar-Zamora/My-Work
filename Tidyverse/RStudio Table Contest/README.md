Bad Bunny :rabbit:
==================

Retrieving the data :cd:
========================

To explore some of the features present in Bad Bunny’s music, I use the
`spotifyr` [package](https://github.com/charlie86/spotifyr) which is an
R wrapper for pulling track audio features and other information from
Spotify’s Web API. In order to access the Spotify Web API, it is
required that you have a Spotify account (free subscription works) of
which to connect a Spotify developer account. To create Spotify
developer account you can go to their their
[dashboard](https://developer.spotify.com/dashboard/). After logging in
you will need to “create an app” which will provide you with a **Client
ID** and **Client Secret** which important in setting up a connection to
the API. After doing that you will have to save those tokens as an
object as so:

``` r
library(tidyverse)
library(spotifyr)
library(knitr)
library(ggtext)
library(gt)
library(glue)
library(extrafont)

Sys.setenv(SPOTIFY_CLIENT_ID = 'xxxxxxxx')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'xxxxxxxx')

access_token <- get_spotify_access_token()
```

Once you have done that you are all ready to go!!

Track features and popularity
-----------------------------

The `spotifyr` package offers a lot of functions when it comes to
accessing information from the Spotify Web API of which can not all be
covered in this post so I encourage y’all to explore it further. For
this post we will cover the `get_artist_audio_features()` function which
retrieves a list of all the features for a track from a given artist.
The primary argument needed in this function is the name of the artist
with proper capitalization.

``` r
track_info <- function(artist) {
  
  track_data <- get_artist_audio_features({{artist}}) %>%
    mutate(artist = {{artist}}) %>%
    tibble()
  
  return(track_data)
}


bad_bunny_tracks <- track_info("Bad Bunny")
```

``` r
track_ids <- bad_bunny_tracks %>% 
  pull(track_id)


track_popularity <- function(track_id) {
  
  get_track({{track_id}}) %>% 
    pluck("popularity") %>%
    tibble() %>%
    rename("popularity" = ".") %>% 
    mutate(track_id = {{track_id}})
  
}

track_popularity <- map_df(track_ids, track_popularity)
```

Building a `gt` table
=====================
