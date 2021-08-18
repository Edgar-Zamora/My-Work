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
shinyServer(function(input, output){
  
  output$report <- downloadHandler(
    
    # For PDF output, change this to "report.pdf"
    filename = paste0(input$carrier, ".html"),
    
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "carrier_report.Rmd")
      file.copy("carrier_report.Rmd", tempReport, overwrite = TRUE)
      
      # Set up parameters to pass to Rmd document
      params <- list(carrier = input$carrier)
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(tempReport, 
                        output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
      }
  )
  }
  )
  
