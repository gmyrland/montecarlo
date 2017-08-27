## Placeholder for welcome screen

# ui
welcomeUI <- function(id) {
    # Check for inclusion
    if (!get_setting("welcome")) return("")

    # Generate welcome screen
    ns <- NS(id)
    tabPanel(
        id="welcome-panel",
        title = "Welcome",
        h1("Monte Carlo Simulator", align = "center"),
        h2("(For simulating things)", align = "center")
    )
}

# server
welcome <- function(input, output, session) {
    # Check for inclusion
    if (!get_setting("welcome")) return(NULL)
}
