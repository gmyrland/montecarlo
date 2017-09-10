## Reporting

default_report <- "```{r}\nls()\n```"

# ui
reportingUI <- function(id) {
    ns <- NS(id)
    tabPanel(
        title = 'Reporting',
        #withMathJax(), # If needed for embedded shiny?
        fluidRow(
            column(4,
               codeInput(ns("markdown"), "", default_report, rows=38)
            ),
            column(8,
               uiOutput(ns('rmarkdown'))
            )
        )
    )    
}

# server
reporting <- function(input, output, session, results) {
    ns <- session$ns
    document <- reactive(render_rmarkdown(input$markdown, results))
    output$rmarkdown = renderUI({document()})
}
