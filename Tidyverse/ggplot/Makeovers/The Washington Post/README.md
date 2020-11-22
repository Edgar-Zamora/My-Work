A Washington Post graphic
=========================

A day after the election, I was swiping through the Snapchat
subscription page for The Washington Post when I came across the
following figure.

![](wpo.PNG)

Trying to understand the graphic took me a couple of tries. There were a
couple of things that I noticed that were troubling for me.

To me, graphic is trying to hard to visualize a simple concept. The
basic understanding of the visual was to showcase how accurate states
have been at picking presidential candidates to become president. The
addition of “state winner not elected” legend to me was unnecessary
because it can be assumed that if a state did not pick the right
candidate it must have been wrong.

In additional to over complicating the issues, adding a presidents party
is a little much. It lead me trying to understand two different concepts
within one graph. One being states accuracy in candidate selection and
also whether that choice aligned along party lines. To include party
requries a additional visualization.

The last issue I see is that the graphic has a mistake. If you look at
the 2012 election (third column from the right), there are two different
colours within the same column, which is impossible. That would mean a
president was elected from two different parties.

In the following sections I will replicated the graphic in R and attempt
to improve upon it to better capture the concept being protrayed.

Replicating the WPO grapic
==========================

In order to replicated the graphic in R, I use the `geom_tile()` from
the `ggplot2` package.

![](replicated.PNG)

Remkaing the WPO graphic
========================
