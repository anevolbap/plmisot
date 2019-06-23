library(alabama)
library(fda)
library(robustbase)
source('src/generar.R')
source('src/minimizar.R')
source('src/mpl.v7.R')  ## source('src/mpl-pablo.R')


simular <- function (datos, nn, estimate, cont, extra = NULL, poda,
                     from, to, carpeta) {
    
    ## ---------------------------------------
    ## Wrapper for simular_Ludu and simular_AY
    ## ---------------------------------------
    
    if (estimate$type == "nos") {
        lapply(estimate$ven,
               function (ven) {
                   simular_AY(datos = datos,
                              nn = nn,
                              cont = cont,
                              ven = ven,
                              extra = extra,
                              poda = poda,
                              from = from,
                              to = to,
                              carpeta = carpeta)
               })
    }
    
    if (estimate$type == "splines") {
        lapply(estimate$spl,
               function (spl) {
                   simular_LuDu(datos = datos,
                                nn = nn,
                                spl = spl,
                                cont = cont,
                                extra = extra,
                                initial = estimate$initial,
                                fLoss = estimate$fLoss,
                                poda = poda,
                                from = from,
                                to = to,
                                carpeta = carpeta)
               })
    }
}


simular_LuDu <- function (datos, nn, spl, cont, extra = NULL, initial,
                          fLoss, poda, from, to, carpeta) {

    ## -----------------------------------------------------------------
    ## Regresion parcialmente lineal con restricciones de monotonia
    ##
    ## Siguiendo los trabajos de Lu y Du (200?)
    ## -----------------------------------------------------------------
    ## datos  : 'sosa', 'du', 'ay', 'revision'
    ## nn     : sample size
    ## spl    : number of splines
    ## cont   : contamination scheme 'C0', 'C1', ...
    ## initial: 'cl', 'rb', 'ay'
    ## fLoss  : loss function 'ls', 'huber', 'tukey', 'l1'
    ## poda   : trimming for MISE
    ## from   : starting iteration (seed)
    ## to     : last iteration (seed)
    ## carpeta: output folder
    ## -----------------------------------------------------------------
    
    ## Some samples may be discarded
    done <- 0
    iter <- from
    
    while (done <= (to - from)) {
        attempt <- try({
            ## Set seed for reproducibility
            print(c(iter, datos, spl, cont))
            set.seed(iter)
            
            ## Sample and spline basis (unif knots)
            smpl <- generar(datos, nn, cont, extra)
            rr   <- smpl$r
            pp   <- length(smpl$b)
            tt   <- smpl$t
            kns  <- seq(min(tt), max(tt), length = spl - 4 + 2)
            base <- create.bspline.basis(rr, breaks = kns, norder = 4)
            bspl <- getbasismatrix(tt, base)
            
            ## lmrob control parameters
            control <- lmrob.control(trace.level = 0,
                                     tuning.psi  = 3.4434,
                                     nResample   = 5000,
                                     subsampling = 'simple',
                                     rel.tol     = 1e-5,
                                     refine.tol  = 1e-5,
                                     k.max       = 2e3,
                                     maxit.scale = 2e3,
                                     max.it      = 2e3)
            
            ## Initial estimates
            if (initial == 'cl'){ # clasico
                lm_init   <- lm(smpl$y ~ bspl + smpl$x - 1)
                par_init  <- lm_init$coeff
                scl_init  <- 1
                init_conv <- 2
            }
            if (initial == 'rb'){ # robusto
                lm_init   <- lmrob(smpl$y ~ bspl + smpl$x - 1, control = control)
                par_init  <- lm_init$coeff
                scl_init  <- lm_init$scale
                init_conv <- lm_init$init.S$converged
            }
            if (initial == 'ay'){  # monotono Alvarez-Yohai
                ven       <- 0.15
                lm_init   <- monotonopl(smpl$x, smpl$y, smpl$t, ven)
                spl_init  <- lmrob(lm_init$g ~ bspl - 1, control = control)$coeff
                par_init  <- c(spl_init, lm_init$b)
                scl_init  <- 1
                init_conv <- 3
            }

            ## Main estimation
            est   <- plisot(smpl$y, smpl$x, bspl, fLoss, par_init, scl_init)
            error <- (smpl$g - bspl %*% est$spl)^2
            mise  <- mean(error)
            saco  <- floor(nn * poda)
            cual  <- (1 + saco):(nn - saco)
            mise_podado <- mean(error[cual])
        }, silent = FALSE)

        if (!inherits(attempt, 'try-error')) {
            ## Increase the number of successful iterations
            done <- done + 1
            
            ## Save data
            file_name <- paste(initial, fLoss, 'n', nn, from, to, 'cont', cont,
                               'extra', extra, 'spl', spl, sep = '-')
            to_write  <- c(iter, init_conv, est$conv, nn, pp, spl,
                           mise, mise_podado,
                           est$scl, est$val, est$lm, est$spl)
            
            if (!dir.exists(carpeta)) {dir.create(carpeta)}
            aux <- paste(datos, initial, fLoss, 'n', nn, 'cont', cont, sep='-')
            folder_name <- paste(carpeta, aux, sep = '/')
            if (!dir.exists(folder_name)) {dir.create(folder_name)}
            write(to_write, paste(folder_name, file_name, sep = '/'),
                  append = TRUE, ncol = length(to_write))
        }
        
        ## Next iteration...
        iter <- iter + 1
    }
}

