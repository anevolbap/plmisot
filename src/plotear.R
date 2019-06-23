## [4] 
plotear <- function (archivo) { 
    datos <- read.table(archivo)
    nn    <- 100
    smad  <- datos[, 2] 
    ss    <- datos[, 3] 
    mise  <- datos[, 4]
    gg    <- t(datos[, 4 + (1:nn)])
    bb    <- datos[, -(1:(nn + 4))]
    par(mfrow = c(1, 4))
    boxplot(cbind(smad, ss), names = c('MAD', 'M-scale'))
    boxplot(mise, names = c('MISE'))
    boxplot(bb, names = c('beta1', 'beta2'))
    abline(h = c(0.5, 1), col = 'red')
    grilla <- seq(0, 1, length = nn)
    matplot(gg[, sample(ncol(datos), 100)], col = 'gray30', type = 'l')
    lines(sin(grilla * pi / 2), col = 'blue', lwd = 3)
    lines(rowMeans(gg), col = 'red', lwd = 3)
}


grafiquitos <- function(archivo, b1est, b1, b2est, b2, mise){
    pdf(paste(archivo, '-box1', '.pdf', sep=''))
    boxplot(b1est, main = b1)
    abline(h = b1, col = 'red', lty = 2, lwd = 3)
    dev.off()
    ##
    pdf(paste(archivo, '-box2', '.pdf', sep=''))
    boxplot(b2est, main = b2)
    abline(h = b2, col = 'red', lty = 2, lwd = 3)
    dev.off()
    ## Boxplot MISE
    pdf(paste(archivo, 'dens', '.pdf', sep=''))
    b = plot(density(mise), main = 'MISE')
    dev.off()
    
}
