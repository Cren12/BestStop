packages <- c('quantmod',
              'magrittr')

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

source('MakePaths.R')

getSymbols('SPY')
sigma <- TTR::volatility(OHLC = OHLC(SPY),
                         n = 5,
                         calc = 'yang.zhang',
                         mean0 = TRUE) %>%
  last() %>%
  as.numeric()
paths <- MakePaths(sigma = sigma,
                   terminal = 1/12,
                   xinit = as.numeric(last(Cl(SPY))))

