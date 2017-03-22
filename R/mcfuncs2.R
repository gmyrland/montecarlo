## Monte Carlo functions (Alternate approach)

# Perform a single Monte Carlo iteration

run_iteration <- function(n, init, expr, env_proto) {
    # Create environment for this iteration, inheriting from global
    env <- new.env(parent = env_proto)
    
    # Initialize env for this iteration
    env$.n <- n
    eval(parse(text=init), envir=env)
    
    # Evaluate expression in env
    result <- eval(parse(text=expr), envir=env)
    
    # Add additional information to resulting environment
    if(!exists(".Result", envir=env)) env$.Result <- result
    
    # Return results
    return(env)
}

# Generate a full set of trial results

run_monte_carlo <- function(n, global, init, expr, seed=as.integer(runif(1,0,1e5))) {
    # Input validation
    stopifnot(
        is.character(global),
        is.character(init),
        is.character(expr)
    )
    
    # Initialize
    set.seed(seed)
    env_proto <- new.env()
    eval(parse(text=global), envir=env_proto)
    
    # Run
    starttime <- Sys.time
    outcomes <- lapply(1:n, run_iteration, init=init, expr=expr, env_proto=env_proto)
    endtime <- Sys.time()
    
    # Generate results
    results <- data.frame(
        n = sapply(outcomes, function(env) env$.n),
        result = sapply(outcomes, function(env) env$.Result),
        stringsAsFactors = FALSE
    )
    
    attr(results, "starttime") <- starttime
    attr(results, "endtime") <- endtime
    return(results)
}

## Testing

tmp <- function() {
    ## Text inputs can be any length of valid R expressions
    
    # global - common to all runs
    global <- "x = 5"
    # definitions for variable distributions
    init   <- "y = rnorm(n=1, mean=0, sd=0.1)
               z = runif(n=1, min=0, max=1)"
    # The executed expression(s), with final value used as result
    expr   <- "x + y + z"
    
    # Execute Monte Carlo
    n <- 1000
    results <- run_monte_carlo(n, global, init, expr)
    
    # Results
    hist(results$result)
}
