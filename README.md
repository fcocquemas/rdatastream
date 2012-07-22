# RDatastream

RDatastream is a R interface to the [Thomson Dataworks Enterprise](http://dataworks.thomson.com/Dataworks/Enterprise/1.0/) SOAP API (non free), with some convenience functions for retrieving Datastream data specifically. This package requires valid credentials for use with this API.

For now, the easiest way to install RDatastream is to use the `devtools` package:

    install.packages("XML")
    install.packages("RCurl")
    
    # install.packages("devtools")
    library(devtools)
    install_github("RDatastream", username = "fcocquemas")

## Recommendations

It is recommended that you read the [Thomson Dataworks Enterprise User Guide](http://dataworks.thomson.com/Dataworks/Enterprise/1.0/documentation/user%20guide.pdf), especially section 4.1.2 on client design. It gives reasonable guidelines for not overloading the servers with too intensive requests.

## Licence

RDatastream is released under the MIT licence.
