Predicting A Customers Shipping Mode :package:
==============================================

Having seen recent articles and tweets regarding the {tidymodels}
package, I decided to give it a try myself. Today I decide to use the
superstore dataset that is commonly used when working in Tableau. The
superstore data records purchases from fictional customers regarding
various products.

As is customary, we start by loading the necessary packages and data.

``` r
library(tidyverse)
library(tidymodels)
library(janitor)
library(readxl)

orders <- read_excel("data/Global Superstore.xls", sheet = "Orders") %>% 
  clean_names()

#data source: https://community.tableau.com/s/question/0D54T00000C5vSDSAZ/global-superstore-data-file
```

For this post, we use the Superstore dataset from Tableau. The dataset
was found on the Tableau community forum and can found
[here](https://community.tableau.com/s/question/0D54T00000C5vSDSAZ/global-superstore-data-file).

Superstore Data
===============

The superstore dataset consist of transactions (fictional) for customers
order which can be a single item or multiple items. In addition to each
individual item, there are other transactional details like order and
ship date, shipping mode, profit margin and many other items.

``` r
head(orders) %>% 
  select(customer_id, order_date, ship_date, ship_mode, segment,
         shipping_cost, order_priority, profit)
```

    ## # A tibble: 6 x 8
    ##   customer_id order_date          ship_date           ship_mode segment
    ##   <chr>       <dttm>              <dttm>              <chr>     <chr>  
    ## 1 RH-19495    2012-07-31 00:00:00 2012-07-31 00:00:00 Same Day  Consum…
    ## 2 JR-16210    2013-02-05 00:00:00 2013-02-07 00:00:00 Second C… Corpor…
    ## 3 CR-12730    2013-10-17 00:00:00 2013-10-18 00:00:00 First Cl… Consum…
    ## 4 KM-16375    2013-01-28 00:00:00 2013-01-30 00:00:00 First Cl… Home O…
    ## 5 RH-9495     2013-11-05 00:00:00 2013-11-06 00:00:00 Same Day  Consum…
    ## 6 JM-15655    2013-06-28 00:00:00 2013-07-01 00:00:00 Second C… Corpor…
    ## # … with 3 more variables: shipping_cost <dbl>, order_priority <chr>,
    ## #   profit <dbl>

The *main objective* of this post is to **predict a customers shipping
mode** based on a set of predictors.

Exploratory Analysis
====================

Creating A Recipe
=================

Building models
===============

Reporting Results
=================

Conclusions
===========
