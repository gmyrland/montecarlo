## Config

# Read config.yaml
get_config <- function() {
    conf <- NULL
    function() {
        if (is.null(conf)) {
            conf <<- yaml.load_file('config.yml')
        }
        (conf)
    }
}

# Config access method(s)
get_default <- function(name) {
    v <- config()$defaults[[name]]
    if (is.null(v)) {
        warning(name, " is not defined as a default configuration variable")
    }
    (v)
}

# Prepare config
config <- get_config()
