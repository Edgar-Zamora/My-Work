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
# fluidPage(
# 
#     includeCSS("www/styles.css"),
#     theme = 'www/styles.css',
# 
#     navbarPage(
# 
#         # tags$div(class = "navbar-content",
#         #
#         #
#         #          )
# 
#         title = tags$image(class = 'kraken-img',
#                        src = 'https://upload.wikimedia.org/wikipedia/en/thumb/4/48/Seattle_Kraken_official_logo.svg/220px-Seattle_Kraken_official_logo.svg.png',
#                        alt = 'Seattle Kraken'),
#             tags$p("Seattle Kraken"),
# 
#         windowTitle = "Seattle Kraken Trivia",
# 
#         tabPanel(selectInput("choose_player", "", choices = sort(seattle_kraken$player)))),
# 
#     mainPanel(
# 
# 
#             imageOutput("playerImg"),
# 
#             tags$br(),
# 
#             textOutput("playerName"),
# 
#             tags$br(),
# 
#             uiOutput("playerInfo"),
# 
#             tags$br(),
# 
#             gt_output(outputId = "stat_tbl")
# 
#             )
#     )


fluidPage(
    
    includeCSS("www/styles.css"),
    theme = 'www/styles.css',
    
    tags$body(
        
        tags$div(id="navbarContainer",
                 tags$div(id="navFlexContainer",
                 tags$img(class = 'kraken-img',
                          src = 'https://upload.wikimedia.org/wikipedia/en/thumb/4/48/Seattle_Kraken_official_logo.svg/220px-Seattle_Kraken_official_logo.svg.png',
                          alt = 'Seattle Kraken'),
                 tags$p(id="pTagNav", 
                        "Seattle Kraken"),
                 tags$div(id="navDropdown", selectInput("choose_player", "", choices = sort(seattle_kraken$player)))
                 )
                 ),
        
        tags$div(id = 'mainContent',
                 tags$div(class = 'mainContent-playerImg',
                          imageOutput("playerImg"),
                          tags$h3(textOutput('playerName'))),
                 
                 tags$div(class = 'mainContent-playerInfo',
                          uiOutput('playerInfo')),
                 
                 tags$div(class = 'mainContent-playStats',
                          gt_output(outputId = "stat_tbl"))
                 )
        
        )
    )

