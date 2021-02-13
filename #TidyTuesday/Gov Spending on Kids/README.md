Goverment Spending on Kids
==========================

For [Week
38](https://github.com/rfordatascience/tidytuesday/blob/master/data/2020/2020-09-15/readme.md)
of \#TidyTuesday I focus on two new features, making each strip box
header fill based on whether state increase their spending by 50% and
using `{geomfacet}` package to arrange the facets to resemble the United
States.

Conditional Strip Colors
------------------------

When reading through the `{ggplot2}` documentation regarding
modifications to facet strips, I could not find anything that meet what
I was attempting to do. So as many programmers/coders do, I went to
stack overflow and search for an answer which I found!! The
[answer](https://stackoverflow.com/questions/60332202/conditionally-fill-ggtext-text-boxes-in-facet-wrap/60345086#60345086%3E)
comes the author of the `{ggtext}` package, [Clause
Wilke](https://stackoverflow.com/users/4975218/claus-wilke), which
requires creating a function and other stuff that I myself find
difficult understanding. The good thing is that it works! Once you
create the function all that is requires is that you call said function
when making edits to the theme of plot like so:

``` r
plot %>% 
  theme(
    strip.text = custom_function{  #Here is where you add the stack overflow function
      ....
    }
  )
```

After tuning the other aspects of the function you are set. As seen
below, in the plot those states that saw a 50% increase to their state
spending saw were colored blue.

Mapping A Facet Map
-------------------

The [`{geofacet}`](https://hafen.github.io/geofacet/) by Hafen and Kotov
affords the ability to arrange ggplot facets in a way that resembles
different geographical entities. For the most part, using `{geofacet}`
is as using the `facet_*` functions from ggplot2. The only part that may
be tricky with using this package is having the proper fields (state,
providence, region etc.) that allow the plotting. To plot according to a
geographic area you will use the `facet_geo` function. The main argument
is `grid`, which asks you to provide the specific grid layout you want
to use. A complete list of options can be found on the `geofacet`
[webpage](https://hafen.github.io/geofacet/reference/index.html). Your
code should look something like below:

``` r
plot %>% 
  facet_geo(~field to facet by, grid = desired layout)
```

Wrap up
=======

In all this weeks TidyTuesday showed me new stylistic feature to add to
my existing plots and introduced a new package that will come in handy
when working with national data that requires looking at states
separately. Below is a the finished plot using the two things I learned
this week.

![](higherEd_spending.png "Goverment Spending on Kids")

You can find the code on my [GitHub
page](https://github.com/Edgar-Zamora/My-Work/blob/master/%23TidyTuesday/Gov%20Spending%20on%20Kids/gov_spending_on_kids.R)
