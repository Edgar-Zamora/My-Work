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
      align = 'center'
    ) %>%
    # cols_align(
    #   align = 'left',
    #   columns = 1
    # ) %>% 
    
    # Styling the gt table to match what is on the Kraken website
    tab_style(
      style = list(
        cell_fill(color = "#000000"),
        cell_text(color = '#FFFFFF')
      ),
      locations = cells_column_labels(
        columns = everything()
      )
    ) %>% 
    tab_style(
      style = list(
        cell_fill(color = "#DFDFDF"),
        cell_text(color = "#283A49", weight = "normal")
      ),
      locations = cells_body(
        columns = Season
      )
    ) %>% 
    tab_style(
      style = list(
        cell_fill(color = "#ECECEC"),
        cell_text(color = "#111111",
                  font = google_font(name = 'Lato'), 'monospace',
                  weight = 'normal')
      ),
      locations = cells_body(
        columns = -1
      )
    ) %>% 
    tab_style(
      style = cell_borders(sides = "top", 
                           color = "#DEDEDE", 
                           weight = px(2)),
      locations = cells_body(
        rows = Season == 'NHL Career'
      )
    ) %>% 
  
  # Adding general table styles
  tab_options(
    table_body.border.bottom.color = "white",
    table_body.border.top.color = "white",
    column_labels.border.top.color = "white",
    container.width = '100%'
  )
  
  
}

