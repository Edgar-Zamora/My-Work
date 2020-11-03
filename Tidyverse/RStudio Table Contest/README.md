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

    ## Warning: `mutate_()` is deprecated as of dplyr 0.7.0.
    ## Please use `mutate()` instead.
    ## See vignette('programming') for more help
    ## This warning is displayed once every 8 hours.
    ## Call `lifecycle::last_warnings()` to see where this warning was generated.

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

``` r
bad_bunny_tracks %>%
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
  cols_label(
    track_preview_url = md("Lets Hear It &#127911;"),
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
    style = list(cell_text(font = "Againts", #https://www.dafont.com/againts.font?text=Bad+Bunny
                           size = px(65), 
                           color = "white"),
                 cell_fill(color = "black")),
    locations = cells_title("title")
  ) %>% 
  tab_style(
    style = cell_text(
      font = "Colors Of Autumn", #https://www.dafont.com/colors-of-autumn.font
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
      size = px(18.5)),
    locations = cells_body(vars(popularity, danceability, energy,
                     valence)) 
  ) %>% 
  tab_style(
    style = cell_text(
      weight = "bold",
      color = "#156594",
      size = px(20)
    ),
    locations = list(
      cells_body(columns=c(4), rows=c(6)),
      cells_body(columns=c(5), rows=c(5)),
      cells_body(columns=c(6), rows=c(8))
    )) %>% 
  cols_width(
    vars(track_name) ~ px(300),
    vars(track_preview_url) ~ px(350),
    vars(url, popularity, danceability, energy, valence) ~ px(120)
  )  %>% 
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
    footnote = md("**Popularity** is calculated by algorithm and is based, in the most part, on the total number of plays the track has had and how recent those plays are."),
    locations = cells_column_labels(
      columns = vars(popularity))
  ) %>% 
  tab_footnote(
    footnote = md("**Danceability** is a measure based on a combination of musical elements including tempo, rhythm stability, beat strenght, and overall regularity"),
    locations = cells_column_labels(
      columns = vars(danceability))
  ) %>% 
  tab_footnote(
    footnote = md("**Energy** represents a perceptual measure of intensity and activity in a track. High energy resembles death metal while low resembles Bach."),
    locations = cells_column_labels(
      columns = vars(energy))
  ) %>% 
  tab_footnote(
    footnote = md("**Valence** describes the positiveness conveyed by a track. high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry)"),
    locations = cells_column_labels(
      columns = vars(valence))
  ) %>% 
  tab_options(
    table_body.hlines.color = "white",
    table.border.bottom.color = "white",
    table.border.bottom.width = px(3),
    data_row.padding = px(7),
    footnotes.font.size = px(10)
  ) %>% 
  tab_source_note(source_note = md("**Data**: Spotify Web API")) %>% 
  data_color(
    columns = vars(popularity),
    colors = scales::col_numeric(
      # custom defined values - notice that order matters!
      palette = c('#fbeb04', '#f1d324', '#e5bd30', '#d7a739', '#23a6e1'),
      domain = NULL
    )
  )
```

<!--html_preserve-->
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#iuhvwhpyic .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
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

#iuhvwhpyic .gt_heading {
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

#iuhvwhpyic .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#iuhvwhpyic .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 4px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#iuhvwhpyic .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#iuhvwhpyic .gt_col_headings {
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

#iuhvwhpyic .gt_col_heading {
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

#iuhvwhpyic .gt_column_spanner_outer {
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

#iuhvwhpyic .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#iuhvwhpyic .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#iuhvwhpyic .gt_column_spanner {
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

#iuhvwhpyic .gt_group_heading {
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

#iuhvwhpyic .gt_empty_group_heading {
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

#iuhvwhpyic .gt_from_md > :first-child {
  margin-top: 0;
}

#iuhvwhpyic .gt_from_md > :last-child {
  margin-bottom: 0;
}

#iuhvwhpyic .gt_row {
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

#iuhvwhpyic .gt_stub {
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

#iuhvwhpyic .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#iuhvwhpyic .gt_first_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
}

#iuhvwhpyic .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#iuhvwhpyic .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#iuhvwhpyic .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#iuhvwhpyic .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#iuhvwhpyic .gt_footnotes {
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

#iuhvwhpyic .gt_footnote {
  margin: 0px;
  font-size: 10px;
  padding: 4px;
}

#iuhvwhpyic .gt_sourcenotes {
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

#iuhvwhpyic .gt_sourcenote {
  font-size: 90%;
  padding: 4px;
}

#iuhvwhpyic .gt_left {
  text-align: left;
}

#iuhvwhpyic .gt_center {
  text-align: center;
}

#iuhvwhpyic .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#iuhvwhpyic .gt_font_normal {
  font-weight: normal;
}

#iuhvwhpyic .gt_font_bold {
  font-weight: bold;
}

#iuhvwhpyic .gt_font_italic {
  font-style: italic;
}

#iuhvwhpyic .gt_super {
  font-size: 65%;
}

