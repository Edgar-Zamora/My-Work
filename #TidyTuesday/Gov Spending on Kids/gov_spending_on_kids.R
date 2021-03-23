library(tidyverse)
library(geofacet)
library(scales)
library(ggtext)
library(cowplot)
library(extrafont)
library(here)
#library(ggforce)

kids <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-15/kids.csv') %>% 
  left_join(tibble(
  state_abb = state.abb,
  state_name = state.name) %>% 
  add_row(state_abb = "DC", state_name = "District of Columbia"), by = c("state" = "state_name"))


## This will allow for the change the strip headers
## THIS IS NOT MT WORK. The solution comes from Claus Wilke who was answering a question on stackoverflow asked by Eric Green. 
## You can find the question and answer here: https://stackoverflow.com/questions/60332202/conditionally-fill-ggtext-text-boxes-in-facet-wrap/60345086#60345086

element_textbox_highlight <- function(..., hi.labels = NULL, hi.fill = NULL,
                                      hi.col = NULL, hi.box.col = NULL) {
  structure(
    c(element_textbox(...),
      list(hi.labels = hi.labels, hi.fill = hi.fill, hi.col = hi.col, hi.box.col = hi.box.col)
    ),
    class = c("element_textbox_highlight", "element_textbox", "element_text", "element")
  )
}

element_grob.element_textbox_highlight <- function(element, label = "", ...) {
  if (label %in% element$hi.labels) {
    element$fill <- element$hi.fill %||% element$fill
    element$colour <- element$hi.col %||% element$colour
    element$box.colour <- element$hi.box.col %||% element$box.colour
  }
  NextMethod()
}


## Summarizing state spending to figure out whether there was an increase from one year to another.

## Making summaries for legend and state-level 
## Overall summary
#overall_state_spending <- kids %>% 
#  filter(variable == "highered") %>% 
#  group_by(year) %>% 
#  summarise(
#    avg = round(mean(inf_adj_perchild), 2)) %>% 
#  ungroup() %>% 
#  mutate(spending_change = case_when(avg  > lag(avg, default = first(avg), order_by = year) ~ "Increase",
#                                     avg  < lag(avg, default = first(avg), order_by = year) ~ "Decrease",
#                                     TRUE ~ "Same"),
#         spending_colour = lead(spending_change),
#         spending_colour = factor(spending_colour, levels = c("Increase", "Decrease", "Same"))) %>% 
#  ungroup() %>%
#  filter(year != "2016")

## State summary
state_spending <- kids %>% 
  filter(variable == "highered") %>% 
  group_by(state_abb, year) %>% 
  summarise(
    avg = round(mean(inf_adj_perchild), 2)) %>% 
  ungroup() %>% 
  group_by(state_abb) %>% 
  mutate(spending_change = case_when(avg  > lag(avg, default = first(avg), order_by = year) ~ "Increase",
                                     avg  < lag(avg, default = first(avg), order_by = year) ~ "Decrease",
                                     TRUE ~ "Same"),
         spending_colour = lead(spending_change),
         spending_colour = factor(spending_colour, levels = c("Increase", "Same", "Decrease"))) %>% 
  ungroup() %>%
  filter(year != "2016")



## Pulling those states that had at least a 50% increase in spending from the 1997 to 2015
state_total_change <- state_spending %>% 
  group_by(state_abb) %>% 
  summarise(
    better_off = round((last(avg) - first(avg))/first(avg) * 100, 0)) %>% 
  ungroup() %>% 
  filter(better_off >= 50) %>% 
  pull(state_abb)


## Creating visualization
#ggplot(overall_state_spending, aes(year, avg, color = spending_colour, group = 1)) +
#  geom_line(size = .8, key_glyph = "timeseries") +
#  geom_mark_circle(aes(filter = year == 2002, label = NULL, 
#                       description = "A change, or lack of, in spending per child is indicated by a difference in color"), show.legend = FALSE) +
#  scale_color_manual(name = "Spending Change \nFrom Previous Year", values = c("#59A14F","#E15759", "#BAB0AC")) +
#  scale_y_continuous(labels = dollar_format()) +
#  labs(
#    x = NULL,
#    y = "Adjusted for Inflation Per Child ($)"
#  ) +
#  facet_wrap(~"Overall") +
#  theme(
#    legend.key = element_blank(),
#    panel.grid = element_blank(),
#    panel.background = element_blank(),
#    axis.ticks = element_blank(),
#    axis.text.x = element_blank(),
#    strip.background = element_blank(),
#    strip.text = element_textbox_highlight(
#      size = 12,
#      color = "black", fill = "#DFF0D8", box.color = "#DFF0D8",
#      halign = 0.5, linetype = 1, r = unit(5, "pt"), width = unit(1, "npc"),
#      padding = margin(2, 0, 1, 0), margin = margin(3, 3, 3, 3),
#      hi.labels = state_total_change ,
#      hi.fill = "#5D729D", hi.box.col = "#5D729D", hi.col = "white")
#  )


ggplot(state_spending, aes(year, avg, group = state_abb, color = spending_colour)) +
  geom_line(size = .8, key_glyph = "timeseries") +
  scale_color_manual(name = "Spending Change \nFrom Previous Year", values = c("#59A14F",  "#BAB0AC", "#E15759")) +
  scale_y_continuous(labels = dollar_format(),
                     breaks = c(1, 3)) +
  labs(
    x = NULL,
    y = "Spending per child, adjust for inflation ($1000s)",
    title = "Public spending on higher education by state and year",
    subtitle = "The spending per child, adjusted for inflation, for each state from 1997 to 2015. Each <b style='color:#59A14F'>increase </b>, 
    <b style='color:#E15759'>decrease</b>, or <b style='color:#BAB0AC'>constant</b> <br> spending is compared to the previous years spending. 
    Additionally those **states that increased their spending by 50%** from 
    <br> 1997 to 2015 are colored <b style='color:#5D729D'>blue</b> while those that did not are colored <b style='color:#DFF0D8'>green(ish) </b>"
  ) +
  theme(
    legend.key = element_blank(),
    panel.grid = element_blank(),
    panel.background = element_blank(),
    axis.ticks = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_text(family = "Chalkboard"),
    axis.title.y = element_text(family = "Chalkduster", size = 9),
    strip.background = element_blank(),
    plot.title = element_text(size = 20, family = "Chalkduster"),
    plot.subtitle = element_markdown(size = 10, family = "Chalkboard"),
    legend.text = element_text(family = "Chalkboard"),
    legend.title = element_text(family = "Chalkduster"),
    strip.text = element_textbox_highlight(
      size = 12, family = "Chalkduster",
      color = "black", fill = "#DFF0D8", box.color = "#DFF0D8",
      halign = 0.5, linetype = 1, r = unit(5, "pt"), width = unit(1, "npc"),
      padding = margin(2, 0, 1, 0), margin = margin(3, 3, 3, 3),
      hi.labels = state_total_change ,
      hi.fill = "#5D729D", hi.box.col = "#5D729D", hi.col = "white")
    ) +
  facet_geo(~state_abb, grid = "us_state_grid2")
  ggsave(here("#TidyTuesday", "Gov Spending on Kids", "higherEd_spending.png"), width = 8, height = 8, units = c("in"))

  
