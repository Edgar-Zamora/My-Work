library(tidyverse)
library(gt)

members <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-22/members.csv') %>% 
  mutate_if(is.logical, as.numeric)


#Instructions on how to add html code to the body of the table (#https://github.com/rstudio/gt/issues/146)
flags <- tibble(
  country = c("Nepal", "USA", "Japan", "UK", "France", "Spain", "S Korea", "Italy",
              "Germany", "Switzerland"),
  hexadecimal_code = c("&#x1F1F3;&#x1F1F5;", "&#x1F1FA;&#x1F1F8;", "&#x1F1EF;&#x1F1F5;",
                       "&#x1F1EC;&#x1F1E7;", "&#x1F1EB;&#x1F1F7;", "&#x1F1EA;&#x1F1F8;",
                       "&#x1F1F0;&#x1F1F7;", "&#x1F1EE;&#x1F1F9;", "&#x1F1E9;&#x1F1EA;",
                       "&#x1F1E8;&#x1F1ED;"))

tbl <- members %>% 
  count(citizenship, success) %>% 
  group_by(citizenship) %>% 
  mutate(total_attempts = sum(n),
         success_rate = n/sum(n)) %>% 
  arrange(-total_attempts) %>% 
  ungroup() %>% 
  filter(success == "1") %>% 
  pivot_wider(names_from = success, values_from = n) %>% 
  slice(1:10) %>% 
  rename(successful_summits = `1`) %>% 
  mutate(citizenship = paste0(citizenship," ", flags$hexadecimal_code)) %>% 
  select(citizenship, successful_summits, success_rate, total_attempts)



#building table
tbl %>% 
  gt() %>% 
  fmt_markdown(columns = vars(citizenship)) %>% 
  fmt_percent(
    columns = vars(success_rate),
    decimals = 0
  ) %>% 
  fmt_number(
    columns = vars(successful_summits, total_attempts),
    sep_mark = ",",
    decimals = 0,
  ) %>% 
  tab_header(
    title =  (html("<span style='font-size:25px'>🏔 <b> Top 10</b> Countries To Attempt A Summit<span style='font-size:25px'>🏔 </span>"))
  ) %>% 
  cols_align(align = "center", columns = vars(successful_summits, success_rate, total_attempts)) %>% 
  tab_spanner(
    label = html("Reaching the Top <span style='font-size:13px'>🏆</span>"),
    columns = vars(successful_summits, success_rate)
  ) %>% 
  cols_label(
    success_rate = md("Success <br>Rate (%)"),
    successful_summits = md("Successful <br>Summits"),
    total_attempts = "Total Attempts",
    citizenship = "Citizenship"
  ) %>% 
  tab_style(
    style = list(
      cell_fill(color = "lightcyan"),
      cell_text(weight = "bold")
    ),
    locations = cells_body(
      columns = vars(success_rate),
      rows = success_rate >= 25)
  )
  












