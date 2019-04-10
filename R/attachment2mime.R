#' @importFrom base64enc base64encode
attachment2mime <- function(fn) {

    text <- strsplit( base64encode(fn, linewidth=72, newline="\r\n\t"), split = "\t", fixed = TRUE)[[1]]
    fname <- basename(fn)
    
    
    mimePart <- c("Content-Type: application/octet-stream\r\n",
                  paste0("Content-Disposition: attachment; filename=",fname, "\r\n"),
                  "Content-Transfer-Encoding: base64\r\n",
                  "\r\n",
                  text)
    mimePart
}
