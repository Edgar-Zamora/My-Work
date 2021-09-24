library(shiny)
library(shinyalert)
library(recruitR)
library(tidyverse)
library(gt)
library(here)
library(fontawesome)
library(htmltools)
library(extrafont)
library(janitor)
library(bslib)
library(shinyWidgets)
library(leaflet)
library(htmltools)
library(leaflet.extras)
#devtools::install_github("ashbaldry/shinytitle")
library(shinytitle)


# Reading in data

cfb_recruits <- read_rds(here("Shiny", "College Football Recruits",
                              "data", "college_recruits_15_22.rds"))
cfb_team_sum <- read_rds(here("Shiny", "College Football Recruits",
                              "data", "college_recruit_sum_15_22.rds"))



################## App


# Define UI for application that draws a histogram

fluidPage(
    
    includeCSS("www/styles.css"),
    
    theme = "www/styles.css",
    
    
    navbarPage(title = uiOutput("team_logo"),
               
               windowTitle = "CFB Dashboard",
               
               
               tabPanel("College Team Analysis",
                        
                        fluidRow(
                            
                            column(4,
                            selectInput("cfb_year", "Year:",
                                        choices = unique(cfb_recruits$year),
                                        selected = 2021)
                            ),
                            
                            column(4,
                            selectInput("cfb_team", 'College Football Team:',
                                        choices = sort(unique(cfb_recruits$committed_to)),
                                        selected = "Oregon")
                            )
                        ),
                        
                        fluidRow(
                            column(8,
                                   leafletOutput("cfb_recruit_loc", height = 600)
                            ),
                            column(4,
                                   plotOutput("cfb_recruit_states", height = 600)
                            )
                        )
                    ),
              
               tabPanel("Top Recruits",
                        
                        
                        HTML(paste0("<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css'>
                                 
                                 <table>
                                 <tr class = 'tr-header'>
                                 <td width='10%'>Commits</td>
                                 <td width='10%'>Top 300</td>
                                 <td width='10%'>Other Commits</td>
                                 <td width='10%'>
                                 <span class='fa fa-star checked'></span>
                                 <span class='fa fa-star checked'></span>
                                 <span class='fa fa-star checked'></span>
                                 <span class='fa fa-star checked'></span>
                                 <span class='fa fa-star checked'></span></td>
                                 <td width='10%'><span class='fa fa-star checked'></span>
                                 <span class='fa fa-star checked'></span>
                                 <span class='fa fa-star checked'></span>
                                 <span class='fa fa-star checked'></span>
                                 <span class='fa fa-star'></span></td>
                                 <td width='10%'><span class='fa fa-star checked'></span>
                                 <span class='fa fa-star checked'></span>
                                 <span class='fa fa-star checked'></span>
                                 <span class='fa fa-star'></span>
                                 <span class='fa fa-star'></span></td>
                                 </tr>
                                 <tr class = 'tr-row'>
                                 <td>", textOutput("commits"), "</td>
                                 <td>", textOutput("top_300"), "</td>
                                 <td>", textOutput("other_commits"), "</td>
                                 <td>", textOutput("five_star"), "</td>
                                 <td>", textOutput("four_star"), "</td>
                                 <td>", textOutput("three_star"), "</td>
                                 </tr>
                                 </table>")),
                        
                        tags$br(),
                        tags$br(),
                        
                        
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
