library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    data <- reactive(recruits %>% 
                         filter(committed_to == input$cfb_team)) 
    
    
    
    output$recruit_tbl <- render_gt(
        expr = gt_tbl %>% 
            tab_header(
                title = paste(input$num_recruits_tbl, "sss")
            ),
        height = px(600),
        width = px(1000)
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
    
    # output$team_logo <- renderUI({
    #     
    #     html(paste0("<img src='",team_logo(),"' width=50 >"))
    #     
    #     
    # })
    
    

})
