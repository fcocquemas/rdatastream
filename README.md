# RDatastream

RDatastream is a R interface to the [Thomson Dataworks Enterprise](http://dataworks.thomson.com/Dataworks/Enterprise/1.0/) SOAP API (non free), with some convenience functions for retrieving Datastream data specifically. This package requires valid credentials for this API.

## Notes

* This API happens to be the one used by the [MATLAB datafeed toolbox](http://www.mathworks.fr/help/toolbox/datafeed/datastream.html), so if you have used it before, this package should work as well.
* This package is mainly meant to access Datastream. It should work for [other Dataworks Enterprise sources](http://dtg.tfn.com/data/), but they are quite poorly documented and I do not have valid credentials for most. If you do, and want to see this package extended, please get in touch!
* Not using `SSOAP` is deliberate; I initially toyed with it, and it felt too cumbersome for such a simple API.
* If you feel like some of design choices could be improved, please also get in touch!

## Installation

First, you will need dependencies `XML` and `RCurl`.

    install.packages("XML")
    install.packages("RCurl")

For now, the easiest way to install RDatastream is to use the `devtools` package to get the latest version straight from Github. Install the `devtools` package if you do not have it yet:

    install.packages("devtools")
    
Then load `devtools` and install `RDatastream` from Github.

    library(devtools)
    install_github("RDatastream", username = "fcocquemas")

## Basic use

First, you need to define a user with your valid credentials, like this:

    user <- list(username = "DS:XXXX000", password = "XXX000")

Then you can check which sources you have access to with these credentials:

    dsSources(user)

Hopefully "Datastream" should be among the sources.

Simple requests can then be made. Let's say, for instance, that we want the price and market value of IBM (quoted on the NYSE) on June 4th, 2007. The NYSE tickers are preceeded by `"U:"`, so the DS ticker is `"U:IBM"`.

    dat <- ds(user, securities = "U:IBM", fields = c("P", "MV"), date = "2007-06-04")
    
Or equivalently:

    dat <- ds(user, "U:IBM", c("P", "MV"), "2007-06-04")
    
Checking `data` should show the status code and, if need be, the error message. To look at the data returned as a dataframe, do:

    dat[["Data",1]]
    
Which should be:

      CCY       DATE                DISPNAME FREQUENCY       MV      P SYMBOL
    1  U$ 2007-06-04 INTERNATIONAL BUS.MCHS.         D 157733.1 106.23  U:IBM

You can also specify several tickers and date ranges instead of a single date. For instance, let's add Microsoft (`"@MSFT"`, NASDAQ tickers are preceeded by `"@"`), and let's look from June 4th, 2007 to June 4th, 2009 at the monthly frequency.

    dat <- ds(user, c("U:IBM", "@MSFT"), c("P", "MV"), 
              fromDate = "2007-06-04", toDate = "2009-06-04", period = "M")

As you can seen, each ticker is dealt with in a separate record. To get access to the resulting dataframes, just do:

    dat["Data",]

## Advanced use

### Using custom requests

The Datastream request syntax is somewhat arcane but can be more powerful in certain cases. A [decent guide can be found here](http://dtg.tfn.com/data/DataStream.html). You can use this syntax directly with this package when your needs are more sophisticated.

For instance, let's say I want the data from the previous example combined in a single dataframe.

    request1 <- "U:IBM,@MSFT~=P,MV~2007-06-04~:2009-06-04~M"
    dat <- ds(user, requests = request1)
    dat[["Data",1]]
    
We can run several such requests in a single API call.

    request2 <- "U:MMM~=P,PO~2007-09-01~:2007-09-12~D"
    request3 <- "906187~2008-01-01~:2008-10-02~M"
    request4 <- "PCH#(U:BAC(MV))~2008-01-01~:2008-10-02~M"
    requests <- c(request1, request2, request3, request4)
    dat <- ds(user, requests = requests)
    dat["Data",]

### Other useful tips with the Datastream syntax

#### Get some reference information on a security with `"~XREF"`, including ISIN, industry, etc.

    dat <- ds(user, requests = "U:IBM~XREF") 
    dat[["Data",1]]
    
#### Get some static items like NAME, ISIN with `"~REP"`

    dat <- ds(user, requests = "U:IBM~=NAME,ISIN~REP") 
    dat[["Data",1]]
    
#### Use Datastream expressions, e.g. for a moving average on 20 days

    dat <- ds(user, requests = "MAV#(U:IBM,20D)~2007-09-01~:2009-09-01~D") 
    dat[["Data",1]]

Any other tip we should know about?

## Resources

It is recommended that you read the [Thomson Dataworks Enterprise User Guide](http://dataworks.thomson.com/Dataworks/Enterprise/1.0/documentation/user%20guide.pdf), especially section 4.1.2 on client design. It gives reasonable guidelines for not overloading the servers with too intensive requests.

For building custom Datastream requests, useful guidelines are given on this somewhat old [Thomson Financial Network](http://dtg.tfn.com/data/DataStream.html) webpage. I have been able to replicate all of their examples except for the Navigator search ones.

If you have access codes for the Datastream Extranet, you can use the [Datastream Navigator](http://product.datastream.com/navigator/) to look up codes and data types.

## Licence

RDatastream is released under the MIT licence.
