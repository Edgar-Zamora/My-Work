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



# Reading in data

cfb_recruits <- read_rds(here("Shiny", "College Football Recruits",
                              "data", "college_recruits_15_22.rds"))
cfb_team_sum <- read_rds(here("Shiny", "College Football Recruits",
                              "data", "college_recruit_sum_15_22.rds"))


# Source script
source(here("Shiny", "College Football Recruits", "script", "helper_funs.R"))



# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    # Reactive Data
    data <- reactive({cfb_recruits %>% 
                         filter(committed_to == input$cfb_team,
                                year == input$cfb_year) %>% 
                         arrange(ranking) %>% 
                         mutate(hometown = paste0(city, ", ", state_province, "<br>", school),
                                rating_stars = map(stars, rating_stars),
                                rating = rating * 100,
                                leaflet_ranking = ranking,
                                ranking = paste0("<div class='rating-cont'><p>", ranking, "</p></div>"),
                                across(c(hometown_info_latitude, hometown_info_longitude), as.numeric),
                                content = paste0("Player: <b>", name, "</b>",
                                                 "<br> Committed to:<b> ", committed_to, "</b>",
                                                 "<br> Ranking:<b> ", leaflet_ranking, "</b>",
                                                 "<br> Position:<b> ", position, "</b>",
                                                 " <br>Hometown:<b> ",city, ", ", state_province, "<b>"))})
    
    
    team_logo <- reactive({cfb_recruits %>% 
            filter(committed_to == input$cfb_team)})
    
    
    
    cfb_commits <- reactive({cfb_team_sum %>% 
            filter(committed_to == input$cfb_team,
                   year == input$cfb_year)})
    
    
    
    
    # Saving data values
    output$commits <- renderText(cfb_commits()$commits)
    
    output$top_300 <- renderText(cfb_commits()$top_300)
    
    output$other_commits<- renderText(cfb_commits()$other_commits)
    
    output$five_star<- renderText(cfb_commits()$five_star)
    
    output$four_star <- renderText(cfb_commits()$four_star)
    
    output$three_star <- renderText(cfb_commits()$three_star)
    

    output$team_logo <- renderUI({
        
        HTML(paste0("<img src='", unique(team_logo()$logos_0), "' width='55' height='55'> CFB Recruits"))
        

    })
    
    
    
    
    # Creating leaflet map
    
    output$cfb_recruit_loc <- renderLeaflet({
        
        leaflet() %>%
          addTiles() %>%
          addMarkers(lng = data()$hometown_info_longitude,
                     lat = data()$hometown_info_latitude,
                     popup = data()$content,
                     clusterOptions = markerClusterOptions()) %>%
          leaflet.extras::addResetMapButton() %>%
          leaflet.extras::addFullscreenControl()
        
    })
    

    
    
    # Creating barplot
    
    output$cfb_recruit_states <- renderPlot({
        
        data() %>% 
            group_by(year, committed_to, state_province) %>% 
            tally() %>% 
            arrange(desc(n)) %>% 
            mutate(state_province = case_when(is.na(state_province) ~ "N/A",
                                              TRUE ~ state_province)) %>% 
            ggplot(aes(n, fct_reorder(fct_rev(state_province), n), label = n)) +
            geom_point(size = 11, colour = '#044520') +
            geom_text(colour = "white", size = 5) + 
            labs(
                title = paste0(input$cfb_team, " Recruits By State"),
                x = "",
                y = ""
            ) +
            theme(
                axis.ticks = element_blank(),
                axis.text.x = element_blank(),
                axis.text.y = element_text(colour = "black", size = 12),
                panel.grid.minor = element_blank(),
                panel.grid.major.x = element_blank(),
                panel.grid.major.y = element_line(colour = "#ECECEC"),
                panel.background = element_blank(),
                plot.title = element_text(size = 20)
                )
        
    })
    
    
    
    # Creating gt table
    gt_tbl <- reactive(data() %>% 
                           select(ranking, name, position, hometown, height, weight,
                                  rating_stars, rating, logos_0, committed_to) %>% 
                           gt()  %>% 
                           fmt_markdown(
                               columns = c(hometown, ranking)
                           ) %>% 
                           cols_hide(
                               columns = committed_to
                           ) %>% 
                           text_transform(
                               locations = cells_body(
                                   columns = c(logos_0)
                               ),
                               fn = function(x) {
                                   paste0(web_image(
                                       url = x,
                                       height = 70
                                   ))
                               }
                           ) %>%
                           fmt_number(
                               columns = c(height, rating),
                               decimals = 1
                           ) %>% 
                           tab_style(
                               style = cell_fill(
                                   color = "#DEDEDE"
                               ),
                               locations = cells_column_labels(
                                   columns = everything()
                               )
                           ) %>% 
                           cols_label(
                               ranking = md("**RK**"),
                               name = md("**PLAYER**"),
                               position = md("**PS**"),
                               hometown = md("**HOMETOWN**"),
                               height = md("**HT**"),
                               weight = md("**WT**"),
                               rating_stars = md("**STARS**"),
                               rating = md("**GRADE**"),
                               logos_0 = md(" ")
                           ) %>% 
                           tab_style(
                               style = cell_text(
                                   color = "black",
                                   size = px(35)
                               ),
                               locations = cells_title(
                                   groups = "title"
                               )
                           ) %>% 
                           opt_css(
                               css = '.gt_left:nth-child(1){
                               background-color: #E6E6E6;
                               vertical-align: middle;}
                               
                               .rating-cont p{
                               text-align: center;
                               color: #8A8A8A;
                               font-size: 21px;}
                               
                               img+ p {
                               float: right;}'
                           ))
    
    
    
    
    
    output$recruit_tbl <- render_gt(
        expr = gt_tbl()
    )
    
    
    # team_col <- reactive({data() %>% 
    #         distinct(color) %>% 
    #         pull()
    #                      })
    # 
    # 
    # team_logo <- reactive({ data() %>% 
    #         distinct(logos_0) %>% 
    #         pull()
    # })
    

    
    
    # observe({
    #     # Make sure theme is kept current with desired
    #     session$setCurrentTheme(
    #         bs_theme_update(theme, bg = team_col(), fg = "#f5f0f0")
    #     )
    # })
    
    
    # output$static <- renderTable({
    #     
    #     head(data())
    #     
    # })
    # 
    
    

})
