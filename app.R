library(shiny)
library(yaml)

## Source R files in the R subfolder
sapply(list.files("R", "*.R", full.names = TRUE), source)

## Shiny UI
ui <- navbarPage(
  theme = 'https://bootswatch.com/cerulean/bootstrap.min.css',
  id="navbar",

  title="Monte Carlo",
  #welcomeUI("welcome"),
  tabPanel("Simulation",
    sidebarLayout(
      sidebarPanel(
        textInput("n", "Number of runs:", get_default("n_trials")),
        actionButton("simulate", "Run Simulation")
      ),
      mainPanel(
        textAreaInput("global", "Global", get_default("global")),
        textAreaInput("init", "Run Initialization", get_default("init")),
        textAreaInput("expr", "Expression", get_default("expr")),
        hr(),
        textAreaInput("plot", "Plot", get_default("plot")),
        plotOutput("plot_output"),
        textAreaInput("inspect", "Inspect", get_default("inspect")),
        textOutput("inspect_output", container=pre)
      )
    )
  ),
  tabPanel("Results"),
  tabPanel("Reporting"),
  tabPanel("Settings")
)

## Shiny Server
server <- function(input, output, session) {
  callModule(welcome, "welcome")
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
