## --------------------------------------------------
## Script para crear los graficos del trabajo PLMISOT
##
## 4 de noviembre de 2018
## --------------------------------------------------

## BOXPLOT de las estimaciones de los beta
un_boxplot <- function(cont, files) {
    ## LuDu - clasico
    file_CL <- grep(paste('bic', CL, cont, sep='.*'), files, value=TRUE)
    cols_CL <- max(count.fields(file_CL))
    datos_CL <- read.table(file_CL, col.names = 1:cols_CL, fill = TRUE)
    beta1_CL <- datos_CL[, 11]
    beta2_CL <- datos_CL[, 12]
    ## LuDu - robusto (Huber)
    file_RB <- grep(paste('bic', RB, cont, sep='.*'), files, value=TRUE)
    cols_RB <- max(count.fields(file_RB))
    datos_RB <- read.table(file_RB, col.names=1:cols_RB, fill=TRUE)
    beta1_RB <- datos_RB[, 11]
    beta2_RB <- datos_RB[, 12]
    ## Nosotros - robusto (AY)
    file_ROB <- grep(paste(ROB, cont, sep='.*'), files, value=TRUE)
    cols_ROB <- max(count.fields(file_ROB))
    datos_ROB <- read.table(file_ROB, col.names=1:cols_ROB, fill=TRUE)
    beta1_ROB <- datos_ROB[, 6]
    beta2_ROB <- datos_ROB[, 7]
    ##
    beta1 <- cbind('CL'=beta1_CL, 'HB'=beta1_RB, 'RB'=beta1_ROB)
    beta2 <- cbind('CL'=beta2_CL, 'HB'=beta2_RB, 'RB'=beta2_ROB)
    par(mfrow=c(1,2), oma=c(0.1, 0.1, 0.1, 0.1), mar=c(2, 2, 2, 2))
    boxplot(beta1, plot=TRUE, lwd=1, pch=20)
    abline(h=0.5, col="steelblue", lwd=3, lty=1)
    boxplot(beta2, plot=TRUE, lwd=1, pch=20)
    abline(h=1, col="steelblue", lwd=3, lty=1)
    #title(cont, outer=TRUE)
    b2 <- recordPlot()
    return(b2)
}

## Densidades de los MISE
un_density <- function(cont, files) {
    ## LuDu - clasico
    file_CL <- grep(paste('bic', CL, cont, sep='.*'), files, value=TRUE)
    cols_CL <- max(count.fields(file_CL))
    datos_CL <- read.table(file_CL, col.names = 1:cols_CL, fill = TRUE)
    mise_CL <- datos_CL[, 7]
    ## LuDu - robusto (Huber)
    file_RB <- grep(paste('bic', RB, cont, sep='.*'), files, value=TRUE)
    cols_RB <- max(count.fields(file_RB))
    datos_RB <- read.table(file_RB, col.names=1:cols_RB, fill=TRUE)
    mise_RB <- datos_RB[, 7]
    ## Nosotros - robusto (AY)
    file_ROB <- grep(paste(ROB, cont, sep='.*'), files, value=TRUE)
    cols_ROB <- max(count.fields(file_ROB))
    datos_ROB <- read.table(file_ROB, col.names=1:cols_ROB, fill=TRUE)
    mise_ROB <- datos_ROB[, 4]
    ##
    mise <- cbind('CL'=mise_CL, 'HB'=mise_RB, 'RB'=mise_ROB)
    par(oma=c(0.1, 0.1, 0.1, 0.1), mar=c(2, 2, 2, 2))
    dd <- apply(mise, 2, density)
    ## title(cont, outer=TRUE)
    return(dd)
}

## Todas las salidas
path <- 'salidas/2018-oct-casi-finales'
files <- list.files(path, full.names=TRUE, recursive=TRUE)

## Boxplots 
CL <- 'cl-ls'
RB <- 'cl-huber'
ROB <- 'ay'

contaminaciones <- c('C0',
                     'C1',
                     'C2-extra-1', 'C2-extra-3', 'C2-extra-5',
                     'C3',
                     'C4-extra-5', 'C4-extra-10', 'C4-extra-15')

path <- 'graficos-paper'
if(!dir.exists(path)) dir.create(path)
for (cont in contaminaciones){
    pdf(paste(path, '/', 'betas', cont, '.pdf', sep=''))
    bxplts <- un_boxplot(cont, files)
    dev.off()
    pdf(paste(path, '/', 'mise', cont, '.pdf', sep=''))
    dens <- un_density(cont, files)
    mm <- max(sapply(dens, function(x) max(x$y)))
    plot(dens$CL, lty=1, lwd=3, main='', col='orange', ylim=c(0,mm))
    lines(dens$HB, lty=2, lwd=3, col='blue')
    lines(dens$RB, lty=1, lwd=3, col='darkgreen')
    dev.off()
}

