##
## Comparacion del mpl original (dani) y el nuevo (yo)
##

rm(list=ls())
set.seed(1)
source("mpl-pablo.R")

rm(list=ls())
set.seed(1)
source("mpl.v7.R")

nn <- 50
pp <- 2
tt <- runif(nn, 0, 1)
gg <- function (t) sin(pi * t / 2)
xx <- matrix(rnorm(nn * pp), nn, pp)
yy <- drop(xx %*% c(0.5, 2)) + gg(tt)


dani <- mpl_dani(xx, yy, xt = tt, ventana = 0.2)
dani

pablo <- mpl_pablo(xx, yy, tt = tt, ven = 0.2)
pablo



mpl_pablo(xx, yy, tt = tt, ven = 0.2)
