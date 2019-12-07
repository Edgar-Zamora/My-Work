library(rvest)
library(tidyverse)
library(glue)

#110
#hr121008
#hr091608

#Use for hearings before May 21, 2014
scrape <- function(url){
  url <- glue('http://archives-financialservices.house.gov/hearing110/{url}.shtml')
  
  product <- url %>%
    read_html() %>%
    html_nodes(".holder-interior-body")
  
  names <- product %>%
    html_nodes("li") %>%
    html_text() %>%
    gsub("\\n", "",.)
  
  date <- product %>%
    html_nodes("h2+ p") %>%
    html_text() %>%
    gsub("\\n", "",.) %>%
    gsub("\\r", "",.) 
  
  title <- product %>%
    html_nodes("h2") %>%
    html_text()
  
  tibble(Names = names, 
         Date = date, 
         Title = title)
}

#http://archives-financialservices.house.gov/hearings107.shtml

url <- c("hr121008", "hr091608")
glue('http://archives-financialservices.house.gov/hearing110/{url}.shtml')

patterns <- c("Mr. |The Honorable |Ms. ") #Idk if you want to take these titles out of names

x <- map_df(url, scrape) %>% 
  mutate(Names = as.factor(str_replace(Names, patterns, ""))) %>% 
  separate(Date, c("Weekday","MonthDay", "Year"), sep = "([\\,])") %>% 
  separate(Names, c("Name","Title", "Organization"), sep = "([\\,])") %>% 
  mutate_if(is.character, str_trim)

#try doing a detect with () at the edges with anything in between to be removed, whether they are numbers or letters(uppercase and lowercase)