#iuhvwhpyic .gt_footnote_marks {
  font-style: italic;
  font-size: 65%;
}
</style>
<div id="iuhvwhpyic" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<table class="gt_table" style="table-layout: fixed;; width: 0px">
<colgroup>
<col style="width:120px;"/>
<col style="width:300px;"/>
<col style="width:120px;"/>
<col style="width:120px;"/>
<col style="width:120px;"/>
<col style="width:120px;"/>
<col style="width:350px;"/>
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
Lets Hear It 🎧
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
<td class="gt_row gt_center" style="font-family: &#39;Colors Of Autumn&#39;; font-size: 20px;">
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
<td class="gt_row gt_center">

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
<img src="https://i.scdn.co/image/ab67616d0000b273548f7ec52da7313de0c5e4a0" style="height:80px;">
</td>
<td class="gt_row gt_center" style="font-family: &#39;Colors Of Autumn&#39;; font-size: 20px;">
Yo Perreo Sola
</td>
<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #23A6E1;">
85
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.86
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.76
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.45
</td>
<td class="gt_row gt_center">

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
<img src="https://i.scdn.co/image/ab67616d0000b2734891d9b25d8919448388f3bb" style="height:80px;">
</td>
<td class="gt_row gt_center" style="font-family: &#39;Colors Of Autumn&#39;; font-size: 20px;">
LA CANCION
</td>
<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #DCAE36;">
83
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
<td class="gt_row gt_center">

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
<td class="gt_row gt_center" style="font-family: &#39;Colors Of Autumn&#39;; font-size: 20px;">
La Dificil
</td>
<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #DCAE36;">
83
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.69
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.85
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.76
</td>
<td class="gt_row gt_center">

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
<img src="https://i.scdn.co/image/ab67616d0000b273548f7ec52da7313de0c5e4a0" style="height:80px;">
</td>
<td class="gt_row gt_center" style="font-family: &#39;Colors Of Autumn&#39;; font-size: 20px;">
La Santa
</td>
<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #DCAE36;">
83
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.74
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.87
</td>
<td class="gt_row gt_center" style="font-size: 20px; color: #156594; font-weight: bold;">
0.59
</td>
<td class="gt_row gt_center">

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
<td class="gt_row gt_center" style="font-family: &#39;Colors Of Autumn&#39;; font-size: 20px;">
Si Veo a Tu Mama
</td>
<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #DCAE36;">
83
</td>
<td class="gt_row gt_center" style="font-size: 20px; color: #156594; font-weight: bold;">
0.90
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.60
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.82
</td>
<td class="gt_row gt_center">

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
<img src="https://i.scdn.co/image/ab67616d0000b2732fbd77033247e889cb7d2ac4" style="height:80px;">
</td>
<td class="gt_row gt_center" style="font-family: &#39;Colors Of Autumn&#39;; font-size: 20px;">
Si Estuviesemos Juntos
</td>
<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #EDCC29;">
81
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.67
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.59
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.16
</td>
<td class="gt_row gt_center">

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
<td class="gt_row gt_center" style="font-family: &#39;Colors Of Autumn&#39;; font-size: 20px;">
A Tu Merced
</td>
<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #EDCC29;">
81
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.86
</td>
<td class="gt_row gt_center" style="font-size: 20px; color: #156594; font-weight: bold;">
0.79
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.89
</td>
<td class="gt_row gt_center">

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
<img src="https://i.scdn.co/image/ab67616d0000b273ae879683217d488c39600092" style="height:80px;">
</td>
<td class="gt_row gt_center" style="font-family: &#39;Colors Of Autumn&#39;; font-size: 20px;">
CANCION CON YANDEL
</td>
<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #F4DB1D;">
80
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.75
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.74
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.49
</td>
<td class="gt_row gt_center">

<div class="gt_from_md">

<p>
<audio controlsList="nodownload" controls src="https://p.scdn.co/mp3-preview/3456180fd3829f9fe491b04c8598fd5f7125d614?cid=9d31a6fe89fc4bbda898cd726a12d593">
</audio>
</p>

</div>

</td>
</tr>
<tr>
<td class="gt_row gt_left">
<img src="https://i.scdn.co/image/ab67616d0000b273ae879683217d488c39600092" style="height:80px;">
</td>
<td class="gt_row gt_center" style="font-family: &#39;Colors Of Autumn&#39;; font-size: 20px;">
BYE ME FUI
</td>
<td class="gt_row gt_center" style="border-left-width: 3px; border-left-style: solid; border-left-color: black; border-right-width: 3px; border-right-style: solid; border-right-color: black; font-size: 18.5px; color: #000000; background-color: #FBEB04;">
79
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.71
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.60
</td>
<td class="gt_row gt_center" style="font-size: 18.5px;">
0.59
</td>
<td class="gt_row gt_center">

<div class="gt_from_md">

<p>
<audio controlsList="nodownload" controls src="https://p.scdn.co/mp3-preview/eef0dfff08040b64bdceb7e28889f9d9bb17f8bb?cid=9d31a6fe89fc4bbda898cd726a12d593">
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
