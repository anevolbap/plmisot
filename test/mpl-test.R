##
## Rutinas de testeo
##

## TEST MPL-PABLO
mplTest <- function () {
    set.seed(2)
    source('../mpl-pablo.R')
    ven <- 0.5
    nn  <- 5e2
    xx  <- matrix(rnorm(nn*2), nn,2)
    tt  <- runif(nn)
    ff  <- function (x) sin(x * pi/2)
    bb  <- c(-1, 2)
    yy  <- xx %*% bb + ff(tt) + rt(nn,2)
    fit <- mpl_pablo(xx,yy,tt,ven)
    list(fit = fit, tt = tt)
}


fit <- mplTest()
fit$fit$b
ff  <- function (x) sin(x * pi/2)
plot(sort(fit$tt), fit$fit$g)
curve(ff, add=TRUE, col = 'red')

## Benchmark
rm(list = ls())
source('src/simularAY.R')
library(microbenchmark)
mm = microbenchmark(simAlvYoh(datos = 'sosa', nn = 100, out = 'C3', 0.2,
                         from = 1, to = 1,
                         'res7nov', plt = FALSE), unit='s', times = 20)
boxplot(mm)
summary(mm)

