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
    document <- reactive({
        t <- tempfile(fileext = '.Rmd')
        cat(input$markdown, file = t)
        on.exit(unlink(sub('.html$', '*', t)), add = TRUE)
        env = new.env()
        try(env$results <- results())
        t <- render(
            input = t,
            #runtime = "shiny",
            output_format = html_document(theme = "cerulean"), # quick fix
            envir = env
        )
        
        ## read results
        res <- readLines(t)
        
        #wrappers <- c(readLines, HTML, withMathJax)
        #for (.F in wrappers) res <- .F(res)
        withMathJax(HTML(res))
    })
    output$rmarkdown = renderUI({document()})
}
