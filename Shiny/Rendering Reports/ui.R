library(shiny)
library(tidyverse)
library(nycflights13)
library(viridis)
library(ggthemes)
library(lubridate)
library(shinyWidgets)
library(extrafont)
library(ggtext)
library(glue)
library(rmarkdown)


merged_df <- flights %>% 
  left_join(airports %>% 
              rename(dest_airport = name), by = c("dest" = "faa")) %>% 
  right_join(airlines %>% 
               rename(carrier_name = name), by = "carrier") %>% 
  mutate(date = mdy(paste(month, day, year, sep = "/")))



# Define UI for application that draws a histogram

fluidPage(
  
  includeCSS("www/style.css"),
  
  navbarPage( "NYC Flights Report",
    
    tabPanel("Build Report",
             selectInput(
               "carrier", "Select a Carrier:", 
               choices = unique(merged_df$carrier_name)),
             
             dateRangeInput(
               "daterange", "Date Range",
               start = "2013-01-01", end = "2013-12-31", format = "yyyy-mm-dd"),
             
             radioButtons("file_type", "Choose a file type",
                          choices = list("PDF" = ".pdf", "HTML" = ".html")),
             
             downloadButton("report", "Generate report"),
             
             verbatimTextOutput("value")
             ),
    
    tabPanel("About")
    )
)
