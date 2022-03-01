# Helper Function

# A general webscraping function that will pull information about the Kraken roster. This
# includes player name, birthplace, height, etc.

kraken_scrape <- function(category) {
  
  scrape(session) %>% 
    html_elements({{category}}) %>% 
    html_text() %>% 
    as_tibble() %>% 
    row_to_names(row_number = 1) %>% 
    clean_names()
}


# A function that will return the img address for each of the Kraken players images. This allows
# for bigger player image to be used.
kraken_imgs <- function(url) {
  
  session <- bow({{url}})
  
  scrape(session) %>% 
    html_element(".player-jumbotron-vitals__headshot-image") %>% 
    html_attr("src") %>% 
    as_tibble()
}



# Retreving seasons and career stats for each Kraken player
kraken_stats <- function(player_name, player_url) {
  
  session <- bow({{player_url}})
  
  scrape(session) %>%
    html_table() %>% 
    pluck(., 3) %>% 
    mutate(player_name = {{player_name}})
  
}




# Creating table for season and career stats
kraken_tbl <- function(data) {
  
  data %>% 
    gt() %>% 
    cols_hide(
      columns = player_name
    ) %>% 
    cols_width(
      Season ~ px(125)
    ) %>% 
    cols_align(
      columns = 2:13,
      align = 'center'
    ) %>% 
    tab_style(
      style = list(
        cell_fill(color = '#F0F3F5'),
        cell_text(weight = 500),
        cell_borders(sides = "top", weight = px(3))
      ),
      locations = cells_body(
        rows = Season == 'NHL Career'
      )
    ) %>% 
    tab_options(
      table_body.border.bottom.color = "white",
      table_body.border.top.color = "white",
      column_labels.border.top.color = "white"
    )
  
  
}

