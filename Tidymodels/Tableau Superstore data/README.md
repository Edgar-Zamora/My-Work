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
library(lubridate)

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
order, including single and bulk orders. In addition to each individual
item, there are other transactional details like order and ship date,
shipping mode, profit margin and many other items. Below you can see the
complete list that is available

    ##  [1] "row_id"         "order_id"       "order_date"     "ship_date"     
    ##  [5] "ship_mode"      "customer_id"    "customer_name"  "segment"       
    ##  [9] "city"           "state"          "country"        "postal_code"   
    ## [13] "market"         "region"         "product_id"     "category"      
    ## [17] "sub_category"   "product_name"   "sales"          "quantity"      
    ## [21] "discount"       "profit"         "shipping_cost"  "order_priority"

The *main objective* of this post is to **predict a products shipping
mode** based on a set of predictors.

Though all factors may be relevant in helping to predict the shipping
mode of a customer, I decide to limit it to a few that I believe matter.
Note that this decision is not based on any scientific analysis or reach
but but instead is my perspective. The variables I decide to go with are
*order date*, *shipping data*, *segment*, *shipping cost*, *order
priority*, and *profit*.

``` r
head(orders) %>% 
  select(customer_id, order_date, ship_mode, segment,
         shipping_cost, order_priority, profit)
```

    ## # A tibble: 6 x 7
    ##   customer_id order_date          ship_mode segment shipping_cost order_priority
    ##   <chr>       <dttm>              <chr>     <chr>           <dbl> <chr>         
    ## 1 RH-19495    2012-07-31 00:00:00 Same Day  Consum…          934. Critical      
    ## 2 JR-16210    2013-02-05 00:00:00 Second C… Corpor…          924. Critical      
    ## 3 CR-12730    2013-10-17 00:00:00 First Cl… Consum…          915. Medium        
    ## 4 KM-16375    2013-01-28 00:00:00 First Cl… Home O…          910. Medium        
    ## 5 RH-9495     2013-11-05 00:00:00 Same Day  Consum…          903. Critical      
    ## 6 JM-15655    2013-06-28 00:00:00 Second C… Corpor…          897. Critical      
    ## # … with 1 more variable: profit <dbl>

Exploratory Analysis
====================

Prior to deleving into some exploratory analysis, we first must
transform the data into a format that will allow use to visualize and
model our data.

``` r
orders %>% 
  select(customer_id, order_date, ship_mode, segment,
         shipping_cost, order_priority, profit) %>% 
  group_by(customer_id, order_date) %>% 
  mutate(num_in_order = n()) %>% 
  ungroup() %>% 
  mutate(order_month = month(order_date),
         segment = case_when(segment == "Consumer" ~ 1,
                             segment == "Corporate" ~ 2,
                             TRUE ~ 3), #Home Office
         ship_mode = case_when(ship_mode == "Same Day" ~ 1,
                               ship_mode == "First Class" ~ 2,
                               ship_mode == "Second Class" ~ 3,
                               TRUE ~ 4), # Standard Class
         order_priority = case_when(order_priority == "Critical" ~ 1,
                                    order_priority == "High" ~ 2,
                                    order_priority == "Medium" ~ 3,
                                    TRUE ~ 4)) %>%  #Low
  select(-c(customer_id, order_date))
```

    ## # A tibble: 51,290 x 7
    ##    ship_mode segment shipping_cost order_priority  profit num_in_order
    ##        <dbl>   <dbl>         <dbl>          <dbl>   <dbl>        <int>
    ##  1         1       1          934.              1   762.             3
    ##  2         3       2          924.              1  -289.             4
    ##  3         2       1          915.              3   920.             5
    ##  4         2       3          910.              3   -96.5            1
    ##  5         1       1          903.              1   312.             1
    ##  6         3       2          897.              1   763.             5
    ##  7         2       1          895.              1   565.             2
    ##  8         4       1          878.              2   996.             1
    ##  9         4       2          868.              4  1906.             3
    ## 10         3       1          866.              1 -1862.             1
    ## # … with 51,280 more rows, and 1 more variable: order_month <dbl>

Creating A Recipe
=================

Building models
===============

Reporting Results
=================

Conclusions
===========
