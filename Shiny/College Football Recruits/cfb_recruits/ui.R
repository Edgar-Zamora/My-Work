library(shiny)
library(shinyalert)
library(recruitR)
library(tidyverse)
library(gt)
library(fontawesome)
library(htmltools)
library(extrafont)
library(janitor)
library(bslib)



# Star ratings
rating_stars <- function(rating, max_rating = 5) {
    rounded_rating <- floor(rating + 0.5)  # always round up
    
    stars <- lapply(seq_len(max_rating), function(i) {
        if (i <= rounded_rating) fontawesome::fa("star", fill= "#d4af37") else fontawesome::fa("star", fill= "grey")
    })
    
    label <- sprintf("%s out of %s", rating, max_rating)
    
    div_out <- div(title = label, "aria-label" = label, role = "img", stars)
    
    as.character(div_out) %>% 
        gt::html()
}


# Bring in team info
cfb_team <- read_csv("team_info.csv") %>% 
    clean_names()

# Get most recent recruits
recruits <- cfbd_recruiting_player(year = 2017, recruit_type = "HighSchool") %>% 
    as_tibble() %>% 
    left_join(cfb_team, by = c("committed_to" = "school"))


theme <- bs_theme(
    bg = "#202123", fg = "#B8BCC2"
)

################## App


# Define UI for application that draws a histogram
fluidPage(
    
    includeCSS("www/styles.css"),
    
    theme = theme,
    
    # modalDialog(
    #     selectInput("cfb_team", "College Teams",
    #                 choices = sort(unique(recruits$committed_to))),
    #     title = "Choose Your College Team",
    #     size = "m",
    #     easyClose = FALSE
    # ),
    
    navbarPage(title = "College Football Recruits",
               
               
               tabPanel("College Team Analysis",
                        
                        "stuff",
                        
                        
                        ),
              
               tabPanel("Top Recruits",
                        
                        numericInput(inputId = "num_recruits_tbl", 
                                    label = "Number of Recruits to display",
                                    value = 100, min = 1, max = 4359),
                        
                        gt_output(outputId = "recruit_tbl")
                        
                        ),
               
               navbarMenu("About",
                        tabPanel("Data Source",
                                 
                                 "check"
                                 
                                 ),
                        tabPanel("Author",
                                 
                                 sidebarLayout(
                                     mainPanel("stuff"),
                                     sidebarPanel(
                                         html("
                                         <h3>Connecting</h3>
                                         <ul>
                                             <li><a href='https://twitter.com/edgar_zamora_'>Twitter<a></li>
                                             <li><a href='https://github.com/Edgar-Zamora'>GitHub<a></li>
                                             <li><a href='https://github.com/Edgar-Zamora'>LinkedIn</li>
                                         </ul>")
                                         )
                                     )
                                 ))
               )
    )
