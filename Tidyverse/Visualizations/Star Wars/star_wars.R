library(tidyverse)
library(extrafont)
library(magick)
library(ggimage)

options(max.print=1000000)
font_import()
fonttable()
#https://www.dafont.com/font-comment.php?file=star_jedi

df <- tibble(
  rating = c(6.5, 6.5, 7.5, 8.6, 8.7, 8.3, 7.9, 7, 6.7),
  title = factor(c("Star Wars: Episode I \nThe Phantom Menace (1999)",
                   "Star Wars: Episode II \nAttack of the Clones (2002)",
                   "Star Wars: Episode III \nRevent of the Sit (2005)",
                   "Star Wars: Episode IV \nA New Hope (1977)",
                   "Star Wars: Episode V \nThe Empire Strikes Back (1980)",
                   "Star Wars: Episode VI \nReturn of the Jedi (1983)",
                   "Star Wars: Episode VII \nThe Force Awakens (2015)",
                   "Star Wars: Episode VIII \nThe Last Jedi (2017) ",
                   "Star Wars: Episode IX \nThe Rise of Skywalker (2019)")))


df <- df %>% 
  mutate(title = str_to_upper(title))

plot <- ggplot(df, aes(rating, fct_reorder(title, rating))) +
  #geom_point(colour = "white", size = 7) +
  geom_image(aes(image = "death_star.png"), size = .08) +
  scale_x_continuous(limits = c(6.5, 9),
                     breaks = c(6.5, 7, 7.5, 8, 8.5),
                     position = "top") +
  labs(
    x = "",
    y = "",
    title = "SKYWALKER SAGA",
    subtitle = "RANKED BY IMBb USERS",
    caption = "data: IMBd | graphic: @Edgar_Zamora_ | photo: Thom Schneider") +
  theme_minimal() +
  theme(
    text = element_text(colour = "white"),
    axis.text = element_text(family = "Avenir Book", size = 11, face = "bold"),
    axis.text.x = element_text(colour = "#FFFC33"),
    axis.text.y = element_text(colour = "white"),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_line(colour = "#FFFC33", linetype = "dotted"),
    plot.title = element_text(hjust = 1.1,  size = 55, family = "Star Jedi Hollow"),
    plot.subtitle = element_text(hjust = .9, size = 14, family = "Avenir Book", face = "bold"),
    plot.caption = element_text(colour = "white", size = 7, hjust = .8),
    plot.background = element_rect(fill = "black"))

plot

ggbackground(plot, "thom-schneider-iSYYLt2rKac-unsplash.jpg")

ggsave("star_wars.png", width = 20, height = 18, units = "cm")

#Photo by Jacob Spence on Unsplash
