# Load packages
library(recruitR)
library(tidyverse)
library(httr)
library(jsonlite)
library(maps)
library(gt)




# College Football 2022 Recruits
# This is borrowed from the {recruitR} package.

results <- httr::RETRY(
  "GET", "https://api.collegefootballdata.com/recruiting/players?year=2022&classification=HighSchool",
  httr::add_headers(Authorization = paste("Bearer", cfbd_key()))
)


cfb_2022_recruits <- results %>%
  httr::content(as = "text", encoding = "UTF-8") %>%
  jsonlite::fromJSON(flatten=TRUE) %>%
  janitor::clean_names() %>% 
  as_tibble()



# Wrangling data
cfb_2022_plyr_recruits <- cfb_2022_recruits %>% 
  distinct(year, name, school, committed_to, position,
           stars, rating, state_province) %>% 
  group_by(name) %>% 
  fill(c("committed_to", "position"), .direction = "down") %>% 
  ungroup() %>% 
  distinct_all() %>% 
  arrange(desc(rating)) %>%
  mutate(across(rating, ~format(., digits = 4)),
         ovr_ranking = dense_rank(desc(rating))) %>%
  ungroup() %>% 
  group_by(state_province) %>% 
  arrange(state_province) %>% 
  mutate(state_ranking = dense_rank(desc(rating))) %>% 
  ungroup() %>% 
  mutate(top300 = if_else(ovr_ranking <= 300, "y", "n"))


# Helper Functions/DF
state_df <- tibble(
  state_abb = state.abb,
  state_name = state.name
) %>% 
  mutate(across(state_name, str_to_lower))


state_map_data <- map_data("state") %>% 
  as.tibble()


state_outline <- function(data, region) {
  
  data %>% 
    filter(region == {{region}}) %>% 
    ggplot(mapping = aes(long, lat, group = group)) +
    coord_fixed(1.3) +
    geom_polygon(color="black", fill="transparent") +
    theme(
      panel.grid = element_blank(),
      panel.background = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.title = element_blank()
    )
  
}



# plots <- state_df %>% 
#   filter(!state_name %in% c("alaska", "hawaii")) %>% 
#   left_join(state_map_data, by = c("state_name" = "region")) %>% 
#   select(-state_abb) %>% 
#   mutate(region = state_name) %>% 
#   relocate(region, .before = subregion) %>% 
#   nest(data = c(long:subregion))  %>% 
#   mutate(plot = map2(data, state_name, ~ggplot(., mapping = aes(long, lat, group = group)) +
#                        coord_fixed(1.3) +
#                        geom_polygon(color="black", fill="transparent") +
#                        theme(
#                          panel.grid = element_blank(),
#                          panel.background = element_blank(),
#                          axis.text = element_blank(),
#                          axis.ticks = element_blank(),
#                          axis.title = element_blank()
#                        ))
#   )
# 
# 
# 
# 
# state_df %>% 
#   filter(!state_name %in% c("alaska", "hawaii")) %>% 
#   mutate(ggplot = NA) %>% 
#   gt() %>% 
#   text_transform(
#     locations = cells_body(columns = ggplot),
#     fn = function(x) {
#       plots$plot %>%
#         ggplot_image(height = px(200))
#     }
#   )


