## Monte Carlo functions (Alternate approach)

# Perform a single Monte Carlo iteration

run_iteration <- function(n, init, expr, env_proto) {
    # Create environment for this iteration, inheriting from global
    env <- new.env(parent = env_proto)
    
    # Initialize env for this iteration
    env$.n <- n
    eval(init, envir=env)
    
    # Evaluate expression in env
    result <- eval(expr, envir=env)
    
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
    
    # Parse expressions
    pinit <- parse(text=init)
    pexpr <- parse(text=expr)

    # Run
    starttime <- Sys.time()
    outcomes <- lapply(1:n, run_iteration, init=pinit, expr=pexpr, env_proto=env_proto)
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
