#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(gt)

seattle_kraken <- read_csv('data/seattle_kraken.csv')


# Define UI for application that draws a histogram
fluidPage(
    
    includeCSS("www/styles.css"),
    theme = 'www/styles.css',
    
    navbarPage(
        
        
        title = tags$div(class = 'navbar-logo',
            tags$image(class = 'kraken-img',
                       src = 'https://upload.wikimedia.org/wikipedia/en/thumb/4/48/Seattle_Kraken_official_logo.svg/220px-Seattle_Kraken_official_logo.svg.png',
                       alt = 'Seattle Kraken'),
            tags$p("Seattle Kraken"),
            ),
        
        windowTitle = "Seattle Kraken Trivia",
        
        tabPanel(selectInput("choose_player", "", choices = sort(seattle_kraken$player))),
        
        mainPanel(
            
            imageOutput("playerImg"),
            
            tags$br(),
            
            textOutput("playerName"),
            
            tags$br(),
            
            uiOutput("playerInfo"),
            
            tags$br(),
            
            gt_output(outputId = "stat_tbl")
            
            )
    )
    )
