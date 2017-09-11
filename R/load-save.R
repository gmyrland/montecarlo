# Until a more elegant solution is coded...

load_file <- function(file, session) {
    if (is.null(file()))
        return(NULL)
    # Read file
    x <- fromJSON(readChar(file, file.info(file)$size))
    # Parse file
    updateTextAreaInput(session, "n_trials", value = x$n_trials)
    updateTextAreaInput(session, "envir", value = x$envir)
    updateTextAreaInput(session, "global", value = x$global)
    updateTextAreaInput(session, "init", value = x$init)
    updateTextAreaInput(session, "expr", value = x$expr)
    updateTextAreaInput(session, "finalize", value = x$finalize)
    updateTextAreaInput(session, NS("result-panel", "markdown"), value = x$result_code)
    updateTextAreaInput(session, NS("data-panel", "inspect"), value = x$inspect)
    updateTextAreaInput(session, NS("reporting", "markdown"), value = x$reporting)
}

save_file <- function(input, output, session) {
    filename <- function() {("montecarlo.json")}
    content <- function(file) {
        # All relevant fields to object
        x <- list(
            `n_trials` = input$n_trials,
            `envir` = input$envir,
            `global` = input$global,
            `init` = input$init,
            `expr` = input$expr,
            `finalize` = input$finalize,
            `result_code` = input[[NS("result-panel", "markdown")]],
            `inspect` = input[[NS("data-panel", "inspect")]],
            `reporting` = input[[NS("reporting", "markdown")]]
        )
        # Write to tmp file
        writeLines(toJSON(x, pretty=TRUE), file)
    }
    downloadHandler(filename = filename, content = content)
}
