## Results

# ui
resultsTabUI <- function(id) {
    ns <- NS(id)
    tabPanel(
        title = 'Results',
        h1("Results"),
        DT::dataTableOutput(ns("results")),
        downloadButton(ns('csv'), 'csv')
    )
}

# server
resultstab <- function(input, output, session, results) {
    ns <- session$ns
    output$results <- DT::renderDataTable(
        datatable(
            results()$data, options=list(), rownames = FALSE
        ), server=TRUE
    )
    output$csv <- downloadHandler(
        filename=function() {"montecarlo.csv"},
        content=function(file) {
            write.csv(results()$data, file, row.names=FALSE)
        },
        contentType='text/csv'
    )
}
