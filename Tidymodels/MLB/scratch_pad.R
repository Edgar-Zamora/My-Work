library(scales)
library(ggforce)


game_data %>% 
  filter(away_home == "home") %>% 
  group_by(year) %>% 
  summarise(
    avg_attendance = mean(attendance, na.rm = T)
  ) %>% 
  ggplot(aes(year, avg_attendance)) +
  geom_line(size = 2) +
  geom_mark_circle(aes(filter = year == 2001,
                       label = "2001 Season",
                       description = "Last time Mariners made the MLB playoffs.")) +
  scale_y_continuous(limits = c(0, 50000)) +
  labs(
    x = "Year",
    y = "Avg Attedance",
    title = "Seattle Mariners Avg Season Attendance"
  ) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(colour = "#EBECF0"),
    panel.background = element_blank(),
    axis.ticks = element_blank()
  )
