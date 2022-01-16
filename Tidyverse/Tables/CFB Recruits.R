# Load packages
library(recruitR)
library(tidyverse)
library(httr)
library(jsonlite)
library(maps)
library(gt)
library(janitor)




# College Football 2022 Recruits
# This is borrowed from the {recruitR} package.

results <- httr::RETRY(
  "GET", "https://api.collegefootballdata.com/recruiting/players?year=2022&classification=HighSchool",
  httr::add_headers(Authorization = paste("Bearer", cfbd_key()))
)


cfb_2022_recruits <- results %>%
  httr::content(as = "text", encoding = "UTF-8") %>%
  fromJSON(flatten=TRUE) %>%
  clean_names() %>% 
  as_tibble() %>% 
  rename("Committed.to" = "committed_to") %>% 
  college_states() %>% 
  clean_names()




# Helper Functions/DF
state_df <- tibble(
  state_abb = state.abb,
  state_name = state.name
) %>% 
  mutate(across(state_name, str_to_lower))


state_map_data <- map_data("state") %>% 
  as_tibble()


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



# Wrangling data
cfb_2022_plyr_recruits <- cfb_2022_recruits %>%
  left_join(state_df, by = c('state_province' = "state_abb")) %>% 
  distinct(year, name, school, committed_to, position,
           stars, rating, state_province, college_state) %>% 
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
  mutate(top300 = if_else(ovr_ranking <= 300, "y", "n"),
         college_state = case_when(is.na(committed_to) ~ "uncommited",
                                   TRUE ~ college_state),
         in_state = case_when(state_province == college_state ~ "y",
                              TRUE ~ "n"),
         state_top_10 = case_when(state_ranking <= 10 ~ 'y',
                                  TRUE ~ 'n'))




# Summarizing state information
cfb_state_summary <- cfb_2022_plyr_recruits %>% 
  filter(state_province %in% state.abb) %>% 
  group_by(state_province) %>%  
  summarise(
    num_recruits = n(),
    in_state_commits = sum(in_state == "y"),
    top300_recruits = sum(top300 == "y"),
    top300_in_state_commits = sum(top300 == 'y' & in_state == 'y')
  ) %>% 
  ungroup()
  




# Plotting
plots <- cfb_state_summary %>% 
  filter(state_province != "HI") %>% 
  left_join(state_df, by = c("state_province" = 'state_abb')) %>% 
  left_join(state_map_data, by = c("state_name" = "region")) %>% 
  mutate(region = state_name) %>% 
  relocate(region, .before = subregion) %>%
  select(-c(num_recruits:top300_in_state_commits)) %>% 
  nest(data = c(long:subregion)) %>% 
  mutate(plot = map2(data, state_name, ~ggplot(., mapping = aes(long, lat, group = group)) +
                       coord_fixed(1.3) +
                       geom_polygon(color="black", fill="transparent", size = 1.5) +
                       theme(
                         panel.grid = element_blank(),
                         panel.background = element_blank(),
                         axis.text = element_blank(),
                         axis.ticks = element_blank(),
                         axis.title = element_blank()
                       )
                     )
         )





cfb_state_summary %>% 
  left_join(state_df, by = c("state_province" = 'state_abb')) %>% 
  filter(state_province != "HI") %>% 
  mutate(ggplot = NA,
         across(state_name, str_to_title),
         in_state_top_10 = NA,
         in_state_top_schls = NA,
         top300_top_schls = NA) %>% 
  select(ggplot, state_name, num_recruits, 
         in_state_commits, in_state_top_10, in_state_top_schls,
         top300_recruits, top300_in_state_commits, top300_top_schls) %>% 
  gt() %>% 
  text_transform(
    locations = cells_body(columns = ggplot),
    fn = function(x) {
      plots$plot %>% 
        ggplot_image(height = px(150))
    }
  ) %>% 
  cols_label(
    state_name = "",
    ggplot = "",
    num_recruits = "# of Recruits",
    in_state_commits = "Commits",
    in_state_top_10 = "Top 10 Commits",
    in_state_top_schls = "Top Schools",
    top300_recruits = "Recruits",
    top300_in_state_commits = "In-State Commits",
    top300_top_schls = 'Top Schools'
  ) %>% 
  tab_header(
    title = "Are They Staying Home?",
    subtitle = "Looking at whether college recruits commit to in-state schools"
  ) %>% 
  tab_spanner(
    label = "Top 300",
    columns = c(starts_with("top300"))
  ) %>% 
  tab_spanner(
    label = "In-State",
    columns = c(starts_with("in_state"))
  ) %>% 
  tab_style(
    style = list(
      cell_borders(
        sides = "left",
        color = 'black',
        weight = px(6)
      )
    ),
    locations = cells_body(
      columns = c(in_state_commits, top300_recruits)
    )
  ) %>% 
  cols_align(
    columns = 2:6,
    align = "center"
  ) %>% 
  tab_options(table.font.size = px(20)) %>%
  opt_table_font(
    font = list(
      google_font(name = "Ubuntu"),
      "Sans", "Serif"
    )
  )


