#Packages
library(tidyverse)
library(cowplot)
library(extrafont)
library(magick)
library(png)

#Data
penguins <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-07-28/penguins.csv')


#plot
plot <- penguins %>%
  mutate(species = factor(species, levels = c("Chinstrap", "Gentoo", "Adelie"))) %>%
  ggplot() +
  geom_point(aes(bill_length_mm, bill_depth_mm, colour = species)) +
  scale_colour_manual(values = c("#C75DCB", "#156F75", "#FA7501")) +
  labs(
    x = NULL,
    y = NULL
  ) +
  facet_wrap(~species) +
  theme_minimal() +
  theme(
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    axis.title = element_text(size = 8),
    strip.background = element_blank(),
    strip.text = element_blank(),
    panel.background = element_blank(),
    legend.position = "none",
    panel.grid = element_blank()
  )

img <- readPNG("lter_penguins.png")

triangle <- tibble(
  x = c(1.8, 1,8, 3,8),
  y = c(41, 45, 43)
)

cover <- penguins %>% 
  ggplot() +
  scale_x_continuous(limits = c(0, 60)) +
  scale_y_continuous(limits = c(0, 100)) +
  geom_rect(xmin = 0, xmax = 4, ymin = 0, ymax = 100,   fill = "#FFCE00") + #left
  geom_rect(xmin = 1.2, xmax = 58.8, ymin = 0, ymax = 4, fill = "#FFCE00") + #bottom
  geom_rect(xmin = 56, xmax = 60, ymin = 0, ymax = 100 , fill = "#FFCE00") + #right
  geom_rect(xmin = 1.2, xmax = 60, ymin = 96, ymax = 100, fill = "#FFCE00") + #top
  geom_polygon(data = triangle, aes(x = x, y = y), fill = "red") +
  annotate("text", x = 30, y = 88, label = 'PALMER \nPENGUINS', family = "Josefin Sans Regular",
           size = 8) +
  annotate("text", x = 30, y = 2, label = "Artwork: @allison_horst | Data: Gorman, Williams, and Fraster (2014)",
           size = 2) +
  annotate("text", 30, y = 98, label = "8.2020", colour = "red", family = "Copperplate Light",
           size = 4) +
  annotate("text", x = 13, y = 43, label = "Bill lenght by Bill depth \nfor Palmer Penguins",
           size = 2.5, family = "Josefin Sans Regular") +
  labs(
    x = NULL,
    y = NULL
  )+
  annotation_custom(rasterGrob(img),
                    xmin = 10, xmax = 50,
                    ymin = 40, ymax = 85) +
  theme(
    panel.grid = element_blank(),
    panel.background = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank()
  ) 


ggdraw(cover) +
  draw_plot(plot, .13, .085, .85, .3)



#447, 612

