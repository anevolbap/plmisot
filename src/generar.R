## --------------------------------------------------
## Generates contaminated data following
##
##        y = x * b + g(t) + error
## --------------------------------------------------
## datos : 'sosa', 'ay', 'du', 'revision'
## nn    : sample size
## out   : 'C0','C1','C2','C2i','C2ii'...
## extra : more parameters...
## --------------------------------------------------


generar <- function (datos, nn, out, extra) {
    switch(datos,
           revision = generar_revision(nn, out),
           sosa     = generar_sosa(nn, out, extra),
           ay       = generar_ay(nn, out),
           du       = generar_du(nn, out))
}


generar_revision <- function (nn, out) {
    ## -----------------------------------
    ## nn  : sample size
    ## out : contamination scheme (string)
    ## -----------------------------------
    
    tt <- runif(nn, 0, 1)
    bb <- c(0.5, 1)
    xx <- matrix(rt(2 * nn,2), nn, 2)
    gg <- sin(pi * tt / 2)
    ee <- rt(nn,2)*0.5
  
    yy <- xx %*% bb + gg + ee

    ## Contamination schemes
    if (out == 'C13') {
        oo <- (0 < tt & tt < 0.1)
        yy[oo == 1] <- 3
    }
    if (out == 'C15') {
        oo <- (0 < tt & tt < 0.1)
        yy[oo == 1] <- 5
    }
    if (out == 'C210') {
        oo <- runif(nn, 0, 1)
        yy[oo > 0.9] <- 10
        xx[oo > 0.9,] <- c(3,1)
    }
    if (out == 'C215') {
        oo <- runif(nn, 0, 1)
        yy[oo > 0.9] <- 15
        xx[oo > 0.9,] <- c(3,1)
    }
    if (out == 'C3') {
        oo <- (0 < tt & tt < 0.1)
        ee[oo == 1] <- runif(sum(oo), 2, 4)
        yy[oo == 1] <- xx[oo == 1,] %*% bb + gg[oo == 1] + ee[oo == 1]
    }
    
    return(list(y = yy, x = xx, t = tt, b = bb, g = gg, e = ee))
}


generar_sosa <- function (nn, out, extra) {
    ## ----------------------------------------------
    ## nn    : sample size
    ## out   : contamination rate
    ## extra : extra parameters for the contamination
    ## ----------------------------------------------
    rr <- c(0, 1)
    tt <- runif(nn, rr[1], rr[2])
    bb <- c(0.5, 1)
    xx <- matrix(rnorm(2 * nn), nn, 2)
    gg <- sin(pi * tt / 2)
    ee <- rnorm(nn, 0, 0.5)

    ## Contamination and errors
    if (out == 'C0') {
        oo <- rep(0, nn)
    }
    if (out == 'C1') {
        oo <- rbinom(nn, 1, 0.1)
        ee[oo == 1] <- runif(sum(oo), 2, 4)
    }
    if (out == 'C2') {
        oo <- (0.4 < tt & tt < 0.5)
        ee[oo == 1] <- rnorm(sum(oo), 5, 0.5)
    }
    if (out == 'C2i') {
        oo <- (0.4 < tt & tt < 0.5)
        ee[oo == 1] <- rnorm(sum(oo), 1, 0.5)
    }
    if (out == 'C2ii') {
        oo <- (0 < tt & tt < 0.1)
        ee[oo == 1] <- 3  # rnorm(sum(oo), 1, 0.5)  # CHECK
    }
    if (out == 'C2iii') {
        oo <- (0.1 < tt & tt < 0.2)
        ee[oo == 1] <- 5  # rnorm(sum(oo), 1, 0.5)  # CHECK
    }
    if (out == 'C3') {
        oo <- rep(0, nn)
        ee <- rnorm(nn, 0, 2)
    }
    if (out == 'C3n') {
        oo <- rep(0, nn)
        ee <- rnorm(nn, 1, 2)
    }
    
    ## Response
    yy <- xx %*% bb + gg + ee

    ## Algunas pruebas de contaminacion nuevas
    if (out == 'C2ej1') {
        oo <- (0 < tt & tt < 0.1)
        yy[oo == 1] <- 1
    }
    if (out == 'C2ej2') {
        oo <- (0.1 < tt & tt < 0.2)
        yy[oo == 1] <- 1
    }
    if (out == 'C2nueva1') {
        oo <- (0 < tt & tt < 0.1)
        yy[oo == 1] <- extra
    }
    if (out == 'C2nueva2') {
        oo <- (0.1 < tt & tt < 0.2)
        yy[oo == 1] <- extra
    }

    ## High leverage 
    if (out == 'C4') {
        oo <- rbinom(nn, 1, 0.1)
        xx[oo == 1] <- c(3, 1)
        yy[oo == 1] <- extra
    }

    return(list(y = yy, x = xx, t = tt,
                b = bb,
                g = gg, r = rr,
                e = ee, out = oo))
}


generar_du <- function (nn, out) {
    ## nn    : sample size
    ## out   : contamination rate
    rr <- c(0, 10)
    tt <- runif(nn, rr[1], rr[2])
    bb <- c(1, 2)
    x1 <- rnorm(nn)
    x2 <- rbinom(nn, 1, 0.5)
    xx <- cbind(x1, x2)
    gg <- exp(tt / 4) - 0.5
    
    ## Contamination and errors
    oo <- rep(0, nn)
    if (out == 'C0') ee <- rnorm(nn, 0, 1)
    if (out == 'C1') ee <- rt(nn, 3)
    if (out == 'C2') ee <- rcauchy(nn)
   
    ## Response
    yy <- xx %*% bb + gg + ee

    return(list(y = yy, x = xx, t = tt,
                b = bb,
                g = gg, r = rr,
                e = ee, out = oo))
}


generar_ay <- function (nn, out) {
    ## -----------------------------------
    ## nn    : sample size
    ## out   : contamination rate
    ## -----------------------------------
    
    rr <- c(0, 1)
    tt <- runif(nn, rr[1], rr[2])
    bb <- c(0.5, 1)
    xx <- matrix(rnorm(2 * nn), nn, 2)
    gg <- 10 + 5 * tt^2
    
    ## Contamination and errors
    oo <- rep(0, nn)
    if (out == 'C0') ee <- rnorm(nn, 0, 1)
    if (out == 'C1') ee <- rt(nn, 3)
   
    ## Response
    yy <- xx %*% bb + gg + ee

    return(list(y = yy, x = xx, t = tt,
                b = bb,
                g = gg, r = rr,
                e = ee, out = oo))
}

