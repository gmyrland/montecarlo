inputPanelUI <- function(id) {
    ns <- NS(id)
    tagList(
        uiOutput(ns("input_results"), container=pre),
        actionButton(ns("refresh_input"), "Refresh Inputs")
    )
}

inputPanel <- function(input, output, session, envir, global, init) {
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
        #data <- init_results()$data[, col]
        #try(hist(data, main=lbl, breaks=25))
        #data <- init_results()$data[, col, drop=FALSE]
        #try(ggplot(data) + geom_histogram(aes_string(x=names(data)[1]), bins=100)) # geom_density(aes_string(x=col)))
        try(ggplot(init_results()$data, aes_string(x=names(init_results()$data)[col])) + geom_density(fill="darkgreen", alpha=0.5)) #geom_freqpoly()) #geom_density())
        #"gaussian", "rectangular", "triangular", "epanechnikov", "biweight", "cosine" or "optcosine"
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
        codeInput(ns("markdown"), "Plot", get_default("result_code"), rows=3),
        uiOutput(ns("result_output"))
    )
}

resultPanel <- function(input, output, session, results) {
    ns <- session$ns
    document <- reactive(render_rmarkdown(input$markdown, results))
    output$result_output = renderUI({document()})
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