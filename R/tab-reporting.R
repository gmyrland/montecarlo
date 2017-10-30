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
               codeInput(ns("markdown"), "", default_report, rows=38),
               downloadButton(ns('pdf'), 'pdf'),
               downloadButton(ns('docx'), 'docx'),
               downloadButton(ns('html'), 'html')
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
    document <- reactive(render_html_fragment(input$markdown, results))
    output$rmarkdown = renderUI({document()})
    output$pdf <- downloadHandler(
        filename=function() {"montecarlo.pdf"},
        content=function(file) render_document(input$markdown, results, pdf_document(), file),
        contentType='application/pdf'
    )
    output$docx <- downloadHandler(
        filename=function() {"montecarlo.docx"},
        content=function(file) render_document(input$markdown, results, 'word_document', file),
        contentType='application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    )
    output$html <- downloadHandler(
        filename=function() {"montecarlo.html"},
        content=function(file) render_document(input$markdown, results, html_document(theme = "sandstone"), file),
        contentType='text/html'
    )
}
