#' sendmail
#'
#' Send e-mails from R via SMTP with authentication and encryption.
#'
#' @param from From address.
#' @param to To address.
#' @param subject subject of email.
#' @param smtpsettings server settings for the smtp server. A list with the following entries:
#' \describe{
#'   \item{server:}{address of smtp server, e.g. smtp.googlemail.com}
#'   \item{port:}{optional port, defaults to 465 (SSL)}
#'   \item{username:}{If server requires authentication, supply username}
#'   \item{password:}{password if required}
#'   \item{usessl:}{If port is set to be different from 465, ssl will not be used by default, can be specified here optionally.}
#' }
#' @param msg character vector holding lines of email or character string with entire message.
#' @param attachment optional character vector containing path of files to be attached.
#' @param verifycert TRUE or FALSE, indicating whether to verify certificate
#'                   of SMTP server. On windows, this defaults to FALSE, on unix-like machines to TRUE.
#'
#' 
#'
#' @useDynLib Rmailer
#' @export
sendmail <- function(from, to, subject, msg, smtpsettings, attachment = NULL,
                     verifycert  = if(.Platform$OS.type == "unix") TRUE else FALSE ){


    ## currently not supported:
    cc <- NULL
    
    verifycert <- as.integer(verifycert)


    if (length(msg) == 0) warning("Message is empty!")
    
    ## get the server information
    server <- smtpsettings[["server"]]
    username <- smtpsettings[["username"]]
    password <- smtpsettings[["password"]]
    useauth <- if (is.null(username)) 0L else 1L

    port <- if (!is.null(smtpsettings[["port"]]))
                smtpsettings[["port"]] else 465
    usessl <- if (!is.null(smtpsettings[["port"]])) {
                  smtpsettings[["port"]]
              } else {
                  if (port == 465) TRUE else FALSE
              }
    server <- paste0(if (usessl) "smtps://" else "smtp://",server)

    ## build up the message

    ## header:
    currenttime <- Sys.time()
    tUTC <- format(currenttime, tz = "UTC", format = "%H")
    diffh <- as.numeric(format(currenttime, format = "%H")) - as.numeric(tUTC)
    diffh <- paste0(if (diffh <0) "-" else "+",
                   if (abs(diffh) <10) paste0("0", abs(diffh),"00") else paste0(diffh,"00"))

    
    months  <- c("Jan","Feb","Mar","Apr","May","Jun", "Jul","Aug","Sep","Oct","Nov", "Dec")
    weekdays <- c("Mon","Tue","Wed","Thu","Fri","Sat","Sun")
    
    header <- paste0("Date: ",
                     weekdays[as.numeric(format(currenttime, format = "%u"))], ", ",
                     format(currenttime, format = "%d"), " ",
                     months[as.numeric(format(currenttime, format = "%m"))]," ",
                     format(currenttime,  format = "%Y"), " ",
                     format(currenttime, format = "%T")," ",
                     diffh, "\r\n")
    
    header <- c(header,
                paste0("To: ", to, "\r\n"),
                paste0("From: ", from, "\r\n"),
                paste0("Cc: ", cc, "\r\n"),
                paste0("Subject: ", subject, "\r\n"),
                "MIME-Version: 1.0\r\n",
                'Content-Type: multipart/alternative; boundary="=_boundary"\r\n')

    
    ## body:
    body <- c("Content-Type: text/plain; charset=utf-8\r\n",
              "Content-Transfer-Encoding: quoted-printable\r\n",
              "\r\n",
              do.call(c,lapply(msg, splitText)))
    
    
    ## attachments if supplied:
    if (!is.null(attachment)){
        attchmnts <- do.call( function(x) c("\r\n", "--=_boundary\r\n",x),
                             lapply(attachment, attachment2mime))
        
    }

    msg <- c(header, "\r\n",
             "--=_boundary\r\n",
             body,
             if (is.null(attachment)) NULL else  attchmnts,
             "\r\n",
             "--=_boundary--")
    
    
    res <- .Call("send_email",
                 from = as.character(from) ,
                 to = as.character(to),
                 nto = as.integer(length(to)),
                 user = as.character(username),
                 password = as.character(password),
                 server = as.character(server),
                 useauth = useauth,
                 usessl = as.integer(usessl),
                 verifyssl = verifycert,
                 msg = msg,
                 nrmsg = as.integer(length(msg)),
                 verbose = 0L,
                 PACKAGE = "Rmailer")
    res
}
