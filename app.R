library(shiny)
library(yaml)

## Load configuration and defaults
config <- yaml.load_file('config.yml')
default_global  <- config$defaults$global
default_init    <- config$defaults$init
default_expr    <- config$defaults$expr
default_n       <- config$defaults$n_trials
default_plot    <- config$defaults$plot
default_inspect <- config$defaults$inspect

## Source the Monte Carlo functions
source("R/mcfuncs2.R", local=TRUE)

## Shiny UI
ui <- fluidPage(
  # Application title
  titlePanel("Monte Carlo"),

  sidebarLayout(
    sidebarPanel(
      textInput("n", "Number of runs:", default_n),
      actionButton("simulate", "Run Simulation")
    ),

    mainPanel(
      textAreaInput("global", "Global", default_global),
      textAreaInput("init", "Run Initialization", default_init),
      textAreaInput("expr", "Expression", default_expr),
      hr(),
      textAreaInput("plot", "Plot", default_plot),
      plotOutput("plot_output"),
      textAreaInput("inspect", "Inspect", default_inspect),
      textOutput("inspect_output", container=pre)
    )
  )
)

## Shiny Server
server <- function(input, output, session) {
  results <- eventReactive(input$simulate, {
      # Run simulation
      n <- input$n
      global <- input$global
      init <- input$init
      expr <- input$expr
      run_monte_carlo(n, global, init, expr)
  })

  output$plot_output <- renderPlot({
      eval(parse(text=input$plot))
  })
  output$inspect_output <- renderPrint({
      eval(parse(text=input$inspect))
  })

  session$onSessionEnded(function() stopApp(returnValue=NULL))
}

shinyApp(ui, server)
