#Packages
library(tidyverse)
library(magrittr)
library(readr)
library(ggalt)

#Importing Data
tx_injuries <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-09-10/tx_injuries.csv")

injuries <- tx_injuries %>% 
  count(gender, body_part) 
  filter(n >= 5  & body_part != "Face" & body_part != "Forehead") %>% 
  arrange(desc(n)) %>% 
  print(n = Inf) %>% 
  as.tibble()

#Putting the coordinates of where the body party approximatelyis
injuries$xcord <- round(c(155,152,545,550,490,492,495,142,133,494,493,155,145,410,40),0)
injuries$ycord <- round(c(650,650,555,555,600,475,600,65,225,475,390,620,65,452,360),0)

#Create circle points for geom_encircle
hand <- injuries %>% 
  filter(body_part == "Hand")

elbow <- injuries %>% 
  filter(body_part == "Elbow")

#Creating plot
plot <- ggplot(injuries, aes(xcord,ycord)) +
  geom_point(aes(colour = gender, size = n), alpha = .8) +
  geom_encircle(aes(xcord,ycord),data = hand, s_shape = .5,size = 2, expand = 0.001,
                spread = 0.02, colour = "red") +
  geom_curve(aes(x = 33, y = 370, xend = 15, yend = 410), curvature = -.25, 
             arrow = arrow(length = unit(0.015, "cm")), colour = "red") +
  annotate("text", x = 15, y = 440, label = "There were \nonly 5 injuries \nto the hand",
           size = 3) +
  geom_encircle(aes(xcord,ycord),data = elbow, s_shape = .5,size = 2, expand = 0.001,
                spread = 0.02, colour = "red") +
  geom_curve(aes(x = 403, y = 464, xend = 375, yend = 500), curvature = .25, 
             arrow = arrow(length = unit(0.015, "cm")), colour = "red") +
  annotate("text", x = 355, y = 510, label = "WOW!! \nOnly 5 injuries \nelbow",
           size = 3) +
  labs(x = NULL,
       y = NULL,title = "Texas Amusment Park Injuries") +
  scale_x_continuous(limits = c(0,650), breaks = seq(0,650,50)) +
  scale_y_continuous(limits = c(0,650), breaks = seq(0,650,50)) +
  scale_colour_discrete(name  ="Gender", breaks=c("F", "M"), labels=c("Woman", "Man")) +
  scale_size(name = "Number of Injuries", range = c(0, 13)) +
  guides(colour = guide_legend(order = 1),
         size = guide_legend(order = 2)) +
  theme(panel.grid = element_blank(),
        axis.text  = element_blank(),
        axis.ticks = element_blank(),
        plot.title = element_text(hjust = 0.5, size = 18),
        legend.position = c(.518,.28),
        legend.margin = margin(6,6,6,6),
        legend.text = element_text(size = 11),
        legend.title = element_text(size = 12),
        legend.key.size = unit(.55, "cm"),
        legend.spacing.x = unit(.01, "cm"),
        legend.spacing.y = unit(.01, "cm"))

#Adding background
ggbackground(plot, "bodyoutline.jpg")

#Saving plot
ggsave("Amusment Park Injuries.png", width = 30, height = 17, units = "cm")

