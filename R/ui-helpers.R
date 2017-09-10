
# After trying to figure out how to make textAreaInput span the entire form
# by myself, I stumbled on the workaround provided here:
# http://stackoverflow.com/questions/40808889/a-dynamically-resizing-shiny-textareainput-box

textAreaInput2 <- function (inputId, label, value = "", width = NULL, height = NULL,
          cols = NULL, rows = NULL, placeholder = NULL, resize = NULL) {
    value <- restoreInput(id = inputId, default = value)
    if (!is.null(resize)) {
        resize <- match.arg(resize, c("both", "none", "vertical", "horizontal"))
    }
    style <- paste("max-width: 100%;", if (!is.null(width))
        paste0("width: ", validateCssUnit(width), ";"), if (!is.null(height))
        paste0("height: ", validateCssUnit(height), ";"), if (!is.null(resize))
        paste0("resize: ", resize, ";"))
    if (length(style) == 0)
        style <- NULL
    div(class = "form-group", #label %AND%
        tags$label(label, `for` = inputId), tags$textarea(id = inputId,
        class = "form-control", placeholder = placeholder, style = style,
        rows = rows, cols = cols, value))
}

# General code entry wrapper
codeInput <- function(id, label, value="", width='100%', rows=3) {
    textAreaInput2(id, label, value, rows=rows)
}

