packages <- c('foreach',
              'doFuture')

# +------------------------------------------------------------------
# | library and require load and attach add-on packages. Download and
# | install packages from CRAN-like repositories.
# +------------------------------------------------------------------

lapply(X = packages,
       FUN = function(package){
         if (!require(package = package,
                      character.only = TRUE))
         {
           install.packages(pkgs = package,
                            repos = "https://cloud.r-project.org")
           library(package = package,
                   character.only = TRUE)
         } else {
           library(package = package,
                   character.only = TRUE)    
         }
       })

# +------------------------------------------------------------------
# | Sys.setenv sets environment variables.
# +------------------------------------------------------------------

Sys.setenv(TZ = 'UTC')

# +------------------------------------------------------------------
# | source() causes R to accept its input from the named file or URL
# | or connection or expressions directly.
# +------------------------------------------------------------------

# source()

# +------------------------------------------------------------------

StopScore <- function(
  paths,
  trailing.stop,
  txn.fee
)
{
  # +------------------------------------------------------------------
  # | Register the doFuture parallel adaptor to be used by the foreach 
  # | package.
  # +------------------------------------------------------------------
  
  registerDoFuture()
  
  # +------------------------------------------------------------------
  # | This function allows the user to plan the future, more 
  # | specifically, it specifies how future():s are resolved, e.g. 
  # | sequentially or in parallel. If multicore evaluation is supported,
  # | that will be used, otherwise multisession evaluation will be used.
  # +------------------------------------------------------------------
  
  plan(multiprocess,
       workers = detectCores() - 2)
  
  losses <- foreach(j = 1:ncol(paths), .combine = c) %dopar%
  {
    loss <- 0
    path <- as.vector(paths[, j])
    stop.price <- path[1] * (1 - trailing.stop)
    
    for (i in 2:length(path))
    {
      dx <- path[i] / path[i - 1] - 1
      stop.price <- ifelse(dx > 0, min(path[1], stop.price * (1 + dx)), stop.price)
      
      if (path[i] <= stop.price)
      {
        loss <- stop.price / path[1] - 1 - txn.fee
      }
    }
    
    return(loss)
  }
  
  score <- mean(losses)
  return(score)
}