    ## ── Attaching packages ───────────────────────────────────────────────────────── tidyverse 1.3.0 ──

    ## ✓ ggplot2 3.3.0     ✓ purrr   0.3.4
    ## ✓ tibble  3.0.1     ✓ dplyr   0.8.5
    ## ✓ tidyr   1.0.0     ✓ stringr 1.4.0
    ## ✓ readr   1.3.1     ✓ forcats 0.4.0

    ## Warning: package 'tibble' was built under R version 3.6.2

    ## Warning: package 'purrr' was built under R version 3.6.2

    ## ── Conflicts ──────────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

    ## Loading required package: viridisLite

    ## Parsed with column specification:
    ## cols(
    ##   date = col_date(format = ""),
    ##   county = col_character(),
    ##   state = col_character(),
    ##   fips = col_character(),
    ##   cases = col_double(),
    ##   deaths = col_double()
    ## )

``` r
ggplot(covid_19, aes(date, fct_reorder(county, date), fill = log(cases))) +
  geom_tile(colour = "white") +
  scale_fill_viridis(name = "Num. of \nCases \n(log)",
                     guide = guide_colourbar(direction = "horizontal"),
                     option = "magma") +
  labs(
    x = "Date",
    y = "Washington County",
    title = "Timeline of COVID-19 Caes by Washington County"
  ) +
  theme(
    axis.text  = element_text(size = 12),
    axis.ticks = element_blank(),
    panel.background = element_blank(),
    plot.title = element_text(size = 18),
    legend.position = "bottom"
  )
```

![](README_files/figure-markdown_github/graphic-1.png)
