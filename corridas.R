## ---------------------------------
## Corridas para la review del paper
## ---------------------------------

## 500 replicaciones - 24 de junio

source("src/simular.R")

ventanas <- c(0.15, 0.30, 0.45, 0.60)
contaminaciones <- c("C0", "C13", "C15", "C210", "C215", "C3")
experimento <- "salidas-revision-500rep-24jun19"
replicaciones <- 1000

for (cont in contaminaciones) {
    simular(datos = "revision",
            nn = 100,
            estimate = list(type = "nos", ven = ventanas),
            cont = cont,
            poda = 0,
            from = 1,
            to = replicaciones,
            carpeta = experimento)
}

## 1000 replicaciones - 24 de junio 

source("src/simular.R")

ventanas <- c(0.15, 0.30, 0.45, 0.60)
contaminaciones <- c("C0", "C13", "C15", "C210", "C215", "C3")
experimento <- "salidas-revision-1000rep-24jun19"
replicaciones <- 1000

for (cont in contaminaciones) {
    simular(datos = "revision",
            nn = 100,
            estimate = list(type = "nos", ven = ventanas),
            cont = cont,
            poda = 0,
            from = 1,
            to = replicaciones,
            carpeta = experimento)
}


source("src/simular.R")

start <- Sys.time()
ventanas <- 0.15
contaminaciones <- "C215"
experimento <- "salidas-revision-1000rep-24jun19"
replicaciones <- 500

for (cont in contaminaciones) {
    simular(datos = "revision",
            nn = 100,
            estimate = list(type = "nos", ven = ventanas),
            cont = cont,
            poda = 0,
            from = 1,
            to = replicaciones,
            carpeta = experimento)
}

end <- Sys.time()
print(paste("Elapsed time:", end-start))
