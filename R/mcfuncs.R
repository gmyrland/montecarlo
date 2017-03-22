## Monte Carlo functions (Initial testing)

# Return a function that generates a random variable for
#  a chosen variable distribution

dist_func <- function(dist) {
    switch(dist,
           "constant" = function(param1, ...)
               param1,
           "uniform" = function(param1, param2, ...)
               runif(n=1, min=param1, max=param2),
           "normal" = function(param1, param2, ...)
               rnorm(n=1, mean=param1, sd=param2),
           # ... etc ...
           # default (evaluate text expression)
           function(expr, ...) {eval(parse(text=expr))}
    )
}


# Perform a single Monte Carlo iteration

run_iteration <- function(iter, vars, expr, env_prototype) {
    # Create environment for this iteration
    env <- new.env(parent = env_prototype)
    
    # Populate environment with dataframe of variables
    for (i in seq_along(vars)) {
        dist <- vars[i, "dist"]
        name <- vars[i, "var"]
        p1 <- vars[i, "param1"]
        p2 <- vars[i, "param2"]
        p3 <- vars[i, "param3"]
        text <- vars[i, "expr"]
        env[[name]] <- dist_func(dist)(param1=p1, param2=p2, param3=p3, expr=text)
    }
    
    # Evaluate expression in env
    result <- eval(parse(text=expr), envir=env)
    
    # Return results
    list(n=iter, result=result)
}


# Generate a full set of trial results

run_monte_carlo <- function(vars, n, expr, seed=as.integer(runif(1,0,1e5))) {
    # Input validation
    stopifnot(is.data.frame(vars))
    stopifnot(is.character(expr))
    
    # Initialize
    set.seed(seed)
    env_prototype <- new.env()
    
    # Run
    starttime <- Sys.time()
    outcomes <- lapply(1:n, run_iteration, vars=vars, expr=expr, env_prototype=env_prototype)
    endtime <- Sys.time()
    
    # Generate results
    results <- data.frame(
        iter = sapply(outcomes, function(x) x$n),
        result = sapply(outcomes, function(x) x$result),
        stringsAsFactors = FALSE
    )
    
    attr(results, "starttime") <- starttime
    attr(results, "endtime") <- endtime
    return(results)
}

## Testing

tmp <- function() {
    # define some variables
    vars <- data.frame(
        var=c("x", "y", "z"),
        name=c("X", "Y", "My variable"),
        dist=c("normal", "uniform", "expr"),
        param1=c(3, 5, NA),
        param2=c(2, 10, NA),
        param3=c(NA, NA, NA),
        expr=c(NA, NA, "runif(1,2,3)"),
        stringsAsFactors=FALSE
    )

    n <- 10000
    #expr <- "x + y"
    #expr <- "z <- 4; x <- 0; x + y + z" 
    expr <- "z^2"
    results <- run_monte_carlo(vars, n, expr)
    
    # Results
    hist(results$result)
    #plot(results$result, type="l")
    #plot(cumsum(results$result)/(1:length(results$result)), type="l")
}