simular_AY <- function (datos, nn, cont, extra = NULL, ven, poda, from,
                        to, carpeta) {
    ## ------------------------------------------------------------------
    ## Regresion parcialmente lineal con restricciones de monotonia
    ##
    ## Bianco-Boente (200?) + Alvarez-Yohai (2011)
    ## ------------------------------------------------------------------
    ## datos  : 'sosa', 'ay', 'du'
    ## nn     : sample size
    ## cont    : contamination schemes 'C0', 'C1', 'C2', 'C3', 'C4'
    ## ven    : window size for Alvarez-Yohai estimator
    ## poda   : fraccion de poda en cada borde del intervalo para el MISE
    ## from   : starting iteration
    ## to     : last iteration
    ## carpeta: directorio para guardar las salidas
    ## ------------------------------------------------------------------
    
    ## Some samples may be discarded
    done <- 0
    iter <- from

    while(done <= (to - from)){
        attempt <- try({
            ## Set seed for reproducibility
            print(c(iter, nn, datos, ven, cont))
            set.seed(iter)
            
            ## Sample
            smpl <- generar(datos, nn, cont, extra)
            
            ## Estimation
            est  <- mpl(as.matrix(smpl$x), smpl$y, smpl$t, ven)
	    res  <- smpl$y - smpl$x %*% est$b - est$g
            s1   <- mad(res)   
 	    s2   <- scaleS(res, b = 0.5 , cc = 1.54764)
            error <- (smpl$g[order(smpl$t)] - est$g)^2
            mise <- mean(error)
            saco <- floor(nn * poda)
            cual <- (1 + saco):(nn - saco)
            mise_podado <- mean(error[cual])
        }, silent=FALSE)

        if (!inherits(attempt, 'try-error')) {
            ## Increase the successful number of iterations
            done <- done + 1
            ## Save data
            file_name <- paste('ay', 'n', nn, from, to,
                               'cont', cont, 'extra',extra, 'ven', ven, sep = '-')
            to_write  <- c(iter, s1, s2, mise, mise_podado, est$b, est$g)
            if (!dir.exists(carpeta)) {dir.create(carpeta)}
            aux <- paste(datos, 'ay', 'n', nn, 'cont', cont, 'ven', ven, sep = '-')
            folder_name <- paste(carpeta, aux, sep = '/')
            if (!dir.exists(folder_name)) {dir.create(folder_name)}
            write(to_write, paste(folder_name, '/', file_name, '.txt', sep = ''),
                  append = TRUE, ncol = length(to_write))
        }
        
        ## Next iteration...
        iter <- iter + 1
    }
}

scaleS <- function(u, b = 0.5 , cc = 1.54764) {
    ## find the scale, full iterations
    max.it <- 200
    sc     <- median(abs(u)) / 0.6745
    i      <- 0
    eps    <- 1e-20
    ## magic number alert
    err <- 1
    while(((i <- i + 1) < max.it) && (err > eps)) {
        sc2 <- sqrt(sc^2 * mean(Mchi(u / sc, cc, psi = 'bisquare')) / b)
        err <- abs(sc2 / sc - 1)
        sc  <- sc2
    }
    return(sc)
}
