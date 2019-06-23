##
## Rutina para procesar las salidas 
##

library(xtable)
library(fda)
source('src/procesar.R')
source('src/helpers.R')

## ---------------------
## Alvarez-Yohai (nos)
## ---------------------

## Parametros verdaderos
bb <- c(0.5, 1)
rango <- c(0, 1)
ff <- function (x) sin(x * pi / 2)

## Resumo las salidas y armo la tabla
carpeta <- 'salidas-toy-example'
cuales <- comunes(carpeta, TRUE, patron)
files <- list.files(carpeta, full.names = TRUE, recursive = TRUE,
                    pattern = 'ay')

tablas <- t(sapply(files, resumir, ff = ff, bb = bb, rango = rango,
                   plt = FALSE, cuales, USE.NAMES = TRUE))

rownames(tablas) <- basename(files)
tabla_ay <- round(tablas, 4)

## Exporto la tabla a latex
print(xtable(resumen_ayso, digits = 4))

## Plots (boxplot y density)
sapply(files, resumir, ff=ff, bb=bb, rango=rango, plt = 2)

## Mover los archivos pdf
##          carpeta <- 'salidas/2018-oct-casi-finales/oct5-final-ay'
##          files <- list.files(carpeta, full.names=TRUE, recursive=TRUE, pattern='.pdf')
##          fff <- function(x) file.copy2(x, paste(carpeta, rev(strsplit(x,'/')[[1]])[1], sep='/'))
##          sapply(files, fff)
##          rev(strsplit('a/b','/')[[1]])[1]

## TODO: pendiente

## -------
## Lu-Du
## -------

## Parametros verdaderos
bb_sosa    <- c(0.5, 1)
rango_sosa <- c(0, 1)
ff_sosa    <- function (x) sin(x * pi / 2)

## Calculo los mejores
carpeta  <- 'oct22-final-ludu-cl'
cuales   <- comunes(carpeta, TRUE)
files    <- list.dirs(carpeta, full.names = TRUE, recursive = FALSE)
lapply(files, mejor, cuales, 'bic')

## Resumo las salidas
carpeta  <- '.'
files <- list.files(carpeta, 'bic', full.names = TRUE, recursive = FALSE)

tabla_ludu <- t(sapply(files, resumir, ff_sosa, bb_sosa, rango_sosa))
round(tabla_ludu, 4)

## Exporto la tabla a latex
print(xtable(tabla_ludu, digits = 4))

## Miro algun grafico para ver que onda
resumir(files, ff_sosa, bb_sosa, rango_sosa, plt=2)

## Plots (boxplot y density)
sapply(files, resumir, ff=ff_sosa, bb=bb_sosa, rango=rango_sosa, plt=2)
