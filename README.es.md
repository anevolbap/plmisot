# plmisot

[English](README.md) · [Español](README.es.md)

Código en R del estudio de simulación de:

> Rodríguez, D., Valdora, M. y Vena, P. (2022).
> *Robust estimation in partially linear regression models with monotonicity constraints.*
> Communications in Statistics - Simulation and Computation.
> DOI: [10.1080/03610918.2019.1691732](https://doi.org/10.1080/03610918.2019.1691732)

Esta es la implementación de trabajo que usamos los autores para producir los resultados de simulación del paper. **No** es el material suplementario que se envió formalmente a la revista.

## Modelo

El paper estudia el modelo parcialmente lineal

```
y = x' beta + g(t) + epsilon
```

con `g` monótona, en presencia de outliers en la respuesta y en las covariables. El repositorio implementa dos estimadores robustos y el estudio de simulación que usamos para compararlos.

## Estimadores

- **Alv-Yoh** (`type = "nos"`): la propuesta del paper. Combina un paso semiparamétrico robusto (al estilo Bianco-Boente) con el M-estimador monótono de Álvarez y Yohai (2012) para regresión isotónica.
- **Lu-Du** (`type = "splines"`): el competidor basado en splines siguiendo a Lu (2010), ajustado por optimización con restricciones y elección de función de pérdida (`ls`, `huber`, `tukey`, `l1`).

## Estructura del repositorio

```
corridas.R          script: corre las simulaciones del paper
procesamos.R        script: arma tablas y gráficos a partir de las salidas
graficos-paper.R    script: produce las figuras del paper
src/
  simular.R         wrappers de simulación (Alv-Yoh y Lu-Du)
  generar.R         generación de datos y esquemas de contaminación (C0, C13, C15, C210, C215, C3)
  mpl.R             estimador Alv-Yoh (parcialmente lineal, monótono)
  minimizar.R       optimización con restricciones para Lu-Du
  procesar.R        post-procesamiento de las salidas
  helpers.R         utilidades chicas
  plotear.R         funciones de ploteo
```

## Dependencias

Paquetes de R: `alabama`, `fda`, `robustbase`, `Hmisc`, `xtable`.

```r
install.packages(c("alabama", "fda", "robustbase", "Hmisc", "xtable"))
```

## Uso

Correr desde la raíz del repo para que se resuelvan los `source('src/...')`.

Estimador Alv-Yoh (`estimate$type = "nos"`, `ven` es el ancho de ventana del kernel):

```r
source("src/simular.R")
simular(datos = "revision",
        nn = 100,
        estimate = list(type = "nos", ven = c(0.15, 0.45, 0.6, 0.3)),
        cont = "C215",
        poda = 0,
        from = 1, to = 5,
        carpeta = "toy-example")
```

Estimador Lu-Du (`estimate$type = "splines"`, `spl` es la cantidad de funciones base B-spline):

```r
source("src/simular.R")
simular(datos = "revision",
        nn = 100,
        estimate = list(type = "splines", initial = "cl", fLoss = "huber", spl = 4:13),
        cont = "C215",
        poda = 0,
        from = 1, to = 5,
        carpeta = "toy-example")
```

`initial` es el punto inicial para la optimización (`"cl"` clásico, `"rb"` robusto, `"ay"` Alv-Yoh).

## Reproducción del paper

`corridas.R` corre el estudio completo del paper (1000 réplicas por esquema de contaminación, cuatro anchos de ventana). El mismo script tiene también un ejemplo chico. Las salidas van a una carpeta nombrada por el argumento `carpeta`; `procesamos.R` y `graficos-paper.R` consumen esas carpetas para producir las tablas y figuras.

Cada réplica fija la semilla con su índice de iteración, así los resultados son reproducibles.

## Referencias

- Álvarez, E.E. y Yohai, V.J. (2012). *M-estimators for isotonic regression.* Journal of Statistical Planning and Inference, 142(8), 2351-2368. [doi:10.1016/j.jspi.2012.02.051](https://doi.org/10.1016/j.jspi.2012.02.051)
- Lu, M. (2010). *Spline-based sieve maximum likelihood estimation in the partly linear model under monotonicity constraints.* Journal of Multivariate Analysis, 101(10), 2528-2542. [doi:10.1016/j.jmva.2010.07.002](https://doi.org/10.1016/j.jmva.2010.07.002)
- Rodríguez, D., Valdora, M. y Vena, P. (2022). *Robust estimation in partially linear regression models with monotonicity constraints.* Communications in Statistics - Simulation and Computation. [doi:10.1080/03610918.2019.1691732](https://doi.org/10.1080/03610918.2019.1691732)

## Cita

Si usás este código, por favor citá el paper.
