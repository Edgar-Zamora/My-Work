What the f%&gt;% is Moore’s Law?
================================

Moore’s Law refers to a perception that was first formulated by Gordon
Moore who believed that “the number of transistors on a microchip
doubles every two years, though the cost of computers is halved”[1].
With that in mind, there were a multitude of different ways one could
analyze this perception to decide whether it was true or if it was
lacking in credibility.

Keys Visualization takeaways
============================

Creating the visualization
==========================

As is customary when discussing R analysis, I have provided the
necessary packages to replicate my visualization.

``` r
library(tidyverse)
```

    ## ── Attaching packages ───────────────────────────────────────────────────────────────────────────────────────────── tidyverse 1.2.1 ──

    ## ✔ ggplot2 3.2.1     ✔ purrr   0.3.2
    ## ✔ tibble  2.1.3     ✔ dplyr   0.8.3
    ## ✔ tidyr   1.0.0     ✔ stringr 1.4.0
    ## ✔ readr   1.3.1     ✔ forcats 0.4.0

    ## ── Conflicts ──────────────────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
library(scales)
```

    ## 
    ## Attaching package: 'scales'

    ## The following object is masked from 'package:purrr':
    ## 
    ##     discard

    ## The following object is masked from 'package:readr':
    ## 
    ##     col_factor

``` r
library(grid)
library(ggimage)
library(knitr)
```

[1] <a href="https://www.investopedia.com/terms/m/mooreslaw.asp" class="uri">https://www.investopedia.com/terms/m/mooreslaw.asp</a>
