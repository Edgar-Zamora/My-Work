library(tidyverse)
library(magrittr)
library(readr)
library(scales)
library(grid)
library(ggimage)
#library(extrafont)

#Import Data
cpu <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-09-03/cpu.csv")

#Importing Fonts
#font_import()
#fonttable()

#Graphing
plot <- cpu %>% 
  ggplot(aes(date_of_introduction, area)) +
  geom_point(aes(colour = log2(transistor_count)), size = 3.5, alpha = .8) +
  scale_color_gradient2(high = "gold") +
  scale_y_continuous(breaks = seq(0,800,100)) +
  guides(colour = guide_legend(expression('Num. Of Transitors (log'[2]*')'))) +
  theme(legend.key = element_rect(fill = "white"),
        legend.position = "bottom",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        text = element_text(colour = "white", size = 16, family = "Lucida Console"),
        plot.title = element_text(size = 25, family = "Lucida Console"),
        axis.text = element_text(colour = "white", size = 11, family = "Lucida Console"),
        legend.margin = margin(0,0,0,0),
        legend.box.margin = margin(-5,-5,-10,-5),
        legend.text = element_text(size = 10),
        legend.title = element_text(size = 10)) +
  labs(x = "Year Introduced",
       y = "Area of Chip (mm)",
       title = "Does A Bigger CPU Lead To More Transitors?",
       caption = "@Edgar_Zamora_")
  
#Combining Plot and Image
TidyTuesday_plot <- ggbackground(plot, "CircuitBoard.jpg")

#Saving 

ggsave("TidyTuesday.png", width = 30, height = 17, units = "cm")

#ISource of image: "https://www.vecteezy.com/"
