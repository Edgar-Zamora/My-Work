#Loading packages
library(tidyverse)
library(tidymodels)
library(corrplot)
library(ranger)
library(tidytuesdayR)

# Importing data
tt_ikea <- tt_load(2020, week = 45)

ikea_data <- tt_ikea$ikea %>% 
  select(-X1)


# Prepping recipe to prepare data for modeling
ikea_prep <- ikea_data %>% 
  select(-c(name, old_price, link, short_description, designer)) %>% 
  mutate(sellable_online = as.numeric(sellable_online)) %>% 
  recipe(price ~., data = .) %>% 
  step_other(category) %>% 
  step_knnimpute(depth, width, height) %>% #try later without imputation
  step_dummy(other_colors) %>% 
  step_string2factor(category)



# Sampling data
set.seed(1234)

ikea_split <- initial_split(ikea_prep)
ikea_train <- training(ikea_split)
ikea_test <- testing(ikea_split)

#Building workflow
ikea_wf <- workflow() %>% 
  add_recipe(ikea_rec)


# Linear Regression
ikea_lm <- linear_reg() %>% 
  set_engine("lm") 

ikea_lm_fit <- ikea_wf %>% 
  add_model(ikea_lm) %>% 
  fit(ikea_train) 


# Random forest model
ikea_rf <- rand_forest() %>% 
  set_engine("ranger") %>%
  set_mode("regression")

ikea_rf_fit <- ikea_wf %>% 
  add_model(ikea_rf) %>% 
  fit(ikea_train)


ikea_rf_fit %>% 
  predict(new_data = ikea_test)



