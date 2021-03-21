# Rmailer
Send mails from R via smtp with encryption and authentication


## Prerequisites

### Linux/Mac

Rmailer is based on libcurl. Therefore, make sure to have libcurl installed (including an ssl library).

For instance, on a Debian-based system type

    sudo apt-get install libcurl4-gnutls-dev

to install libcurl with GNU TLS support. Other SSL/TLS libraries will also work.

### Windows

[Rtools](https://cran.r-project.org/bin/windows/Rtools/) is required to build the package from source. 

A prebuilt binary (thanks to [win-builder](https://win-builder.r-project.org/)) is also available [here](https://christophrust.de/rpkg/Rmailer_0.2.zip).


## Installation

After having gone through the steps above, the package can be installed as follows from R console:

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




