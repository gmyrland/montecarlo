library(shiny)
library(yaml)
library(rmarkdown)
library(jsonlite)
library(DT)
library(ggplot2)

## Source R files in the R subfolder
sapply(list.files("R", "*.R", full.names = TRUE), source)

## rmarkdown options
opts_chunk$set(echo=FALSE)

## Shiny UI
ui <- navbarPage(
  theme = 'https://bootswatch.com/cerulean/bootstrap.min.css',
  id="navbar",
  title="Monte Carlo",
  windowTitle = "Monte Carlo",
  #welcomeUI("welcome"),
  tabPanel("Simulation",
    sidebarLayout(
      sidebarPanel(
        width = 2,
        fileInput("file1", "File:",
                  accept = "application/json", placeholder = "Unititled"
        ),
        downloadButton('save_file', 'Save'),
        tableOutput("contents"),
        hr(),
        textInput("n_trials", "Number of runs:", get_default("n_trials")),
        actionButton("simulate", "Run Simulation")
      ),
      mainPanel(
        width = 10,
        column(6,
          tabsetPanel(
            id="code",
            selected = "Code",
            tabPanel("Environment",
                codeInput("envir", "Environment", get_default("environment"), rows=26)),
            tabPanel("Code",
                codeInput("global", "Global", get_default("global"), rows=7),
                codeInput("init", "Run Initialization", get_default("init"), rows=7),
                codeInput("expr", "Expression", get_default("expr"), rows=7)
            ),
            tabPanel("Finalize",
                codeInput("finalize", "Finalize", get_default("finalize"), rows=26)
            )
          )
        ),
        column(6,
          tabsetPanel(
            id="simvalues",
            tabPanel("Inputs", inputPanelUI("input-panel")),
            tabPanel("Results", value="Results", resultPanelUI("result-panel")),
            tabPanel("Data", dataPanelUI("data-panel"))
          )
        )
      )
    )
  ),
  resultsTabUI("results"),
  reportingUI("reporting"),
  tabPanel("Settings")
)

## Shiny Server
server <- function(input, output, session) {
  # Reactives
  simulate <- reactive({input$simulate})
  n_trials <- reactive({input$n_trials})
  envir <- reactive({input$envir})
  global <- reactive({input$global})
  init <- reactive({input$init})
  expr <- reactive({input$expr})
  finalize <- reactive({input$finalize})
  file <- reactive({input$file1$datapath})

  # Load/Save file
  observeEvent(file(), load_file(file, session))
  output$save_file <- save_file(input, output, session)
  if (file.exists(get_default("default_file")))
      load_file(get_default("default_file"), session)

  results <- eventReactive(simulate(), {
      # Run simulation
      run_monte_carlo(n_trials(), envir(), global(), init(), expr(), finalize())
  })

  callModule(welcome, "welcome")
  callModule(resultstab, "results", results)
  callModule(reporting, "reporting", results)

  callModule(inputPanel, "input-panel", envir, global, init)
  callModule(resultPanel, "result-panel", results)
  callModule(dataPanel, "data-panel", results)

  session$onSessionEnded(function() stopApp(returnValue=NULL))
}

shinyApp(ui, server)
