splitText <- function(x, newline = TRUE){
    xo <- x
    lines72max <- NULL
    while (TRUE){
        if (nchar(xo)<=72) {
            lines72max <- c(lines72max, xo)
            break
        }
        nc <- vapply( xos <- strsplit(xo, split = " ")[[1]], function(x) nchar(x) +1, 0, USE.NAMES = FALSE)
        cnc <- cumsum(nc)
        xn <- paste0(xos[1:(which(cnc>72)[1]-1)], collapse = " ")
        lines72max <- c(lines72max, xn)
        xo <- paste0(xos[which(cnc>72)[1]:length(cnc)], collapse = " ")
    }
    if (newline){
        lines72max <- vapply(lines72max, function(x) paste0(x,"\r\n"), "", USE.NAMES = FALSE)
    }
    lines72max
}
