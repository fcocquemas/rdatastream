\name{ds}
\alias{ds}
\title{Request data from Thomson Reuters Datastream SOAP API.}
\usage{
  ds(user, securities = NULL, fields = NULL, date = NULL,
    fromDate = NULL, toDate = NULL, period = "D",
    requests = NULL, toDataFrame = TRUE,
    source = "Datastream")
}
\arguments{
  \item{user}{list with values username and password.}

  \item{securities}{vector of DS tickers or codes.}

  \item{fields}{vector of DS datatypes.}

  \item{date}{date in yyyy-mm-dd format, if only one day is
  requested.  If set, ignores fromDate, toDate and period.}

  \item{fromDate}{date in yyyy-mm-dd format from which to
  start series.}

  \item{toDate}{date in yyyy-mm-dd format at which to end
  series.}

  \item{period}{character describing the periodicity
  ('D','W','M','Q','Y'), defaults to daily.}

  \item{requests}{a vector of requests following the
  Datastream format.  If set, ignores all other parameters
  (except user). More flexible syntax, notably for the use
  of expressions.}

  \item{toDataFrame}{boolean whether to output a dataframe
  in the "Data" row of the returned matrix.}

  \item{source}{default "Datastream", useful if you want to
  access another Dataworks Enterprise data source. You can
  obtain the list of sources you have access to by using
  the dsSources() function in this package.}
}
\value{
  matrix with the returned data, columns being individual
  requests and rows "Source", "Instrument", "StatusType",
  "StatusCode", "StatusMessage", "Fields" and "Data".
}
\description{
  Request data from Thomson Reuters Datastream SOAP API.
}
\examples{
user <- list(username= "DS:XXXX000", password="XXX000")
ds(user, c("U:IBM", "U:MMM"), c("P", "PO"), "2012-07-20")

request1 <- "U:IBM(P)~~USD~2007-09-01~:2008-09-05~D"
request2 <- "U:BAC~=P,PO~2007-09-01~:2007-09-12~D"
request3 <- "906187~2008-01-01~:2008-10-02~M"
request4 <- "PCH#(U:MMM(MV))~2008-01-01~:2008-10-02~M"
requests <- c(request1, request2, request3, request4)

ds(user, requests=request1)
ds(user, requests=requests)
}

