# Rmailer
Send mails from R via smtp with encryption and authentication

# Installation

Rmailer is based on libcurl. Therefore, make sure to have libcurl installed (including an ssl library).

For instance, on a Debian-based system type

    sudo apt-get install libcurl4-gnutls-dev

to install libcurl with GNU TLS support. Other SSL/TLS libraries will also work.

From the R-console

```splus
library(devtools)
install_github("christophrust/Rmailer")
```


# Example

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
         msg = message
         smtpsettings = settings,
	 attachment = "nice_pic.jpg")
```

