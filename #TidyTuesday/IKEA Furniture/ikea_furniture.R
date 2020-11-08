#Loading packages
library(tidyverse)
library(tidymodels)
library(corrplot)
library(ranger)

# Import data
ikea_data <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-11-03/ikea.csv') %>%
  select(-X1) %>% 
  select(price, category, other_colors, depth, height, width)


ikea_data %>% 
  select(-category) %>%
  filter_at(vars(depth, height, width), ~!is.na(.)) %>% 
  mutate(other_colors = case_when(other_colors == "Yes" ~ 1,
                                  TRUE ~ 0)) %>% 
  cor() %>% 
  corrplot(method = "number", type = "lower", order = "hclust",
           tl.srt = 30, tl.col = "black",
           mar = c(0, 0, 2.5, 0),
           title = "Correlation between IKEA futniture price and \nfeatures with missing values removed")


# Prepping recipe to prepare data for modeling
ikea_prep <- recipe(price ~., data = ikea_data) %>% 
  step_other(category) %>% 
  step_knnimpute(depth, width, height) %>% 
  step_dummy(other_colors) %>% 
  step_string2factor(category) %>% 
  prep() %>% 
  juice()


# Correlation with imputation 
ikea_rec %>% 
  prep() %>% 
  juice() %>% 
  select(-category) %>% 
  cor() %>% 
  corrplot(method = "number", type = "lower", order = "hclust",
           tl.srt = 30, tl.col = "black",
           mar = c(0, 0, 2.5, 0),
           title = "Correlation between IKEA futniture price and \nfeatures with missing values imputed")


# Sampling data
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



