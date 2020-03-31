    ## ── Attaching packages ────────────────────────────────────────────────────────────────────────────────────────────── tidyverse 1.2.1 ──

    ## ✔ ggplot2 3.2.1     ✔ purrr   0.3.2
    ## ✔ tibble  2.1.3     ✔ dplyr   0.8.3
    ## ✔ tidyr   1.0.0     ✔ stringr 1.4.0
    ## ✔ readr   1.3.1     ✔ forcats 0.4.0

    ## ── Conflicts ───────────────────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

    ## Loading required package: viridisLite

    ## 
    ## Attaching package: 'scales'

    ## The following object is masked from 'package:viridis':
    ## 
    ##     viridis_pal

    ## The following object is masked from 'package:purrr':
    ## 
    ##     discard

    ## The following object is masked from 'package:readr':
    ## 
    ##     col_factor

    ## Parsed with column specification:
    ## cols(
    ##   city = col_character(),
    ##   state = col_character(),
    ##   city_size = col_character(),
    ##   mode = col_character(),
    ##   n = col_double(),
    ##   percent = col_double(),
    ##   moe = col_double(),
    ##   state_abb = col_character(),
    ##   state_region = col_character()
    ## )

For this TidyTuesday I keep it easy and try my mapping skills using the
[`statebins`](https://github.com/hrbrmstr/statebins) by hrbrmstr.

Walkers by state
================

To prepare

``` r
#Compute total number of walkers per state
total_walking_num <- commute_mode %>% 
  filter(mode == "Walk" & !is.na(state_abb)) %>% 
  group_by(state_abb) %>% 
  summarize(walking_num = sum(n))
```

Creating a map
==============

``` r
ggplot(total_walking_num, aes(state = state_abb, fill = log2(walking_num))) +
  geom_statebins(border_col="grey40", border_size = .2) +
  scale_fill_viridis(option = "magma", direction = -1, label = comma,
                     name = "") +
  labs(title = "Do you like walking to places?",
       subtitle = "Aggregate (log) number of walkers by state") +
  theme(panel.background = element_blank(),
        plot.subtitle = element_text(size = 8),
        legend.position = "right",
        axis.ticks = element_blank(), 
        axis.text = element_blank(),
        plot.title = element_text(size = 23.5)) +
  guides(fill = guide_colourbar(barwidth = 0.7, barheight = 8))
```

<img src="Modes-Less-Traveled_files/figure-markdown_github/mapping-1.png" style="display: block; margin: auto;" />
