# plmisot

[English](README.md) · [Español](README.es.md)

R code for the simulation study in:

> Rodríguez, D., Valdora, M., and Vena, P. (2022).
> *Robust estimation in partially linear regression models with monotonicity constraints.*
> Communications in Statistics - Simulation and Computation.
> DOI: [10.1080/03610918.2019.1691732](https://doi.org/10.1080/03610918.2019.1691732)

This is the working implementation the authors used to produce the simulation results in the paper. It is **not** the supplementary material formally submitted to the journal.

## Model

The paper studies the partially linear model

```
y = x' beta + g(t) + epsilon
```

with `g` monotone, in the presence of outliers in the response and the carriers. The repo implements two robust estimators and the simulation study used to compare them.

## Estimators

- **Alv-Yoh** (`type = "nos"`): the proposal of the paper. Combines a robust semiparametric step (Bianco-Boente style) with the monotone M-estimator of Álvarez and Yohai (2012) for isotonic regression.
- **Lu-Du** (`type = "splines"`): the spline-based competitor following Lu (2010), fit by constrained optimization with a choice of loss (`ls`, `huber`, `tukey`, `l1`).

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

`corridas.R` runs the full simulation study (1000 replications per contamination scheme, four bandwidths). The same script also has a smaller toy example. Outputs go to a folder named by the `carpeta` argument; `procesamos.R` and `graficos-paper.R` consume those folders to produce the tables and figures.

Each replication seeds the RNG with its iteration index, so results are reproducible.

## References

- Álvarez, E.E. and Yohai, V.J. (2012). *M-estimators for isotonic regression.* Journal of Statistical Planning and Inference, 142(8), 2351-2368. [doi:10.1016/j.jspi.2012.02.051](https://doi.org/10.1016/j.jspi.2012.02.051)
- Lu, M. (2010). *Spline-based sieve maximum likelihood estimation in the partly linear model under monotonicity constraints.* Journal of Multivariate Analysis, 101(10), 2528-2542. [doi:10.1016/j.jmva.2010.07.002](https://doi.org/10.1016/j.jmva.2010.07.002)
- Rodríguez, D., Valdora, M. and Vena, P. (2022). *Robust estimation in partially linear regression models with monotonicity constraints.* Communications in Statistics - Simulation and Computation. [doi:10.1080/03610918.2019.1691732](https://doi.org/10.1080/03610918.2019.1691732)

## Citation

If you use this code, please cite the paper.
