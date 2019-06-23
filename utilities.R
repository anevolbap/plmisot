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


##          ## Separar los diferentes archivos con 'extra' de un directorio
##          carpetas <- list.dirs('oct22-final-ludu-cl', recursive=FALSE)
##          carpetas <- grep('C2nueva1', carpetas, value = TRUE)

##          carpetas

##          for (carpeta in carpetas) {
##              idx <- c(1, 3, 5)
##              lapply(idx,
##                     function (idx) {
##                         cond <- paste('extra-', idx, sep='')
##                         files <- list.files(carpeta, pattern=cond, full.names=FALSE)
##                         files_full <- list.files(carpeta, pattern=cond, full.names=TRUE)
##                         for (jter in 1:length(files)) {
##                             destino <- paste('sosa-cl-ls-n-100-out-C2-', cond, sep='')
##                             if (!dir.exists(destino)) dir.create(destino)
##                             file.copy2(from=files_full[jter],
##                                        to=paste('.', destino, files[jter], sep='/'))
##                         }
##                     })
##          }


