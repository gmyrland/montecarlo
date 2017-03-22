## Placeholder for welcome screen

# ui
welcomeUI <- function(id) {
    ns <- NS(id)
    tabPanel(
        "Welcome",
        tags$h1("Monte Carlo Simulator", align = "center"),
        tags$h2("(For simulating things)", align = "center")
    )
}

# server
welcome <- function(input, output, session) {
    
}
