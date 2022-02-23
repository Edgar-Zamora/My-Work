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
    
    player_data <- reactive({ plyr_img_df %>% 
            filter(player == input$choose_player)
        
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
        <li><strong>Position: </strong>", player_data()$pos, "</li>
        <li><strong>Player Number: </strong>", player_data()$number, "</li>
        <li><strong>Age: <strong>", player_data()$age, "</li>
        </ul>")
    })

})
