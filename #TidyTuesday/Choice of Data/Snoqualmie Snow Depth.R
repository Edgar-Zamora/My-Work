#Packages
#install.packages("googlesheets4")
#installed.packages("googledrive")
#install.packages("gghighlight")

library(googledrive)
library(googlesheets4)
library(tidyverse)
library(gghighlight)
library(Hmisc)

## Connecting to Google Account and Google Sheets
# Authroization
sheets_auth()

# Linking to Google Drive
WSDOT_snow_levels <- drive_get("WSDOT_Mountain_Pass_Snow_Level")

#Importing data and creating ranges
snow_levels <- WSDOT_snow_levels %>% 
  read_sheet() %>% 
  mutate(Year = as.factor(Year),
         Month = fct_relevel(Month, c("October","November", "December",
                                      "January", "Feburary", "March", "April",
                                      "May"))) %>% 
  mutate(new_group = ifelse(New > 10, "10+", 
                            ifelse(New > 6.0, "6-9.9",
                                   ifelse(New > 3.0, "3-5.9", "0-2.9"))))

cols <- c("10+" = "#27408B", "6-9.9" = "#1874CD", "3-5.9" = "#7B9AFA", "0-2.9" = "#CFCFCF")

snow_levels %>% 
  filter(Year == "18-19") %>% 
  ggplot(aes(Day, fct_rev(Month), group = Month, fill = new_group)) + 
  geom_tile(color = "white", size = .25) +
  scale_fill_manual(values = cols,
                    name = "Snow Lvl. (in)",
                    limits = c("0-2.9", "3-5.9", "6-9.9", "10+")) +
  scale_x_continuous(limits = c(0,33),
                     breaks = seq(1,33, 3)) +
  labs(title = "Daily New Snow on Snoqualmie Pass",
       y = "",
       x = "") +
  theme(axis.ticks = element_blank(),
        axis.text.y = element_text(hjust = 0, size = 11, colour = "black"),
        axis.text.x = element_text(size = 9, colour = "black"),
        plot.title = element_text(size = 16, hjust = .5),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(), 
        panel.background = element_blank(),
        legend.key = element_blank(),
        legend.position = "bottom",
        legend.box.spacing = unit(-0.5, "cm"))
