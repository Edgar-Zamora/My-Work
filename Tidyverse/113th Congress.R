library(rvest)
library(tidyverse)

#Use for hearings before May 21, 2014
scrape <- function(url){
  starturl<- "https://financialservices.house.gov/calendar/eventsingle.aspx?EventID="
  url <- paste0(starturl,url)
  
  product <- url %>%
    read_html() %>%
    html_nodes(".column > .box .box-holder")
  
  
  names <- product %>%
    html_nodes("li") %>%
    html_text() %>%
    gsub("\\n", "",.)
  
  date <- product %>%
    html_nodes(xpath = "//*[@id='ctl00_ContentCell']/div[3]/div[2]/b/text()[2]") %>%
    html_text() %>%
    gsub("\\n", "",.) %>%
    gsub("\\r", "",.) 
  
  title <- product %>%
    html_nodes(".news-titler") %>%
    html_text()
  
  tibble(Names = names, 
         Date = date, 
         Title = title)
}

#############################################################################################################
#Instead of making each url an individual object, you can create them into a list to be able to iterate over.
#Doesn't eliminate the need to write each url but makes it quicker
#url1 <- "398645"
#url2 <- "398676"
#url3 <- "398681"
#url4 <- "398686"

urls <- c("398645", "398676", "398681", "398686")

#############################################################################################################
#Iterating the function to each url and returning a tibble(table) that has them all combined
#These may take some times (seconds) depending on how much your mapping
total <- map_df(urls, scrape)


#############################################################################################################
#Turning witness title into a factor to allow for sepeartion by the comma
total$Names <- as.factor(total$Names)

#Seperating the witness title into seperate parts 
#R will fill empty table cells with NAs, but may do it incorrectly. For example if there is a name and organization but no title R will put the organization
#in the cell where title goes. So look for NAs and check them.
total <- total %>% 
  separate(Names, c("Name","Title", "Organization"), sep = "([\\,])") %>% 
  separate(Date, c("Weekday","MonthDay", "Year"), sep = "([\\,])")

#Writing dataframe to a csv
write.csv(FSCongress, file = "J.D.csv")


############################################################################################################
############################################################################################################
############################################################################################################
#Use after May 21, 2014

scrape2 <- function(url){
  starturl<- "https://financialservices.house.gov/calendar/eventsingle.aspx?EventID="
  url <- paste0(starturl,url)
  
  product <- url %>%
    read_html() %>%
    html_nodes("#ctl00_ContentCell")
  
  names <- product %>%
    html_nodes(xpath = "//*[@id='previewPanel']/div/p/strong") %>%
    html_text() %>%
    gsub("\\n", "",.) %>%
    gsub("\\r", "",.) 
  
  date <- product %>%
    html_nodes(".meetingTime") %>%
    html_text() %>%
    gsub("\\n", "",.) %>%
    gsub("\\r", "",.) 
  
  title <- product %>%
    html_nodes(".news-titler") %>%
    html_text()
  
  org_title <- product %>% 
    html_nodes(".text-small") %>% 
    html_text() %>%
    gsub("\\n", "",.) %>%
    gsub("\\r", "",.) 
  
  tibble(
    WitnessNames = names,
    Date = date,
    HearingTitle = title,
    Orginzation = org_title)
}

#############################################################################################################

urls2 <- c("401846","401826")

#############################################################################################################

total2 <- map_df(urls2, scrape2)

#############################################################################################################
#Turning witness title into a factor to allow for sepeartion by the comma
total2$WitnessNames <- as.factor(total2$WitnessNames)

#Seperating the witness title into seperate parts 
#R will fill empyt table cells wiht NAs, but may do it incorrectly. For example if there is a name and organization but no title R will put the organization
#in the cell where title goes. So look for NAs and check them.
total2 <- total2 %>% 
  separate(Date, c("Weekday","MonthDay", "Year"), sep = "([\\,])") %>% 
  separate(Orginzation, c("Title","Organization", "Extra (Delete Maybe)"), sep = "([\\,])") 



