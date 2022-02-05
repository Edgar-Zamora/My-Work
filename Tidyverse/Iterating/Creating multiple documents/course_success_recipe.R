library(tidyverse)
library(knitr)
library(rmarkdown)
library(odbc)
library(DBI)
library(dbplyr)
library(janitor)
library(kableExtra)
library(glue)

#Guide:
# https://github.com/hadley/joy-of-fp

#rmarkdown::render(
#  "Course-Success-Rates.Rmd",
# output_file = "Daneen-Course-Success-Rates.html",
#  params = list(dean = "Daneen")
#)

#Getting each unique dean and creating a path for them
deans <- sort(unique(course_success_rates$dean))
paths <- paste0(deans, "-Course-Success-Rates.pdf")

#Turning params into a list
x <- deans[[1]]
list(dean = x) #check that params area list

#Creating a recipe that will map over each parameter dean
params <- map(deans, ~list(dean = .x))

#Mapping the paths and parameters to the recipe of rending a documents to get each deans course success rate
walk2(
  paths, params,
  ~ rmarkdown::render("Course-Success-Rates.Rmd", output_file = .x, params = .y)
)
