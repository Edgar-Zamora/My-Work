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
