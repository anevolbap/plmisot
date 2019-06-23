# PLMIsot

### Argumentos (según estimate$type):
* splines:
 * initial: "cl", "rb", "ay"
 * fLoss: "tukey", "huber", "l1", "ls"
 * spl: list or vector
* nos:
 * ven: list or vector

=======

### Ejemplos:
  * Nosotros
```R
source("src/simular.R")
simular(datos = "revision", nn = 100, estimate = list(type = "nos", ven = c(0.15, 0.45, 0.6, 0.3)), 
cont = "C215", poda = 0, from = 1, to = 5, carpeta = "toy-example")
```
  * Lu-Du
```R
source("src/simular.R")
simular(datos = "revision", nn = 100, estimate = list(type = "splines", initial = "cl", fLoss = "huber", spl = 4:13), cont = "C215", poda = 0, from = 1, to = 5, carpeta = "toy-example")
```

=======

