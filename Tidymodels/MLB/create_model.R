# Load packages
library(tidyverse)
library(tidymodels)
library(ranger)

set.seed(420)

# Load data
source("create_data.R")

# Initial split of data
sea_attnd_split <- initial_split(model_data, prop = 0.80)
sea_attnd_split

sea_attnd_train <- training(sea_attnd_split)
sea_attnd_test <- testing(sea_attnd_split)


# Creating Recipe

model_recipe <- recipe(attendance ~ openning_week + day_night + same_division + weekday,
       data = sea_attnd_train) |> 
  step_date(features = c("month", "doy")) |> 
  step_holiday(holidays = c("USLaborDay", "USInaugurationDay", "USMemorialDay")) |> 
  step_dummy(day_night) |> 
  step_mutate(
    weekend = case_when(weekday %in% c("Friday", "Saturday", "Sunday") ~ 1,
                        TRUE ~ 0)
  )



# Model Specification
## Linear
lm_model <- linear_reg() |> 
  set_engine("lm")


## Random Forest
rf_model <- rand_forest() |> 
  set_engine("ranger") |> 
  set_mode("regression")



# Create workflows
lm_wflow <- workflow() |> 
  add_model(lm_model) |> 
  add_recipe(model_recipe)


fit(lm_wflow, sea_attnd_train)

