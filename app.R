library(shiny)

## Source the Monte Carlo functions
source("R/mcfuncs2.R", local=TRUE)

## Temporary defaults
default_global <- paste0("uniform <- function(min, max) runif(n=1, min=min, max=max)",
                        "\nnormal <- function(sd, mean) rnorm(n=1, sd=sd, mean=mean)")
default_init   <- "x <- uniform(min=5, max=10)\ny <- normal(sd=0.5, mean=0)"
default_expr   <- "x + y"
default_n      <- 1000

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
      plotOutput("result")
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

  output$result <- renderPlot({
    hist(results()$result)
  })

  session$onSessionEnded(function() stopApp(returnValue=NULL))
}

shinyApp(ui, server)
