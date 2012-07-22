\name{dsSources}
\alias{dsSources}
\title{Find available sources from Thomson Reuters Datastream SOAP API.}
\usage{
  dsSources(user)
}
\arguments{
  \item{user}{list with values username and password.}
}
\value{
  matrix with the available sources.
}
\description{
  Find available sources from Thomson Reuters Datastream
  SOAP API.
}
\examples{
user <- list(username= "DS:XXXX000", password="XXX000")
dsSources(user)
}

