
<!-- README.md is generated from README.Rmd. Please edit that file -->
openLEIr
========

openLEIr is an R package providing an unofficial API to openleis.com

Installation
------------

You can install openLEIr from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("vh-d/openLEIr")
```

Example
-------

Use `openLEIs()` to get results for a vector of LEI ids in a list:

``` r
library(openLEIr)

companies <- openLEIr::openLEIs(c("HWUPKR0MPOU8FGXBT394", "5493006MHB84DD0ZWV18", "549300FI8QIVYMUMBB43"))
```

``` r
companies[[1]]$registered_name
#> [1] "Apple Inc."
companies[[2]]$registered_name
#> [1] "Alphabet Inc."
```

Reshaping
---------

Convert to tabular data (a data.table) using `LEIs2dt()`.

In a wide shape

``` r
DT <- LEIs2dt(companies, wide = TRUE)
```

``` r
DT[, .(lei, registered_name, legal_form, 
       headquarter_country_code, headquarter_city, lei_assignment_date)]
#>                     lei                 registered_name   legal_form headquarter_country_code headquarter_city      lei_assignment_date
#> 1: HWUPKR0MPOU8FGXBT394                      Apple Inc. INCORPORATED                       US        Cupertino 2012-06-06T15:53:06.000Z
#> 2: 5493006MHB84DD0ZWV18                   Alphabet Inc. INCORPORATED                       US    Mountain View 2015-08-31T16:16:47.000Z
#> 3: 549300FI8QIVYMUMBB43 Nokia Solutions and Networks Oy   OSAKEYHTIO                       FI            Espoo 2014-01-17T15:23:13.000Z
```

Or as a long table:

``` r
LEIs2dt(companies, wide = FALSE)
#>                       lei           field                                                                               value
#>   1: HWUPKR0MPOU8FGXBT394              id                                                                              101114
#>   2: 5493006MHB84DD0ZWV18              id                                                                              141115
#>   3: 549300FI8QIVYMUMBB43              id                                                                              165420
#>   4: HWUPKR0MPOU8FGXBT394 registered_name                                                                          Apple Inc.
#>   5: 5493006MHB84DD0ZWV18 registered_name                                                                       Alphabet Inc.
#>  ---                                                                                                                         
#> 107: 5493006MHB84DD0ZWV18      source_url https://www.gleif.org/lei-files/20180211/GLEIF/20180211-GLEIF-concatenated-file.zip
#> 108: 549300FI8QIVYMUMBB43      source_url https://www.gleif.org/lei-files/20180211/GLEIF/20180211-GLEIF-concatenated-file.zip
#> 109: HWUPKR0MPOU8FGXBT394    retrieved_at                                                            2018-02-11T02:33:03.000Z
#> 110: 5493006MHB84DD0ZWV18    retrieved_at                                                            2018-02-11T02:33:03.000Z
#> 111: 549300FI8QIVYMUMBB43    retrieved_at                                                            2018-02-11T02:33:03.000Z
```
