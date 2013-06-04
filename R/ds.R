#' Request data from Thomson Reuters Datastream SOAP API.
#' 
#' @export
#' 
#' @param user list with values username and password.
#' @param securities vector of DS tickers or codes.
#' @param fields vector of DS datatypes.
#' @param date date in yyyy-mm-dd format, if only one day is requested.
#'   If set, ignores fromDate, toDate and period.
#' @param fromDate date in yyyy-mm-dd format from which to start series.
#' @param toDate date in yyyy-mm-dd format at which to end series.
#' @param period character describing the periodicity ('D','W','M','Q','Y'),
#'   defaults to daily.
#' @param requests a vector of requests following the Datastream format.
#'   If set, ignores all other parameters (except user). More flexible
#'   syntax, notably for the use of expressions.
#' @param asDataFrame boolean whether to output a dataframe in the "Data"
#'   row of the returned matrix.
#' @param source default "Datastream", useful if you want to access another
#'   Dataworks Enterprise data source. You can obtain the list of sources
#'   you have access to by using the dsSources() function in this package.
#' @return matrix with the returned data, columns being individual requests
#'   and rows "Source", "Instrument", "StatusType", "StatusCode", 
#'   "StatusMessage", "Fields" and "Data".
#' @examples
#' user <- list(username= "DS:XXXX000", password="XXX000")
#' ds(user, c("U:IBM", "U:MMM"), c("P", "PO"), "2012-07-20")
#' 
#' request1 <- "U:IBM(P)~~USD~2007-09-01~:2008-09-05~D"
#' request2 <- "U:BAC~=P,PO~2007-09-01~:2007-09-12~D"
#' request3 <- "906187~2008-01-01~:2008-10-02~M"
#' request4 <- "PCH#(U:MMM(MV))~2008-01-01~:2008-10-02~M"
#' requests <- c(request1, request2, request3, request4)
#' 
#' ds(user, requests=request1)
#' ds(user, requests=requests)
ds <- function(user, securities=NULL, fields=NULL, 
               date=NULL, fromDate=NULL, toDate=NULL,
               period="D", requests=NULL, asDataFrame=TRUE,
               source="Datastream") {
  wsdl <- "http://dataworks.thomson.com/Dataworks/Enterprise/1.0/webServiceClient.asmx"
  xmlns <- "http://xml.thomson.com/financial/v1/tools/distribution/dataworks/enterprise/2003-07/"
  
  # If requests is not set, create it from the pieces
  if(is.null(requests)) {
    requests <- securities
    if(!is.null(fields)) {
      requests <- paste(requests, "~=", paste(fields, collapse=","), sep="")
    }
    
    if(!is.null(date)) {
      requests <- paste(requests, "~@", date, sep="")
    } else {
      if(!is.null(fromDate)) {
        requests <- paste(requests, "~", fromDate, sep="")
      }
      if(!is.null(toDate)) { 
        requests <- paste(requests, "~:", toDate, sep="")
      }
      requests <- paste(requests, "~", period, sep="")
    }
  }
  
  # SOAP headers
  xmlRequest <- '<?xml version="1.0" encoding="utf-8"?>
<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
  <soap12:Body>'
  
  # SOAP action
  xmlRequest <- paste(xmlRequest, '<RequestRecordsAsXml xmlns="',
                      xmlns, '">', sep="")
  
  # Add user
  xmlRequest <- paste(xmlRequest, '<User>',
                      '<Username>', user$username, '</Username>',
                      '<Password>', user$password, 
                      '</Password></User><Requests>', sep="")
  
  # Add the requests 
  xmlRequest <- paste(xmlRequest, 
                      paste('<RequestData><Source>', source, '</Source><Instrument>',
                            requests, '</Instrument>',
#                             ifelse(is.null(options), '', 
#                                    paste('<Options>', options, '</Options>', sep="")),
                            '</RequestData>', 
                            sep="", collapse=""), sep="")
  
  # SOAP footer
  xmlRequest <- paste(xmlRequest, '</Requests>',
                      '<RequestFlags>0</RequestFlags>',
                      '</RequestRecordsAsXml>',
                      ' </soap12:Body></soap12:Envelope>', sep="")
  
  # Perform the request
  resp <- getURL(wsdl, 
                 httpheader=c(Accept="text/xml", Accept="multipart/*", 
                              'Content-Type' = "application/soap+xml; charset=utf-8"),
                 postfields=xmlRequest, verbose = FALSE)
  resp <- xmlParse(resp)
  
  # Extract the XML body and convert it to list
  records <- xmlChildren(resp[["/soap:Envelope/soap:Body/*"]][[1]][[1]])
  records <- sapply(records, xmlToList)
  
  # Convert the obtained data to a dataframe
  if(asDataFrame) {
    records <- rbind(records, apply(records, 2, function(record) {
      as.data.frame(sapply(names(record$Fields), function(fieldname){
        field <- record$Fields[[fieldname]]
        
        # Fix some NULL fields when e.g. no currency (price index variable)
        if(is.null(field)) field <- NA
        
        if(fieldname == "DATE") {
          list(as.Date(unlist(field)))
        } 
        else if(is.list(field)) {
          list(as.numeric(gsub("NaN", NA, as.character(unlist(field)))))
        }
        else {
          list(rep(field, 1, length(record$Fields$DATE)))
        }
      }))
    }))
    rownames(records)[7] <- "Data"
  }
  
  records
}

