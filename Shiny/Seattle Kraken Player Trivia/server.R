#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    player_data <- reactive({ complete_player_df %>% 
            filter(player == input$choose_player)
        
    })
    
    
    player_stats <- reactive({
        kraken_player_stats$`Colin Blackwell`
    })
    
    
    
    # Player Display
    output$playerImg <- renderText({
        paste0("<img src='", player_data()$player_img_large,"'>")
    })
    
    
    output$playerName <- renderText({
        player_data()$player
    })
    
    
    output$playerInfo <- renderText({
        paste0(
        "<ul>
        <li><strong>Birthplace: </strong>", player_data()$birthplace, "</li>
        <li><strong>Weight: </strong>", player_data()$wt, " lbs</li>
        <li><strong>Height: </strong>", player_data()$ht, "</li>
        </ul>
        <ul>
        <li><strong>Position: </strong>", player_data()$pos_name, "</li>
        <li><strong>Player Number: </strong>", player_data()$number, "</li>
        <li><strong>Age: </strong>", player_data()$age, "</li>
        </ul>")
    })
    
    
    
    
    gt_tbl <- reactive(player_stats() %>% 
                           gt() %>% 
                           cols_hide(
                               columns = player_name
                           ) %>% 
                           cols_width(
                               Season ~ px(125)
                           ) %>% 
                           cols_align(
                               columns = 2:13,
                               align = 'center'
                           ) %>% 
                           tab_style(
                               style = list(
                                   cell_fill(color = '#F0F3F5'),
                                   cell_text(weight = 500),
                                   cell_borders(sides = "top", weight = px(3))
                               ),
                               locations = cells_body(
                                   rows = Season == 'NHL Career'
                               )
                           ) %>% 
                           tab_options(
                               table_body.border.bottom.color = "white",
                               table_body.border.top.color = "white",
                               column_labels.border.top.color = "white"
                           ))
    
    
    output$stat_tbl <- render_gt(
        expr = gt_tbl()
    )

})
