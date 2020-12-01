
# Bad Bunny :rabbit:

# Retrieving the data :cd:

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
library(rmarkdown)

Sys.setenv(SPOTIFY_CLIENT_ID = 'xxxxxxxx')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'xxxxxxxx')

access_token <- get_spotify_access_token()
```

Once you have done that you are all ready to go\!\!

## Track features and popularity

The `spotifyr` package offers a lot of functions when it comes to
accessing information from the Spotify Web API of which can not all be
covered in this post so I encourage y’all to explore it further. For
this post we will cover the `get_artist_audio_features()` function which
retrieves a list of all the features for a track from a given artist.
Note that this excludes singles that may have garnered a lot of
attention that are later put into the full released album. In the case
of Bad Bunny, Callaíta and Dakiti and received a lot of praise with the
latter being include in an album.

To be able to extrapolate to other artists, I decided to put use the
`get_artist_audio_features()` function within my own function,
`track_info()`, to retrieve audio features for artists. If the
`get_artist_audio_features()` function is only used be aware that the
function does not return results as a tibble.

``` r
track_info <- function(artist) {
  
  track_data <- get_artist_audio_features({{artist}}) %>%
    mutate(artist = {{artist}}) %>%
    tibble()
  
  return(track_data)
}


bad_bunny_tracks <- track_info("Bad Bunny")
```

After retrieving the audio features for each of Bad Bunny’s tracks, I
proceed to get the popularity of each track based on Spotify’s
algorithm. To be able to get the popularity of a track we need each
track unique id which is provided to us. Using the `pluck()` function we
can, pluck lol, the id of each track to feed into the function that we
create below. Similar to the custom made `track_info()` function, we
create a `track_popularity()` function with the `get_track()` function
from `spotifyr` as the core function.

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

To retrieve the actual popularity ratings we use the `map_df()` from the
`purrr` package to iterate each track id through the `track_popularity`
function with the final object being stored as a data frame. Again we
decide to take this functional approach to allow other to apply the same
methodology to other artists.

After having run the code above, we are left with a lot of tracks with
not a lot of space to visualize it. For these reasons, we decide that it
would be appropriate to choose the top 10 most popular Bad Bunny tracks,
which is what is done below.

``` r
bad_bunny_compl_track <- bad_bunny_tracks %>%
  left_join(track_popularity, by = "track_id") %>% 
  mutate(track_name = case_when(track_name == "LA CANCIÓN" ~ "LA CANCION",
                                track_name == "Si Veo a Tu Mamá" ~ "Si Veo a Tu Mama",
                                track_name == "La Difícil" ~ "La Dificil",
                                track_name == "Si Estuviésemos Juntos" ~ "  Si Estuviesemos Juntos",
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
  select(url, track_name, popularity, danceability, valence, energy,  track_preview_url)
```

When we originally retrieved the Spotify data, you may have noticed two
really cool features, album image and track preview url. These two
features are usually available for each track and we will be using them
in the `gt` table.

# Building a `gt` table

<!--html_preserve-->

<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#rsxadbdexs .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 3px;
  border-bottom-color: white;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#rsxadbdexs .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#rsxadbdexs .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#rsxadbdexs .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 4px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#rsxadbdexs .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#rsxadbdexs .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#rsxadbdexs .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#rsxadbdexs .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#rsxadbdexs .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#rsxadbdexs .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#rsxadbdexs .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#rsxadbdexs .gt_group_heading {
  padding: 8px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#rsxadbdexs .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#rsxadbdexs .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#rsxadbdexs .gt_from_md > :first-child {
  margin-top: 0;
}

#rsxadbdexs .gt_from_md > :last-child {
  margin-bottom: 0;
}

#rsxadbdexs .gt_row {
  padding-top: 7px;
  padding-bottom: 7px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: white;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#rsxadbdexs .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 12px;
}

#rsxadbdexs .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#rsxadbdexs .gt_first_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
}

#rsxadbdexs .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#rsxadbdexs .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#rsxadbdexs .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#rsxadbdexs .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#rsxadbdexs .gt_footnote {
  margin: 0px;
  font-size: 10px;
  padding: 4px;
}

#rsxadbdexs .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#rsxadbdexs .gt_sourcenote {
  font-size: 90%;
  padding: 4px;
}

#rsxadbdexs .gt_left {
  text-align: left;
}

#rsxadbdexs .gt_center {
  text-align: center;
}

#rsxadbdexs .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#rsxadbdexs .gt_font_normal {
  font-weight: normal;
}

#rsxadbdexs .gt_font_bold {
  font-weight: bold;
}

#rsxadbdexs .gt_font_italic {
  font-style: italic;
}

#rsxadbdexs .gt_super {
  font-size: 65%;
}

#rsxadbdexs .gt_footnote_marks {
  font-style: italic;
  font-size: 65%;
}
</style>

<div id="rsxadbdexs" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">

<table class="gt_table" style="table-layout: fixed; width: 1250px">

<colgroup>

<col style="width: 120px"/>

<col style="width: 300px"/>

<col style="width: 120px"/>

<col style="width: 120px"/>

<col style="width: 120px"/>

<col style="width: 120px"/>

<col style="width: 350px"/>

</colgroup>

<thead class="gt_header">

<tr>

<th colspan="7" class="gt_heading gt_title gt_font_normal" style="color: white; font-family: Againts; font-size: 65px; background-color: #000000;">

Bad Bunny
<img src='https://1000marcas.net/wp-content/uploads/2020/01/Bad-Bunny-emblema.jpg' width='100' height='60' style='vertical-align:middle'>

</th>

</tr>

<tr>

<th colspan="7" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style>

</th>

</tr>

</thead>

<thead class="gt_col_headings">

<tr>

<th class="gt_col_heading gt_center gt_columns_bottom_border" rowspan="2" colspan="1" style="border-bottom-width: 3px; border-bottom-style: solid; border-bottom-color: black; border-top-width: 3px; border-top-style: solid; border-top-color: white;">

</th>

<th class="gt_col_heading gt_center gt_columns_bottom_border" rowspan="2" colspan="1" style="border-bottom-width: 3px; border-bottom-style: solid; border-bottom-color: black; border-top-width: 3px; border-top-style: solid; border-top-color: white;">

Track Name

</th>

<th class="gt_col_heading gt_center gt_columns_bottom_border" rowspan="2" colspan="1" style="border-bottom-width: 3px; border-bottom-style: solid; border-bottom-color: black; border-top-width: 3px; border-top-style: solid; border-top-color: white;">

Popularity<sup class="gt_footnote_marks">1</sup>

</th>

<th class="gt_center gt_columns_top_border gt_column_spanner_outer" rowspan="1" colspan="3">

<span class="gt_column_spanner">Track Audio Features 💿</span>

</th>

<th class="gt_col_heading gt_center gt_columns_bottom_border" rowspan="2" colspan="1" style="border-bottom-width: 3px; border-bottom-style: solid; border-bottom-color: black; border-top-width: 3px; border-top-style: solid; border-top-color: white;">

Preview The Track 🎧

</th>

</tr>

<tr>

<th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="border-bottom-width: 3px; border-bottom-style: solid; border-bottom-color: black; border-top-width: 3px; border-top-style: solid; border-top-color: white;">

Danceability<sup class="gt_footnote_marks">2</sup>

</th>

<th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="border-bottom-width: 3px; border-bottom-style: solid; border-bottom-color: black; border-top-width: 3px; border-top-style: solid; border-top-color: white;">

Energy<sup class="gt_footnote_marks">3</sup>

</th>

<th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="border-bottom-width: 3px; border-bottom-style: solid; border-bottom-color: black; border-top-width: 3px; border-top-style: solid; border-top-color: white;">

Valence<sup class="gt_footnote_marks">4</sup>

</th>

</tr>

</thead>

<tbody class="gt_table_body">

<tr>

<td class="gt_row gt_left">

<img src="https://i.scdn.co/image/ab67616d0000b273548f7ec52da7313de0c5e4a0" style="height:80px;">

</td>

<td class="gt_row gt_center" style="font-family: Colors Of Autumn; font-size: 20px;">

Safaera

</td>

<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #23A6E1;">

85

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.61

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.83

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.69

</td>

<td class="gt_row gt_left">

<div class="gt_from_md">

<p>

<audio controlsList="nodownload" controls src="https://p.scdn.co/mp3-preview/c67f59e5d3806b41f54f772ba8cc24410ed0a258?cid=9d31a6fe89fc4bbda898cd726a12d593">

</audio>

</p>

</div>

</td>

</tr>

<tr>

<td class="gt_row gt_left">

<img src="https://i.scdn.co/image/ab67616d0000b2734891d9b25d8919448388f3bb" style="height:80px;">

</td>

<td class="gt_row gt_center" style="font-family: Colors Of Autumn; font-size: 20px;">

LA CANCION

</td>

<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #DCAE36;">

84

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.75

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.65

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.43

</td>

<td class="gt_row gt_left">

<div class="gt_from_md">

<p>

<audio controlsList="nodownload" controls src="NA">

</audio>

</p>

</div>

</td>

</tr>

<tr>

<td class="gt_row gt_left">

<img src="https://i.scdn.co/image/ab67616d0000b273548f7ec52da7313de0c5e4a0" style="height:80px;">

</td>

<td class="gt_row gt_center" style="font-family: Colors Of Autumn; font-size: 20px;">

La Santa

</td>

<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #DCAE36;">

84

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.74

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.87

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.59

</td>

<td class="gt_row gt_left">

<div class="gt_from_md">

<p>

<audio controlsList="nodownload" controls src="https://p.scdn.co/mp3-preview/0fba2ae7b6f5588e301a6c0008914e1e864b6e66?cid=9d31a6fe89fc4bbda898cd726a12d593">

</audio>

</p>

</div>

</td>

</tr>

<tr>

<td class="gt_row gt_left">

<img src="https://i.scdn.co/image/ab67616d0000b273548f7ec52da7313de0c5e4a0" style="height:80px;">

</td>

<td class="gt_row gt_center" style="font-family: Colors Of Autumn; font-size: 20px;">

Si Veo a Tu Mama

</td>

<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #DCAE36;">

84

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.90

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.60

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.82

</td>

<td class="gt_row gt_left">

<div class="gt_from_md">

<p>

<audio controlsList="nodownload" controls src="https://p.scdn.co/mp3-preview/030b0d06fd4154482d5cb122b5c8c6678c86f666?cid=9d31a6fe89fc4bbda898cd726a12d593">

</audio>

</p>

</div>

</td>

</tr>

<tr>

<td class="gt_row gt_left">

<img src="https://i.scdn.co/image/ab67616d0000b273548f7ec52da7313de0c5e4a0" style="height:80px;">

</td>

<td class="gt_row gt_center" style="font-family: Colors Of Autumn; font-size: 20px;">

Yo Perreo Sola

</td>

<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #DCAE36;">

84

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.86

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.76

</td>

<td class="gt_row gt_center" style="font-size: 20px; color: #156594; font-weight: bold;">

0.45

</td>

<td class="gt_row gt_left">

<div class="gt_from_md">

<p>

<audio controlsList="nodownload" controls src="https://p.scdn.co/mp3-preview/3575ce15e6727094dc606c9d29e79f5830340172?cid=9d31a6fe89fc4bbda898cd726a12d593">

</audio>

</p>

</div>

</td>

</tr>

<tr>

<td class="gt_row gt_left">

<img src="https://i.scdn.co/image/ab67616d0000b273548f7ec52da7313de0c5e4a0" style="height:80px;">

</td>

<td class="gt_row gt_center" style="font-family: Colors Of Autumn; font-size: 20px;">

La Dificil

</td>

<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #EDCC29;">

83

</td>

<td class="gt_row gt_center" style="font-size: 20px; color: #156594; font-weight: bold;">

0.69

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.85

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.76

</td>

<td class="gt_row gt_left">

<div class="gt_from_md">

<p>

<audio controlsList="nodownload" controls src="https://p.scdn.co/mp3-preview/b368a8887077ef0d389964973e2ee298f1b03948?cid=9d31a6fe89fc4bbda898cd726a12d593">

</audio>

</p>

</div>

</td>

</tr>

<tr>

<td class="gt_row gt_left">

<img src="https://i.scdn.co/image/ab67616d0000b273005ee342f4eef2cc6e8436ab" style="height:80px;">

</td>

<td class="gt_row gt_center" style="font-family: Colors Of Autumn; font-size: 20px;">

LA NOCHE DE ANOCHE

</td>

<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #EDCC29;">

83

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.86

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.62

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.39

</td>

<td class="gt_row gt_left">

<div class="gt_from_md">

<p>

<audio controlsList="nodownload" controls src="https://p.scdn.co/mp3-preview/a71a9aa2416897c325e1018059d18090a7762c91?cid=9d31a6fe89fc4bbda898cd726a12d593">

</audio>

</p>

</div>

</td>

</tr>

<tr>

<td class="gt_row gt_left">

<img src="https://i.scdn.co/image/ab67616d0000b2732fbd77033247e889cb7d2ac4" style="height:80px;">

</td>

<td class="gt_row gt_center" style="font-family: Colors Of Autumn; font-size: 20px;">

Si Estuviesemos Juntos

</td>

<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #FBEB04;">

82

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.67

</td>

<td class="gt_row gt_center" style="font-size: 20px; color: #156594; font-weight: bold;">

0.59

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.16

</td>

<td class="gt_row gt_left">

<div class="gt_from_md">

<p>

<audio controlsList="nodownload" controls src="https://p.scdn.co/mp3-preview/340f2b16c8f2e94de4f3892e19a9b336573552db?cid=9d31a6fe89fc4bbda898cd726a12d593">

</audio>

</p>

</div>

</td>

</tr>

<tr>

<td class="gt_row gt_left">

<img src="https://i.scdn.co/image/ab67616d0000b273548f7ec52da7313de0c5e4a0" style="height:80px;">

</td>

<td class="gt_row gt_center" style="font-family: Colors Of Autumn; font-size: 20px;">

A Tu Merced

</td>

<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #FBEB04;">

82

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.86

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.79

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.89

</td>

<td class="gt_row gt_left">

<div class="gt_from_md">

<p>

<audio controlsList="nodownload" controls src="https://p.scdn.co/mp3-preview/fa010f780196cdaba49c019c9153a37a57b157c6?cid=9d31a6fe89fc4bbda898cd726a12d593">

</audio>

</p>

</div>

</td>

</tr>

<tr>

<td class="gt_row gt_left">

<img src="https://i.scdn.co/image/ab67616d0000b273005ee342f4eef2cc6e8436ab" style="height:80px;">

</td>

<td class="gt_row gt_center" style="font-family: Colors Of Autumn; font-size: 20px;">

TE MUDASTE

</td>

<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #FBEB04;">

82

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.81

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.64

</td>

<td class="gt_row gt_center" style="font-size: 18.5px;">

0.47

</td>

<td class="gt_row gt_left">

<div class="gt_from_md">

<p>

<audio controlsList="nodownload" controls src="https://p.scdn.co/mp3-preview/4f49b842c112f64c7c0500efaad9583437c2f7f7?cid=9d31a6fe89fc4bbda898cd726a12d593">

</audio>

</p>

</div>

</td>

</tr>

</tbody>

<tfoot class="gt_sourcenotes">

<tr>

<td class="gt_sourcenote" colspan="7">

<strong>Data</strong>: Spotify Web API

</td>

</tr>

</tfoot>

<tfoot>

<tr class="gt_footnotes">

<td colspan="7">

<p class="gt_footnote">

<sup class="gt_footnote_marks"> <em>1</em> </sup>

<strong>Popularity</strong> is calculated by algorithm and is based, in
the most part, on the total number of plays the track has had and how
recent those plays are. <br />

</p>

<p class="gt_footnote">

<sup class="gt_footnote_marks"> <em>2</em> </sup>

<strong>Danceability</strong> is a measure based on a combination of
musical elements including tempo, rhythm stability, beat strenght, and
overall regularity <br />

</p>

<p class="gt_footnote">

<sup class="gt_footnote_marks"> <em>3</em> </sup>

<strong>Energy</strong> represents a perceptual measure of intensity and
activity in a track. High energy resembles death metal while low
resembles Bach. <br />

</p>

<p class="gt_footnote">

<sup class="gt_footnote_marks"> <em>4</em> </sup>

<strong>Valence</strong> describes the positiveness conveyed by a track.
high valence sound more positive (e.g. happy, cheerful, euphoric), while
tracks with low valence sound more negative (e.g. sad, depressed, angry)
<br />

</p>

</td>

</tr>

</tfoot>

</table>

</div>

<!--/html_preserve-->
