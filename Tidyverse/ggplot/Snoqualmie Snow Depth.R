#Packages
#install.packages("googlesheets4")
#installed.packages("googledrive")
#install.packages("gghighlight")

library(googledrive)
library(googlesheets4)
library(tidyverse)
library(gghighlight)

sheets_auth()

deaths <- drive_get("WSDOT_Mountain_Pass_Snow_Level")

snow_levels <- deaths %>% 
  read_sheet() %>% 
  mutate(Year = as.factor(Year),
         Month = fct_relevel(Month, c("October","November", "December",
                                      "January", "Feburary", "March", "April",
                                      "May")))

glimpse(snow_levels)  

snow_levels %>% 
  filter(Year == "18-19") %>% 
  ggplot(aes(Day, Month, group = Month, fill = New)) + 
  geom_tile(color = "white", size = .5) +
  scale_x_continuous(limits = c(1,35),
                     breaks = seq(1,35, 3)) +
  labs(title = "New Snow on Snoqualmie Pass by Month and Day
       ",
       y = "Total (ft)") +
  theme(axis.ticks = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(), 
        panel.background = element_blank(),
        legend.key = element_blank())

