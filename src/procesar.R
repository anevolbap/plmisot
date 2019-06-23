## ----------------------------------
## Funciones para procesar los datos
## ----------------------------------


mejor <- function (folder, cuales, criterio) {
    ## --------------------------------------------------
    ## Elige la mejor cantidad de splines por replicacion
    ## --------------------------------------------------    
    ## Por columna los archivos tienen:
    ##  1,       2,      3,  4,  5,  6,     7,  
    ## it, init_cv, est_cv, nn, pp, spl, mise,
    ##           8,   9, 10,  11,  12  
    ## mise_podado, scl, val, lm, spl
    ## --------------------------------------------------    
    
    files <- list.files(folder, full.names = TRUE)
    crits <- sapply(files, function(x) { 
        datos <- read.table(x)
        iter <- match(cuales, datos[, 1])
        datos <- datos[iter, ]
        nn <- unique(datos[, 4])
        pp <- datos[, 5]
        spl <- datos[, 6]
        scl <- datos[, 9]
        val <- datos[, 10]
        switch(criterio,
               hic1 = log(scl^2*val) + spl*log(nn) / (2*nn) + 2*pp/nn,
               hic2 = log(scl^2) + val/nn + spl*log(nn)/(2*nn) + 2*pp/nn,
               bic = log(scl^2*val) + (spl+pp)*log(nn) / (2*nn),
               aic = log(scl^2*val) + 2*(spl + pp)/nn)
    }, USE.NAMES = FALSE)
    best <- apply(crits, 1, which.min)
    mapply(function (n, x) {
        fila <- unlist(read.table(files[x])[n, ])
        aux <- strsplit(folder,'/')[[1]]
        write(fila, paste(criterio, aux[length(aux)],
                          sep = '-'), length(fila), TRUE)
    }, cuales, best)
}


resumir <- function (archivo, ff, bb, rango, plt = FALSE) {
    ## ---------------------------------------------------------
    ## Wrapper for resumir_LuDu and resumir_AY
    ## ---------------------------------------------------------
    
    estimator <- strsplit(basename(archivo), "-")[[1]][[1]]
    
    if (estimator == "ay") {
        ret <- resumir_AY(archivo, ff, bb, rango, cuales, plt)
    } else {
        ret <- resumir_LuDu(archivo, ff, bb, rango, plt)
    }
    
    return (ret)
}


