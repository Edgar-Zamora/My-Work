library(rvest)
library(tidyverse)
library(glue)

#U.S. House Committee on Finaincal Services (107, 108, 110)
#http://archives-financialservices.house.gov/archive/{url}.shtml (110 Congress Url)
#http://archives-financialservices.house.gov/hearings107.shtml 
#http://archives-financialservices.house.gov/hearings110.shtml
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

#url <- c("hr121008", "hr091608", "hr0626084", "hr030607", "ht1002072") 110 Congress
url <- c("hearings317")

patterns <- c("Mr. |The Honorable |Ms. ") #Idk if you want to take these titles out of names

x <- map_df(url, scrape)  %>% 
  separate(Date, c("Weekday","MonthDay", "Year"), sep = "([\\,])") %>% 
  separate(Names, c("Name","Wit_Title", "Organization"), sep = "([\\,])") %>% 
  mutate_if(is.character, str_trim) %>% 
  mutate(Name = str_replace(Name, patterns, ""))

x <- x %>% 
  mutate(Name = gsub("\\s*\\([^\\)]+\\)","",as.character(x$Name)),
         Organization = gsub("\\s*\\([^\\)]+\\)","",as.character(x$Organization)))


