## Funciones auxiliares

masvotados <- function (file) {
    ## Splines mas votados
    cols  <- max(count.fields(file))
    datos <- read.table(file, col.names = 1:cols, fill = T)
    table(datos[, 6])
}


convergencias <- function (folder) {
    ## Convergencias
    files <- list.files(folder, full.names = TRUE)
    datos <- read.table(files)
    iter  <- datos[, 1]
    conv  <- datos[, 2]
    return(iter[conv == 0])
}


comunes <- function (folder, recursive, pattern = '') {
    ## Iteraciones comunes 
    files   <- list.files(folder, pattern, full.names = TRUE,
                          recursive = recursive)
    idx_all <- lapply(files, function (x) {read.table(x)[, 1]})
    idx_min <- Reduce(intersect, idx_all)
    return(idx_min)
}
