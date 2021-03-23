#Packages
library(dplyr)
library(janitor)
library(viridis)
library(readr)
library(tidyr)
library(ggplot2)
library(ggtext)
library(extrafont)

extrafont::font_import()


#Data
animal_complaints <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-07-21/animal_complaints.csv') %>%
  clean_names() %>% 
  separate(date_received, into = c("month", "year")) %>%
  mutate(month = factor(month, 
                         levels =  c("January", "February", "March",
                                           "April", "May", "June", "July",
                                           "August", "September", "October",
                                           "November", "December"),
                         labels = c("Jan", "Feb", "Mar", "Apr", "May",
                                    "June", "Jul", "Aug", "Sep", "Oct",
                                    "Nov", "Dec")))


#Visualization
per_animal_complaints <- animal_complaints %>% 
  group_by(complaint_type) %>%
  count(month, year) %>% 
  mutate(percent = n/sum(n) * 100) %>%
  ungroup()



ggplot(per_animal_complaints, aes(month, year)) +
  geom_tile(aes(fill = percent), colour = "white", size = 2) +
  geom_text(data = per_animal_complaints %>% group_by(complaint_type) %>% slice_max(percent, n = 10,
                                                                                    with_ties = F),
            aes(label = round(n, 1)), size = 3) +
#  geom_segment(data = segment_coord %>% filter(axis == "x"), aes(x = x1, y = y1, xend = x2, yend = y2)) +
#  geom_segment(data = segment_coord, aes(x = x1, y = y1, xend = x2, yend = y2),
#               arrow = arrow(length = unit(.2, "cm")), inherit.aes = F) +
  labs(
    x = NULL,
    y = NULL,
    title = "Top 10 Months With The Most Reported Complaints By Type",
    subtitle = "While the the percent of complaints by month are generally even throughout the years, there are 
    <br>some months that have a larger tendency to recieve more complaints. Looking below we can see 
    <br>that months that are typically **colder** or considered **winter** months reviece a larger share of complaints.
    <br>Along with reporting the percentage, number of reports for the top 10 months for each complaint type is 
    <br>also provided."
  ) +
  scale_fill_viridis(name = "Percent", option = "plasma",
                     labels = c("0.5%", "1.0%", "1.5%", "2.0%", "2.5%")) +
  scale_x_discrete(breaks = c("Jan", "June","Dec")) +
  scale_y_discrete(breaks = c("2013", "2020")) +
#  coord_cartesian(xlim = c(0,12.2), ylim = c(0,8), clip = "off") +
  facet_wrap(~complaint_type) +
  theme(
    axis.ticks = element_blank(),
    axis.text = element_text(size = 9, colour = "black", family = "Lucida Sans Unicode"),
    panel.background = element_blank(),
    plot.title = element_markdown(size = 14, family = "Lucida Sans Unicode"),
    plot.subtitle = element_markdown(size = 8.5, family = "Lucida Sans Unicode"),
    strip.background = element_blank(),
    strip.text = element_text(colour = "black", size = 10, family = "Lucida Sans Unicode")
    )+
  guides(fill = guide_colourbar(ticks = F, barwidth = 1, barheight = 8))





