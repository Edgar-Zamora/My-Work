library(tidyverse)
library(extrafont)
library(magick)
library(ggimage)

font_import("")
fonttable()
#https://www.dafont.com/font-comment.php?file=star_jedi

df <- tibble(
  rating = c(6.5, 6.5, 7.5, 8.6, 8.7, 8.3, 7.9, 7, 6.7),
  title = factor(c("Star Wars: Episoide I \nThe Phantom Menace (1991)",
                   "Star Wars: Episoide II \nAttack of the Clones (2002)",
                   "Star Wars: Episoide III \nRevent of the Sit (2005)",
                   "Star Wars: Episoide IV \nA New Hope (1977)",
                   "Star Wars: Episoide V \nThe Empire Strikes Back (1980)",
                   "Star Wars: Episoide VI \nReturn of the Jedi (1983)",
                   "Star Wars: Episoide VII \nThe Force Awakens (2015)",
                   "Star Wars: Episoide VIII \nThe Last Jedi (2017) ",
                   "Star Wars: Episoide IX \nThe Rise of Skywalker (2019)")))


df

plot <- ggplot(df, aes(rating, fct_reorder(title, rating))) +
  geom_point(colour = "white", size = 7) +
  scale_x_continuous(limits = c(6.5, 9),
                     breaks = c(6.5, 7, 7.5, 8, 8.5),
                     position = "top") +
  labs(
    x = "",
    y = "",
    title = "SKYWALKER SAGA",
    subtitle = "RANKED BY IMBb USERS") +
  theme_minimal() +
  theme(
    text = element_text(colour = "white"),
    axis.text = element_text(family = "Calibri Light", size = 11, face = "bold"),
    axis.text.x = element_text(colour = "#FFFC33"),
    axis.text.y = element_text(colour = "white"),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_line(colour = "#FFFC33", linetype = "dotted"),
    plot.title = element_text(hjust = -3.5, size = 42, family = "Star Jedi Hollow"),
    plot.subtitle = element_text(hjust = .95, size = 14, family = "Calibri Light", face = "bold"),
    plot.background = element_rect(fill = "black"))



ggbackground(plot, "jacob-spence-Bolre_2dEZI-unsplash.jpg")

ggsave("test.png", width = 20, height = 22, units = "cm")

#Photo by Jacob Spence on Unsplash
