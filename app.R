library(shiny)
library(yaml)
library(rmarkdown)

## Source R files in the R subfolder
sapply(list.files("R", "*.R", full.names = TRUE), source)

## Shiny UI
ui <- navbarPage(
  theme = 'https://bootswatch.com/cerulean/bootstrap.min.css',
  id="navbar",
  title="Monte Carlo",
  windowTitle = "Monte Carlo",
  welcomeUI("welcome"),
  tabPanel("Simulation",
    sidebarLayout(
      sidebarPanel(
        width = 2,
        textInput("n_trials", "Number of runs:", get_default("n_trials")),
        actionButton("simulate", "Run Simulation")
      ),
      mainPanel(
        width = 10,
        column(6,
            codeInput("global", "Global", get_default("global"), rows=7),
            codeInput("init", "Run Initialization", get_default("init"), rows=7),
            codeInput("expr", "Expression", get_default("expr"), rows=7)
        ),
        column(6,
          tabsetPanel("simvalues",
            tabPanel("Inputs",
              "Inputs"
            ),
            tabPanel("Results", resultPanelUI("result-panel")),
            tabPanel("Data", dataPanelUI("data-panel"))
          )
        )
      )
    )
  ),
  tabPanel("Results"),
  reportingUI("reporting"),
  tabPanel("Settings")
)

## Shiny Server
server <- function(input, output, session) {
  # Reactives
  simulate <- reactive({input$simulate})
  n_trials <- reactive({input$n_trials})
  global <- reactive({input$global})
  init <- reactive({input$init})
  expr <- reactive({input$expr})

  results <- eventReactive(simulate(), {
      # Run simulation
      run_monte_carlo(n_trials(), global(), init(), expr())
  })

  callModule(welcome, "welcome")
  callModule(reporting, "reporting", results)

  callModule(resultPanel, "result-panel", results)
  callModule(dataPanel, "data-panel", results)

  session$onSessionEnded(function() stopApp(returnValue=NULL))
}

shinyApp(ui, server)
