plisot <- function(yy, xx, bspl, fLoss, par_init, scl_init) {
    ## -----------------------------------------------------------------
    ## Rutina de minimizacion con restricciones
    ## -----------------------------------------------------------------
    ## yy       : response
    ## xx       : obs por filas
    ## bspl     : matriz splines (por col) evaluados
    ## fLoss    : loss function
    ## par_init : estimador inicial
    ## scl_init : escala inicial
    ## -----------------------------------------------------------------

    ## Change of variables
    spl   <- ncol(bspl)
    cinv  <- lower.tri(diag(spl), diag = T)
    bsplc <- bspl %*% cinv
    init  <- c(par_init[1], diff(par_init[1:spl]), par_init[-(1:spl)])
    
    ## Objective function
    if (fLoss == 'tukey') { # Tukey
        funObj <- function (params) { 
            res <- yy - cbind(bsplc, xx) %*% params
            return(sum(Mchi(res / scl_init, cc = 3.4434,
                            psi = 'bisquare')))
        }
    }
    if (fLoss == 'huber') { # Huber
        funObj <- function (params) { 
            res <- yy - cbind(bsplc, xx) %*% params
            return(sum(Mchi(res, cc = 1.345, psi = 'huber')))
        }
    }
    if (fLoss == 'l1') { # modulo
        funObj <- function (params) {
            res <- yy - cbind(bsplc, xx) %*% params
            return(sum(abs(res)))
        }
    }
    if (fLoss == 'ls') { # cuadrados minimos
        funObj <- function(params) {
            res <- yy - cbind(bsplc, xx) %*% params
            return(sum(res^2))
        }
    }
    
    par_min <- optimizar(init, funObj, spl)    
    par_spl <- cinv %*% par_min$par[1:spl]
    par_lm  <- par_min$par[-(1:spl)]
    val     <- par_min$value

    return(list(spl = par_spl, lm = par_lm, scl = scl_init,
                val = val, conv = par_min$convergence,
                init = par_init))
}

optimizar <- function(init, funObj, k) {
    ## ---------------------------------------------------------------
    ## Rutina de optimizacion
    ## ---------------------------------------------------------------
    ##    init   : punto inicial
    ##    funObj : funcion objetivo
    ##    k      : las variables 2:k tienen restriccion de positividad
    ## ---------------------------------------------------------------


    ## Inequality constrains
    ineq_cons <- function (x) x[2:k]
    
    ## Inequality constrains gradient
    gineq_cons <- function (x) {
        cbind(0, diag(k - 1), matrix(0, k - 1, length(x) - k))
    }
    
    ret <- auglag(par = init,
                  fn  = funObj,
                  hin = ineq_cons,
                  hin.jac = gineq_cons,
                  control.outer = list(trace = F, eps = 1e-10))
    return(ret)
}
