## Monte Carlo functions

# Helper functions

uniform <- function(min, max) {
    runif(n=1, min=min, max=max)
}
normal <- function(sd, mean) {
    rnorm(n=1, sd=sd, mean=mean)
}

# Perform a single Monte Carlo iteration

run_iteration <- function(n, init, expr, env_proto) {
    # Create environment for this iteration, inheriting from global
    env_init <- new.env(parent = env_proto)

    # Initialize env for this iteration
    env_init$.n <- n
    eval(init, envir=env_init)

    # Evaluate expression in env
    env <- new.env(parent = env_init)
    result <- eval(expr, envir=env)

    # Add additional information to resulting environment
    if(!exists(".Result", envir=env, inherits=FALSE))
        env$.Result <- result

    # Return results
    return(env)
}

# Refactor resulting environments as data frame

env_to_df <- function(outcomes) {
    # Get list of unique variable names included in set
    get_env_ls <- function(env, levels=1, ...) {
        if (levels == 0 | identical(env, emptyenv())) return(NULL)
        return(c(ls(envir=env, ...), get_env_ls(parent.env(env), levels - 1, ...)))
    }

    # vars <- unique(unlist(lapply(outcomes, function(env)
    #     c(ls(envir=parent.env(parent.env(env))), ls(envir=parent.env(env)), ls(envir=env)))))
    # vars <- append(vars, ".Result")

    vars <- c(unique(unlist(lapply(outcomes, get_env_ls, levels=3))), ".Result")

    # Generate the dataframe
    result <- data.frame(.n = 1:length(outcomes))
    for (var in vars) {
        result[[var]] <- sapply(outcomes, function(env) get(var, envir=env, inherits=TRUE))
    }
    (result)
}

# Generate a full set of trial results

run_monte_carlo <- function(n, envir, global, init, expr, seed=as.integer(runif(1,0,1e5))) {
    # Input validation
    stopifnot(
        is.character(global),
        is.character(init),
        is.character(expr)
    )

    # Initialize
    set.seed(seed)
    env_envir <- new.env() #parent=baseenv())
    eval(parse(text=envir), envir=env_envir)
    env_proto <- new.env(parent=env_envir)
    eval(parse(text=global), envir=env_proto)

    # Parse expressions
    pinit <- parse(text=init)
    pexpr <- parse(text=expr)

    # Run
    starttime <- Sys.time()
    outcomes <- lapply(1:n, run_iteration, init=pinit, expr=pexpr, env_proto=env_proto)
    endtime <- Sys.time()

    # Generate results
    results <- new.env(parent = emptyenv())
    results$data <- env_to_df(outcomes)

    results$starttime <- starttime
    results$endtime <- endtime
    results$env <- env_proto
    results$global_vars <- ls(envir=env_proto)
    results$init_vars <- unique(unlist(lapply(outcomes, function(env) ls(envir = parent.env(env)))))
    results$expr_vars <- unique(unlist(lapply(outcomes, function(env) ls(envir = env))))
    return(results)
}
