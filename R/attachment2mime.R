#' @importFrom base64enc base64encode
attachment2mime <- function(fn) {

    text <- strsplit( base64encode(fn, linewidth=72, newline="\r\n\t"), split = "\t", fixed = TRUE)[[1]]
    fname <- basename(fn)

  ## list of some known mime types
  filetype <- tolower(gsub(pattern = "(.*[[:punct:]])([a-z0-9]{1,4})$",
                           replacement = "\\2",
                           fname,
                           ignore.case = TRUE))

  mime_type <- if (filetype == "pdf") {
                 "application/pdf"
               } else if (filetype == "bmp"){
                 "image/bmp"
               } else if (filetype == "csv"){
                 "text/csv"
               } else if (filetype == "doc"){
                 "application/msword"
               } else if (filetype == "docx"){
                 "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
               } else if (filetype == "gif"){
                 "image/gif"
               } else if (filetype %in% c("jpg", "jpeg")){
                 "image/jpeg"
               } else if (filetype == "mp3"){
                 "audio/mpeg"
               } else if (filetype == "mp4"){
                 "video/mp4"
               } else if (filetype == "mpeg"){
                 "video/mpeg"
               } else if (filetype == "png"){
                 "image/png"
               } else if (filetype == "pdf"){
                 "application/pdf"
               } else if (filetype == "txt"){
                 "text/plain"
               } else if (filetype == "xls"){
                 "application/vnd.ms-excel"
               } else if (filetype == "xlsx"){
                 "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
               } else{
                 "application/octet-stream"
               }
    
    mimePart <- c("Content-Type: ", mime_type, "\r\n",
                  paste0("Content-Disposition: attachment; filename=",fname, "\r\n"),
                  "Content-Transfer-Encoding: base64\r\n",
                  "\r\n",
                  text)
    mimePart
}