resumir_LuDu <- function (archivo, ff, bb, rango, plt = FALSE) {
    ## ---------------------------------------------------------
    ## Resume una salida de LuDu
    ##
    ## ff: parte no parametrica
    ## bb: betas verdaderos
    ## rango: rango para los splines
    ##
    ##
    ## Por columna los archivos tienen:
    ##  1,       2,      3,  4,  5,  6,     7,            8,
    ## it, init_cv, est_cv, nn, pp, spl, mise,  mise_podado
    ##   9, 10,  11, 12
    ## scl, val, lm, spl
    ## ---------------------------------------------------------

    cols  <- max(count.fields(archivo))
    datos <- read.table(archivo, col.names = 1:cols, fill = T)
    datos[is.na(datos)] <- 0

    ## The truth
    nn  <- unique(datos[, 4])
    pp  <- unique(datos[, 5])
    ttt <- seq(0, 1, length = nn)
    gg  <- ff(ttt)

    ## Evaluated estimators for each replication
    evaluar <- function (fila) {
        set.seed(fila[1])
        tt <- runif(nn, rango[1], rango[2])
        spl <- fila[6]
        params <- fila[-(1:10)]
        gg_par <- params[pp + 1:spl]
        bb_est <- params[1:pp]
        kns <- seq(min(tt), max(tt), length = spl - 4 + 2)
        basis <- create.bspline.basis(rangeval = rango, breaks = kns,
                                      norder = 4)
        bspl <- getbasismatrix(ttt, basis)
        gg_est <- bspl %*% as.vector(gg_par)
        return(c(bb_est, gg_est))
    }
    ests <- t(apply(datos, 1, evaluar))
    
    ## Parametric term (beta)
    betas <- ests[, 1:pp]
    SD <- apply(betas, 2, sd)
    resta <- sweep(betas, 2, bb)
    bias <- colMeans(resta)
    MSE <- colMeans((resta)^2)

    ## Non-parametric term (monotone function)
    gg_est <- ests[, -(1:pp)]
    paso <- 1 / (length(ttt) - 1)
    ISE <- rowSums(sweep(gg_est, 2, gg)^2) * paso
    MISE2 <- mean(ISE)
    MISE1 <- mean(datos[, 8])
        
    ## Plots
    if (plt == 1) {
        par(mfrow = c(1, 4))
        matplot(ttt, t(gg_est), type = 'l', col = 1, lty = 2,
                main = 'No param')
        lines(ttt, gg, type = 'l', col = 'red', lwd = 3)
        lines(ttt, colMeans(gg_est), col = 'blue', lwd = 3)
        legend('topleft', legend = c('est','g','mean'),
               lty = c(2, 1, 1), lwd = 3,
               col = c('black','red','blue'))
        ## Boxplot beta1
        boxplot(betas[, 1], main = 'beta = 0.5')
        abline(h = bb[1], col = 'red', lty = 2, lwd = 3)
        ## Boxplot beta2
        boxplot(betas[, 2], main = 'beta = 1')
        abline(h = bb[2], col = 'red', lty = 2, lwd = 3)
        ## Boxplot MISE
        b <- boxplot(datos[,7], main = 'MISE')
        print(b$o)
    }
    ## Plots
    if (plt == 2) {
        grafiquitos(archivo,
                    betas[, 1], bb[1],
                    betas[, 2], bb[2],
                    datos[, 8])
    }
    return(c(bias = bias, sd = SD, MSE = MSE,
             MISE1 = MISE1, MISE2 = MISE2))
}

resumir_AY <- function (archivo, ff, bb, rango, cuales, plt) {
    ## -------------------------------------------------------
    ## Resume una salida de Alvarez-Yohai
    ##
    ## Las salidas son:
    ##    1   2   3     4      5      6...
    ## iter, s1, s2, mise, misep, est$b, est$g
    ## -------------------------------------------------------

    datos <- read.table(archivo)[cuales, ]

    ## True parameters
    pp <- length(bb)
    tt <- seq(rango[1], rango[2], length = 100)
    gg <- ff(tt)

    ## Estimates
    estims <- datos[, -(1:5)]
    bb_est <- estims[, 1:pp]
    gg_est <- estims[, -(1:pp)]

    ## Summary
    resta <- sweep(bb_est, 2, bb)
    bias  <- colMeans(resta)
    SD    <- apply(bb_est, 2, sd)
    MSE   <- colMeans((resta)^2)
    MISE  <- mean(datos[, 4])
    MISEp <- mean(datos[, 5])
    
    ## Plots
    if (plt == 1) {
        par(mfrow = c(1, 4))
        matplot(tt, t(gg_est), type = 'l', col = 1, lty = 2,
                main = 'No param')
        lines(tt, gg, type = 'l', col = 'red', lwd = 3)
        lines(tt, colMeans(gg_est), col = 'blue', lwd = 3)
        legend('topleft', legend = c('est','g','mean'),
               lty = c(2, 1, 1), lwd = 3, col = c('black','red','blue'))
        #
        boxplot(bb_est[, 1], main = bb[1])
        abline(h = bb[1], col = 'red', lty = 2, lwd = 3)
        #
        boxplot(bb_est[, 2], main = bb[2])
        abline(h = bb[2], col = 'red', lty = 2, lwd = 3)
        ## Boxplot MISE
        b = boxplot(datos[,4], main = 'MISE')
    }
    ## Plots
    if (plt == 2) {
        grafiquitos(archivo,
                    bb_est[, 1], bb[1],
                    bb_est[, 2], bb[2],
                    datos[, 5])
    }
    return(c(bias = bias, sd = SD, MSE = MSE, MISE = MISE,
             MISEp = MISEp))
}
