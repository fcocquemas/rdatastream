#' Find available sources from Thomson Reuters Datastream SOAP API.
#' 
#' @export
#' @param user list with values username and password.
#' @return matrix with the available sources.
#' @examples
#' user <- list(username= "DS:XXXX000", password="XXX000")
#' dsSources(user)
dsSources <- function(user) {
  wsdl <- "http://dataworks.thomson.com/Dataworks/Enterprise/1.0/webServiceClient.asmx"
  xmlns <- "http://xml.thomson.com/financial/v1/tools/distribution/dataworks/enterprise/2003-07/"
 
  
  # SOAP headers
  xmlRequest <- '<?xml version="1.0" encoding="utf-8"?>
<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
  <soap12:Body>'
  
  # SOAP action
  xmlRequest <- paste(xmlRequest, '<Sources xmlns="',
                      xmlns, '">', sep="")
  
  # Add user
  xmlRequest <- paste(xmlRequest, '<User>',
                      '<Username>', user$username, '</Username>',
                      '<Password>', user$password, 
                      '</Password></User>', sep="")
  
  # SOAP footer
  xmlRequest <- paste(xmlRequest, '</Sources>',
                      ' </soap12:Body></soap12:Envelope>', sep="")
  
  # Perform the request
  resp <- getURL(wsdl, 
                 httpheader=c(Accept="text/xml", Accept="multipart/*", 
                              'Content-Type' = "application/soap+xml; charset=utf-8"),
                 postfields=xmlRequest, verbose = FALSE)
  resp <- xmlParse(resp)
  
  # Extract the XML body and convert it to list
  sources <- xmlChildren(resp[["/soap:Envelope/soap:Body/*"]][[1]])
  sources <- sapply(sources, xmlToList)
  sources
}
