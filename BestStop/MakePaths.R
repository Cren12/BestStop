packages <- c('yuima',
              'foreach',
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

MakePaths <- function(
  sigma,
  terminal, # Terminal time of the grid
  xinit # A number identifying the initial value of the solve.variable
)
{
  drift <- '0 * x'
  diffusion <- paste(sigma, '* x')
  
  # +------------------------------------------------------------------
  # | 'setModel' gives a description of stochastic differential 
  # | equation with or without jumps of the following form:
  # | 
  # | dXt = a(t, Xt, alpha)dt + b(t, Xt, beta)dWt + c(t, Xt, gamma)dZt
  # +------------------------------------------------------------------
  
  yuima.model <- setModel(drift = drift,
                          diffusion = diffusion,
                          solve.variable = 'x',
                          xinit = xinit)
  
  # +------------------------------------------------------------------
  # | setSampling is a constructor for yuima.sampling-class.
  # +------------------------------------------------------------------
  
  yuima.sampling <- setSampling(Terminal = terminal,
                                n = 1000)
  
  # +------------------------------------------------------------------
  # | setYuima constructs an object of yuima-class.
  # +------------------------------------------------------------------
  
  yuima <- setYuima(model = yuima.model,
                    sampling = yuima.sampling)
  
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
  
  paths <- foreach(i = 1:2500, .combine = cbind) %dopar%
  {
    # +------------------------------------------------------------------
    # | Sys.setenv sets environment variables.
    # +------------------------------------------------------------------
    
    sim <- simulate(object = yuima)
    
    return(as.vector(sim@data@zoo.data$`Series 1`))
  }
  
  return(paths)
}