inputPanelUI <- function(id) {
    ns <- NS(id)
    tagList(
        uiOutput(ns("input_results"), container=pre),
        checkboxInput(ns("update"), "Automatically update", value = TRUE),
        actionButton(ns("refresh_input"), "Refresh Inputs")
    )
}

inputPanel <- function(input, output, session, envir, global, init) {
    init_updated <- reactiveVal(0)
    observe({
        init()
        if (isolate(!input$update)) return()
        isolate(init_updated(init_updated() + 1))
    })
    init_results <- eventReactive({input$refresh_input; init_updated()}, {
        n <- 5000; seed=1111
        init_results <- run_monte_carlo(n, envir(), global(), init(), "", "", seed=seed)
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
        try(ggplot(init_results()$data, aes_string(x=names(init_results()$data)[col])) + geom_density(fill="darkgreen", alpha=0.5))
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
    document <- reactive(render_html_fragment(input$markdown, results))
    output$result_output = renderUI({document()})
}

dataPanelUI <- function(id) {
    ns <- NS(id)
    tagList(
        codeInput(ns("inspect"), "Inspect", get_default("inspect"), rows=3),
        textOutput(ns("inspect_output"), container=pre)
    )
}

dataPanel <- function(input, output, session, results) {
    data_result <- reactive({
        #makeActiveBinding(".", results())
        #`.` <- results()
        env_base <- results()
        env <- new.env(parent = env_base)
        eval(parse(text=input$inspect), envir=env)
    })
    output$inspect_output <- renderPrint({
        data_result()
    })
}
