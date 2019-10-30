### Necessary Packages ###
#readxl
#car
#tidyverse
#scales

### Preparing the Data for graphing ###
df <- read_excel("Themes from Employee Focus Group Report Mar 2019.xlsx", 
                 col_types = c("text", "numeric", "numeric", 
                               "numeric", "numeric", "numeric", 
                               "numeric", "numeric", "blank", "blank"))

#The code below turns all the na's into No Response
df$Response[is.na(df$Response)] <- "No Response"

#Gathering the data from a wide layout to a long layout so that R can more easily read it
newdf <- gather(df, Theme, Rating, `Value/Recognition`:Accountability, na.rm = FALSE)

#Recoding the variables
newdf$Rating <- recode(newdf$Rating, "1=7;2=6;3=5;4=4;5=3;6=2;7=1")

#Creating a dataframe that contains the mean response for each employee group grouped by theme
#This dataframe will become the primary dataframe used in the graphic
mean_rating <- newdf %>%
  group_by(Response, Theme) %>%
  summarise(mean_size = round(mean(Rating, na.rm = TRUE),1))

#Looking at the distribution of employee groups
table(df$Response, exclude = NULL)

#Creating a colorblind color palette to use in the graphic
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#CC79A7", "#56B4E9")


### Creating Visualization ###

ggplot(mean_rating, aes(x = Response, y = mean_size, fill = Response)) +
  geom_bar(stat = "identity", position = "dodge", width = .8) +
  scale_fill_manual(values = cbPalette) +
  facet_grid(~Theme) +
  scale_y_continuous(breaks=seq(0,7,1)) +
  labs(title = "Importance of Themes by Employee Group", subtitle = "Scale: 1(Least Important) - 7 (Most Important)") +
  geom_text(aes(label= v$mean_size), hjust = .5, vjust = -.3) +
  theme(axis.text.x = element_blank(), legend.position = "bottom",
        plot.title = element_text(size = 20),
        panel.spacing = unit(3, "lines"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks.x = element_blank(),
        panel.background = element_rect(fill = "gray96"))
