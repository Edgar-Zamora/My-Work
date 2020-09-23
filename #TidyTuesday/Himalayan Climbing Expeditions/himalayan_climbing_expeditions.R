library(tidyverse)
library(gt)

members <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-22/members.csv') %>% 
  mutate_if(is.logical, as.numeric)


tbl <- members %>% 
  count(citizenship, success) %>% 
  group_by(citizenship) %>% 
  mutate(total_attempts = sum(n),
         success_rate = round(n/sum(n) * 100, 0)) %>% 
  arrange(-total_attempts) %>% 
  ungroup() %>% 
  filter(success == "1") %>% 
  pivot_wider(names_from = success, values_from = n) %>% 
  slice(1:10) %>% 
  rename(successful_summits = `1`)

tbl %>% 
  add_column(pixels = px(30)) %>% 
  add_column(image = 30) %>% 
  gt() %>% 
  text_transform(
    locations = cells_body(vars(image)),
    fn = function(x) {
      web_image(
        url = "https://www.r-project.org/logo/Rlogo.png",
        height = as.numeric(x)
      )
    }
  ) %>% 
  cols_hide(
    columns = vars(
      pixels)
  )

