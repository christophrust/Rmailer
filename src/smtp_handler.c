#include <R.h>
#include <Rinternals.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <curl/curl.h>




/* struct holding all the data and upload status information */
struct upload_data_status {
  int lines_read;
  const char **msg_with_mimeB64;
};
 



/* callback function reading data from an above struct */
static size_t read_function(void *ptr, size_t size, size_t nmemb, void *userp)
{
  struct upload_data_status *upload_ctx = (struct upload_data_status *)userp;
  
  const char *data;
 
  if((size == 0) || (nmemb == 0) || ((size*nmemb) < 1)) {
    return 0;
  }

  data = (const char *) upload_ctx->msg_with_mimeB64[upload_ctx->lines_read];

  printf("Line: %s", data);
  
  if(data) {
    size_t len = strlen(data);
    memcpy(ptr, data, len);
    upload_ctx->lines_read++;
 
    return len;
  }
 
  return 0;
}



/* send function */
SEXP send_email(SEXP from, SEXP to, SEXP user, SEXP password,
		SEXP server, SEXP useauth, SEXP usessl, SEXP verifyssl,
		SEXP msg, SEXP ncmsg, SEXP verbose)
{
  
  /* return code */
  SEXP res;
  PROTECT(res = allocVector(INTSXP, 1));
  
  /* get stuff from R objects */
  const char *fromaddr = CHAR(STRING_ELT(from, 0));
  const char *toaddr = CHAR(STRING_ELT(to, 0));
  const char *username = CHAR(STRING_ELT(user, 0));
  const char *passwordp = CHAR(STRING_ELT(password, 0));
  const char *servername = CHAR(STRING_ELT(server, 0));
  const int *iuseauth = INTEGER(useauth);
  const int *iusessl = INTEGER(usessl);
  
  const int *incmsg = INTEGER(ncmsg);
  const int *iverifyssl = INTEGER(verifyssl);
  const int *iverbose = INTEGER(verbose);

  const char *msg_with_mimeB64[*incmsg + 1];
  for (int i = 0; i< *incmsg; i++){
    msg_with_mimeB64[i] = CHAR(STRING_ELT(msg, i));
  }
  msg_with_mimeB64[*incmsg] = NULL;
  
  
  /* initialzie CURL */
  CURL *curl;
  CURLcode crl_res = CURLE_OK;
  struct curl_slist *recipients = NULL;
  struct upload_data_status upload_ctx;
 
  upload_ctx.lines_read = 0;
  upload_ctx.msg_with_mimeB64 = malloc(*incmsg * sizeof(char*));
  upload_ctx.msg_with_mimeB64 = msg_with_mimeB64;
    
  curl = curl_easy_init();

  
  if(curl) {
    /* Set username and password */ 

    if (*iuseauth){
      curl_easy_setopt(curl, CURLOPT_USERNAME, username);
      curl_easy_setopt(curl, CURLOPT_PASSWORD, passwordp);
    }

    /* set server address */
    curl_easy_setopt(curl, CURLOPT_URL, servername);
 
    /* verify certificates */
    if (*iverifyssl==0){
      curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
      curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
    }
    

    curl_easy_setopt(curl, CURLOPT_MAIL_FROM, fromaddr);
    
    /* recipient. */ 
    recipients = curl_slist_append(recipients, toaddr);
    curl_easy_setopt(curl, CURLOPT_MAIL_RCPT, recipients);
 
    /* specify callback function */
    curl_easy_setopt(curl, CURLOPT_READFUNCTION, read_function);
    curl_easy_setopt(curl, CURLOPT_READDATA, &upload_ctx);
    curl_easy_setopt(curl, CURLOPT_UPLOAD, 1L);
 

    /* print verbose information*/
    if (*iverbose){
      curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
    }

    
    /* Send the message */ 
    crl_res = curl_easy_perform(curl);
 
    /* Check for errors */ 
    if(crl_res != CURLE_OK)
      fprintf(stderr, "curl_easy_perform() failed: %s\n",
              curl_easy_strerror(crl_res));
    
    /* Free the list of recipients */ 
    curl_slist_free_all(recipients);
    
    /* cleanup */ 
    curl_easy_cleanup(curl);
  }

  /* pass return code to R */
  INTEGER(res)[0] = (int) crl_res;
  UNPROTECT(1);
  return res;
}
