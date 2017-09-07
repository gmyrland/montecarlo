# Until a more elegant solution is coded...

load_file <- function(file, session) {
    if (is.null(file()))
        return(NULL)
    # Read file
    fpath <- file()$datapath
    fsize <- file()$size
    x <- fromJSON(readChar(fpath, fsize))
    # Parse file
    updateTextAreaInput(session, "n_trials", value = x$n_trials)
    updateTextAreaInput(session, "envir", value = x$envir)
    updateTextAreaInput(session, "global", value = x$global)
    updateTextAreaInput(session, "init", value = x$init)
    updateTextAreaInput(session, "expr", value = x$expr)
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
            `expr` = input$expr
        )
        # Write to tmp file
        writeLines(toJSON(x, pretty=TRUE), file)
    }
    downloadHandler(filename = filename, content = content)
}
