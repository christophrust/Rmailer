# Rmailer
Send mails from R via smtp with encryption and authentication

## Installation (Linux/Mac, Windows not yet supported)

Rmailer is based on libcurl. Therefore, make sure to have libcurl installed (including an ssl library).

For instance, on a Debian-based system type

    sudo apt-get install libcurl4-gnutls-dev

to install libcurl with GNU TLS support. Other SSL/TLS libraries will also work.

From the R-console

```splus
library(devtools)
install_github("christophrust/Rmailer")
```


## Example

```splus
library(Rmailer)


message <- c("Hey,",
             "",
	     "I have a nice pic for you!",
	     "",
	     "Best",
	     "C.")


settings <- list(server = "smtp.example.org",
                 username = "user",
		 password = "password")


## send message:
sendmail(from = "sender@example.org",
         to = "receiver@example.org",
         subject = "Good news!",
         msg = message,
         smtpsettings = settings,
	 attachment = "nice_pic.jpg")
```

## Windows support

If this package appears to be useful for someone who is restricted to work on windows, feel free to write me an email and I will try to provide a binary for Windows.
