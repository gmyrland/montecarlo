
# After trying to figure out how to make textAreaInput span the entire form
# by myself, I stumbled on the workaround provided here:
# http://stackoverflow.com/questions/40808889/a-dynamically-resizing-shiny-textareainput-box

textAreaInput2 <- function (inputId, label, value = "", width = NULL, height = NULL,
          cols = NULL, rows = NULL, placeholder = NULL, resize = NULL) {
    value <- restoreInput(id = inputId, default = value)
    if (!is.null(resize)) {
        resize <- match.arg(resize, c("both", "none", "vertical", "horizontal"))
    }
    style <- paste("max-width: 100%;", if (!is.null(width))
        paste0("width: ", validateCssUnit(width), ";"), if (!is.null(height))
        paste0("height: ", validateCssUnit(height), ";"), if (!is.null(resize))
        paste0("resize: ", resize, ";"))
    if (length(style) == 0)
        style <- NULL
    div(class = "form-group", #label %AND%
        tags$label(label, `for` = inputId), tags$textarea(id = inputId,
        class = "form-control", placeholder = placeholder, style = style,
        rows = rows, cols = cols, value))
}

# General code entry wrapper
codeInput <- function(id, label, value="", width='100%', rows=3) {
    textAreaInput2(id, label, value, rows=rows)
}

inputPanelUI <- function(id) {
    ns <- NS(id)
    tagList(
        uiOutput(ns("input_results"), container=pre),
        actionButton(ns("refresh_input"), "Refresh Inputs")
    )
}

inputPanel <- function(input, output, session, envir, global, init, results) {
    init_results <- eventReactive(input$refresh_input, {
        n <- 5000; seed=1111
        init_results <- run_monte_carlo(n, envir(), global(), init(), "", seed=seed)
        init_results$data <- init_results$data[init_results$init_vars]
        (init_results)
    })
    plotname <- function(i) paste("plot", i, sep="")
    output$input_results <- renderUI({
        tags_list <- lapply(1:ncol(init_results()$data), function(i) {
            plotOutput(session$ns(plotname(i)), height = 200)
        })
        do.call(tagList, tags_list)
    })
    max_plot <- 25
    output$plot <- renderPlot(plot(wt ~ cyl, mtcars))
    plot_function <- function(col) {
        lbl <- names(init_results()$data)[col]
        data <- init_results()$data[, col]
        try(hist(data, main=lbl, breaks=25))
    }
    observe({
        for (i in 1:max_plot) {
            local({
                i <- i
                output[[plotname(i)]] <- renderPlot({
                    plot_function(i)
                })
            })
        }
    })
}

resultPanelUI <- function(id) {
    ns <- NS(id)
    tagList(
        plotOutput(ns("plot_output")),
        codeInput(ns("plot"), "Plot", get_default("plot"), rows=3)
    )
}

resultPanel <- function(input, output, session, results) {
    output$plot_output <- renderPlot({
        eval(parse(text=input$plot))
    })
}

dataPanelUI <- function(id) {
    ns <- NS(id)
    tagList(
        codeInput(ns("inspect"), "Inspect", get_default("inspect"), rows=2),
        textOutput(ns("inspect_output"), container=pre)
    )
}

dataPanel <- function(input, output, session, results) {
    data_result <- reactive({
        #makeActiveBinding(".", results())
        `.` <- results()
        eval(parse(text=input$inspect))
    })
    output$inspect_output <- renderPrint({
        data_result()
    })
}
