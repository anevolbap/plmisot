## modelo: Y = X*beta + g(t) + epsilon
## lo transformamos en Y - X*beta = g(t) + epsilon
## Hacemos una cuenta tomando Esperanza condicional respecto a t y nos sacamos de encima a g(t)
## nos queda Y-Phi_0 = (X-Phi)*beta
## estimamos Phi_0 y Phi_j
## llamamos Z = Y - X*beta si conocieramos Beta entonces tendriamos las pseudoobservaciones Z
## como no conocemos Beta lo estimamos con un estimador robusto de regresion
## 1 - ^Phi y ^Phi_0 (usando estimadores no parametricos robustos, punto 2.3 de tu Tesis y el código que me enviaste ## de Andres)
## 2 - ^beta (estimador de regresión robusto, usando la librería robustbase función lmrob aplicado a Y-^Phi_0 = (X-^P## hi) beta )
## Con todo esto obtenemos pseudo observaciones Ẑ = Y - X ^beta 
## Estimaremos g aplicando el metodo propuesto por Yohai - Alvarez
## Donde Ẑ = g(T) + error, para obtener un estimador de g monotono

library(robustbase) #usamos lmrob
library(Hmisc) #para usar wtd.quantile "Weighted Statistical Estimates"

mpl <- function(xx, yy, xt, ventana) {

    ## --------------------------------------------------------------------
    ## Ordenamos las observaciones 
    ## --------------------------------------------------------------------
    tt_order <- order(xt)
    n  <- dim(xx)[1]
    p  <- dim(xx)[2]
    tt <- as.matrix(xt[tt_order],ncol=n)
    yy <- as.matrix(yy[tt_order],ncol=n)

    for (j in 1:p) {
        xx[,j] <- as.matrix(xx[,j][tt_order],ncol=n)
    }

    ## epsilon <- as.matrix(df$epsilon[tt_order],ncol=dim(df$epsilon)[2])
    ## zz <- seq(min(tt),max(tt),length.out=numero.puntosevaluacion)

                                        #--------------------------------------------------------------------
                                        # Calculo de Phi_{0} y Phi_{j}
                                        #--------------------------------------------------------------------

    phi0_sombrero <- as.matrix(etasombrero(yy,tt,ventana))

    phi_sombrero <- matrix(0,ncol=p,nrow=n)
    for (j in 1:p)
    {
        phi_sombrero[,j] <- etasombrero(as.vector(xx[,j]),tt,ventana)
    }

                                        #--------------------------------------------------------------------
                                        # Calculo de betasombrero
                                        #--------------------------------------------------------------------
    Y <- yy - phi0_sombrero
    X <- xx - phi_sombrero
    modelo <- lmrob(Y ~ X-1,  setting = "KS2011")
    betasombrero <- rep(0,p)
                                        #betasombrero <- cbind(modelo$coefficient[1],modelo$coefficient[2],modelo$coefficient[3])
    lista_coeficientes <- names(modelo$coefficients)

    for (j in 1:p)
    {
        betasombrero[j] <- modelo$coefficients[lista_coeficientes[j]]  
    }

                                        #--------------------------------------------------------------------
                                        # Calculo de gsombrero usando Ẑ = g(tt)+error
                                        #--------------------------------------------------------------------

    Zsombrero <- yy
    for (j in 1:p)
    {
        Zsombrero <- Zsombrero -(xx[,j] * betasombrero[j])
    }

                                        # La funcion musombrero asume que todos los datos se encuentran ordenados de menor a mayor segun tt
    gsombrero <- musombrero(Zsombrero,tt)

    return(list(g = gsombrero, b = betasombrero))

}

etasombrero<- function(zz,tt,ventana) {
    lz  <- length(zz) 
    eta <- rep(0,lz)
    medianalocal <- rep(0,lz)
    madlocal <- rep(0,lz)
    
    wt <- pesos_en_los_ts(tt,ventana)
    
    for(i in 1:lz) {
        medianalocal[i] <- wtd.quantile(zz, weights=wt[i,],type=c('i/n'),probs=c(.5),normwt=TRUE)
        madlocal[i] <- wtd.quantile(abs(zz-medianalocal[i]), weights=wt[i,],type=c('i/n'),probs=c(.5),normwt=TRUE)
    }
    
    for (i in 1:lz) {
        eta[i] <- optimize(objetivo_eta, c(-1000,1000), pesos_filai=wt[i,],zz, escala=madlocal[i])$minimum
    }
    eta
}

objetivo_eta<- function(aa,pesos_filai,zz,escala) {
    sum(pesos_filai*rho.huber((zz-aa)/escala))
}


rho.huber<- function(x,k=1.345) {
    ifelse(abs(x)<=k,(x*x)/2,k*abs(x)-(k*k)/2)
}

pesos_en_los_ts <- function(xt,ventana) {
    lxt <- length(xt)
    wt  <- matrix(0, lxt, lxt)
    
    for(i in 1:lxt) {
        punto  <- xt[i]
        wt[,i] <- nucleo(punto,xt,ventana)
    }
    ## divido por la suma
    sumas<- apply(wt,2,sum)
    wt<- wt/sumas
}

                                        #nucleo de epanechnikov
nucepan<- function(x)
{
    a <- 0.75*(1-x*x)
    kepan<- a*(abs(x)<=1)
    kepan
}

                                        #me da el Kh
nucleo<- function(punto,xt,ventana)
{
    arg<- (punto-xt)/ventana
    nucleovec<- nucepan(arg)
    nucleovec
}

                                        #--------------------------------------------------------------------
                                        # Alvarez - Yohai
                                        #--------------------------------------------------------------------
                                        # La funcion musombrero asume que las observaciones se encuentran ordenadas de menor a mayor segun tt. 

musombrero <- function(zz,tt) {
    lz <- length(zz)
    mu.temp <- matrix(NA,nrow=lz,ncol=lz)
    
                                        #calculo de escala sigma_n inicial y un mu inicial
    m0 <- ltsReg(zz ~ 1)
    betaini <- coef(m0)
    escalaini <- m0$scale
    
                                        #variables para simplificar las operaciones
    unos <- as.matrix(rep(1,lz))
    aa <- seq(1,lz,by=1)
    
    for (ii in 1:lz) {
        for (j in ii:lz) {
            pesosuv <- 1*(aa>=ii)*(aa<=j)
            zzuv <- zz [pesosuv>0]
            unosuv <- as.matrix (unos[pesosuv>0])
            modelo <- lmrob..M..fit(unosuv,zzuv, beta.initial = betaini, scale =escalaini,
                                    control = lmrob.control(tuning.psi = 3.44 ,psi = 'bisquare',
                                                            rel.tol     = 1e-5,
                                                            refine.tol  = 1e-5,
                                                            k.max       = 2e3,
                                                            maxit.scale = 2e3,
                                                            max.it      = 2e3)
                                    )
            mu.temp[ii,j] <- coef(modelo) #$coefficient
        }
    }
    
                                        #ahora calculo mu en cada tt[i].
    mu <- rep(NA,lz)
    aux <- as.matrix(mu.temp[1,1:lz])
    minenv <- apply(aux,2,min)
    mu[1] <- max(minenv)
    
    aux <- t(as.matrix(mu.temp[1:lz,lz]))
    minenv <- apply(aux,2,min)
    mu[lz]<-max(minenv)
    
    lz1<-lz-1
    for(i in 2:lz1)
    {
        aux <- t(as.matrix(mu.temp[1:i,i:lz]))
        minenv<- apply(aux,2,min)
        mu[i]<-max(minenv)
    }
    mu
}
