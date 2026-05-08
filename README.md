# plmisot

Simulation code for the paper:

> Rodriguez, D., Valdora, M., and Vena, P. (2019).
> *Robust estimation in partially linear regression models with monotonicity constraints.*
> Communications in Statistics - Simulation and Computation.
> DOI: [10.1080/03610918.2019.1691732](https://doi.org/10.1080/03610918.2019.1691732)

The model is

```
y = x' beta + g(t) + epsilon
```

with `g` monotone. The repo implements two robust estimators and the simulation study from the paper.

## Estimators

- **Alv-Yoh** (`type = "nos"`): the proposal of the paper. Combines a robust semiparametric step (Bianco-Boente style) with the monotone scale-equivariant estimator of Alvarez and Yohai (2012).
- **Lu-Du** (`type = "splines"`): the spline-based competitor of Lu and Du, fit via constrained optimization with a choice of loss (`ls`, `huber`, `tukey`, `l1`).

## Repo layout

```
corridas.R          driver: runs the paper simulations
procesamos.R        driver: builds summary tables and plots from outputs
graficos-paper.R    driver: produces the figures included in the paper
src/
  simular.R         simulation wrappers (Alv-Yoh and Lu-Du)
  generar.R         data generation and contamination schemes (C0, C13, C15, C210, C215, C3)
  mpl.R             Alv-Yoh estimator (partially linear, monotone)
  minimizar.R       constrained optimization for the Lu-Du estimator
  procesar.R        post-processing of simulation outputs
  helpers.R         small utilities
  plotear.R         plotting helpers
```

## Dependencies

R packages: `alabama`, `fda`, `robustbase`, `Hmisc`, `xtable`.

```r
install.packages(c("alabama", "fda", "robustbase", "Hmisc", "xtable"))
```

## Usage

Run from the repo root so the relative `source('src/...')` paths resolve.

Alv-Yoh estimator (`estimate$type = "nos"`, `ven` is the kernel bandwidth):

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

Lu-Du estimator (`estimate$type = "splines"`, `spl` is the number of B-spline basis functions):

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

`initial` is the starting point for the optimization (`"cl"` classical, `"rb"` robust, `"ay"` Alv-Yoh).

## Reproducing the paper

`corridas.R` runs the full study used in the paper (1000 replications per contamination scheme, four bandwidths). The same script also has a small toy example. Outputs go to a folder named by the `carpeta` argument; `procesamos.R` and `graficos-paper.R` consume those folders to produce tables and figures.

Each replication seeds the RNG with its iteration index, so results are reproducible.
