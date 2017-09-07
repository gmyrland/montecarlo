## Results

# ui
resultsTabUI <- function(id) {
    ns <- NS(id)
    tabPanel(
        title = 'Results',
        h1("Results"),
        DT::dataTableOutput(ns("results"))
    )
}

# server
resultstab <- function(input, output, session, results) {
    ns <- session$ns
    output$results <- DT::renderDataTable(
        datatable(results()$data)
    )
}
