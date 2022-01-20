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



# Helper Functions/dataframes
## State name lookup
state_df <- tibble(
  state_abb = state.abb,
  state_name = state.name
) %>% 
  mutate(across(state_name, str_to_lower))


## State outline data
state_map_data <- map_data("state") %>% 
  as_tibble()


## Function for state outlines
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

## School logos
school_logos <- cfbfastR::cfbd_team_info(year = 2022) %>% 
  as_tibble() %>% 
  unnest(logos) %>% 
  group_by(school) %>% 
  filter(str_detect(logos, "\\bdark\\b", negate = TRUE)) %>% 
  select(school, logos) %>% 
  ungroup() %>% 
  add_row(school = c("Central Arkansas", "Montana State", "North Dakota State", "Jackson State", "Northern Arizona",
                     "Northern Iowa", "Weber State", "Murray State", "Southern Illinois", "Eastern Washington",
                     "Princeton", "Monmouth", "Bucknell", "Villanova"),
          logos = c("http://a.espncdn.com/i/teamlogos/ncaa/500/2110.png",
                    "http://a.espncdn.com/i/teamlogos/ncaa/500/149.png",
                    "https://a.espncdn.com/combiner/i?img=/i/teamlogos/ncaa/500/2449.png?w=110&h=110&transparent=true",
                    "http://a.espncdn.com/i/teamlogos/ncaa/500/2296.png",
                    "http://a.espncdn.com/i/teamlogos/ncaa/500/2464.png",
                    "http://a.espncdn.com/i/teamlogos/ncaa/500/2460.png",
                    "http://a.espncdn.com/i/teamlogos/ncaa/500/2692.png",
                    "http://a.espncdn.com/i/teamlogos/ncaa/500/93.png",
                    "http://a.espncdn.com/i/teamlogos/ncaa/500/79.png",
                    "http://a.espncdn.com/i/teamlogos/ncaa/500/331.png",
                    "http://a.espncdn.com/i/teamlogos/ncaa/500/163.png",
                    "http://a.espncdn.com/i/teamlogos/ncaa/500/2405.png",
                    "http://a.espncdn.com/i/teamlogos/ncaa/500/2083.png",
                    "http://a.espncdn.com/i/teamlogos/ncaa/500/222.png"))



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




### State Summary ### 
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
  

# Finding top 3 schools for each category
top3_schls <- cfb_2022_plyr_recruits %>% 
  filter(!is.na(committed_to),
         state_province %in% state.abb) %>% 
  group_by(state_province, committed_to) %>% 
  summarise(
    commits = n()
  ) %>% 
  slice_max(order_by = commits, n = 3) %>% 
  ungroup()  %>% 
  left_join(school_logos, by = c("committed_to" = "school")) %>% 
  group_by(state_province) %>% 
  mutate(top3_schls = paste0("<div class='top-3'> <img class='top-3-img' src='", logos, "'> <span class='top-3-txt'>",committed_to, " (<strong>", commits, "</strong>) </span>
                       </div>", collapse = ""))  %>% 
  ungroup() %>% 
  distinct(state_province, top3_schls) 


in_state_top3_schls <- cfb_2022_plyr_recruits %>% 
  filter(!is.na(committed_to),
         in_state == "y",
         state_province %in% state.abb) %>% 
  group_by(state_province, committed_to) %>% 
  summarise(
    commits = n()
  ) %>% 
  slice_max(order_by = commits, n = 3) %>% 
  ungroup()  %>% 
  left_join(school_logos, by = c("committed_to" = "school")) %>% 
  group_by(state_province) %>% 
  mutate(in_state_top3_schls = paste0("<div class='top-3'> <img class='top-3-img' src='", logos, "'> <span class='top-3-txt'>",committed_to, " (<strong>", commits, "</strong>) </span>
                       </div>", collapse = ""))  %>% 
  ungroup() %>% 
  distinct(state_province, in_state_top3_schls) 



top3_schls_300 <- cfb_2022_plyr_recruits %>% 
  filter(!is.na(committed_to),
         top300 == "y",
         state_province %in% state.abb) %>% 
  group_by(state_province, committed_to) %>% 
  summarise(
    commits = n()
  ) %>% 
  slice_max(order_by = commits, n = 3) %>% 
  ungroup()  %>% 
  left_join(school_logos, by = c("committed_to" = "school")) %>% 
  group_by(state_province) %>% 
  mutate(top300_schls = paste0("<div class='top-3'> <img class='top-3-img' src='", logos, "'> <span class='top-3-txt'>",committed_to, " (<strong>", commits, "</strong>) </span>
                       </div>", collapse = ""))  %>% 
  ungroup() %>% 
  distinct(state_province, top300_schls) 




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
  left_join(top3_schls, by = c("state_province")) %>% 
  left_join(state_df, by = c("state_province" = 'state_abb')) %>% 
  left_join(in_state_top3_schls, by = "state_province") %>% 
  left_join(top3_schls_300, by = "state_province") %>% 
  filter(state_province != "HI") %>% 
  mutate(ggplot = NA,
         across(state_name, str_to_title),
         in_state_top_10 = NA) %>% 
  select(ggplot, state_name, num_recruits, top3_schls,
         in_state_commits, in_state_top_10, in_state_top3_schls,
         top300_recruits, top300_in_state_commits, top300_schls) %>% 
  gt() %>% 
  fmt_markdown(columns = c(top3_schls, in_state_top3_schls, top300_schls)) %>% 
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
    top3_schls = "Top Schools",
    in_state_commits = "Commits",
    in_state_top_10 = "Top 10 Commits",
    in_state_top3_schls = "Top Schools",
    top300_recruits = "Recruits",
    top300_in_state_commits = "In-State Commits",
    top300_schls = 'Top Schools'
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
    columns = 2:10,
    align = "center"
  ) %>% 
  tab_options(table.font.size = px(20)) %>%
  opt_table_font(
    font = list(
      google_font(name = "Ubuntu"),
      "Sans", "Serif"
    )
  ) %>% 
opt_css(
  css = '.top-3-img {
  width: 50px;
  height: 50px;}
  
  .gt_row gt_center {
  display: flex;
  justify-content: flex-start;}

  .top-3 {
  display: flex;
  align-items: center;}

  .top-3-txt {
  margin-left: 10px;}

  .top-3-img {
  margin: 3px 0px;
  }'
)


