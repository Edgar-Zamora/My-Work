library(shiny)


report_path <- tempfile(fileext = ".Rmd")
file.copy("carrier_report.Rmd", report_path, overwrite = TRUE)

render_report <- function(input, output, params) {
  rmarkdown::render(input,
                    output_file = output,
                    params = params,
                    envir = new.env(parent = globalenv())
  )
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  output$report <- downloadHandler(
    filename = function() {
      
      if(!str_detect(input$carrier, "\\.")) {
        
        paste0(input$carrier, ".html")
        
      } else {
        
        paste0(input$carrier, "html")
        
      }
      


      },
    
    content = function(file) {
      params <- list(carrier = input$carrier)
      
      id <- showNotification(
        "Rendering report...", 
        duration = NULL, 
        closeButton = FALSE
      )
      
      on.exit(removeNotification(id), add = TRUE)
      
      callr::r(
        render_report,
        list(input = report_path, 
             output = file, 
             params = params)
        )
    })
  }
  )
  
