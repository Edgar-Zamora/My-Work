# Libaries ----
library(tidyverse)

# Loading Data ----
df <- read.csv("FallSurveyclean v2.csv") %>% 
  select(know_acadm_advisor, academ_advisor_availability, academ_advisor_knowledge, academ_advisor_trans_knowledge, 
         academ_advisor_concerned, degreecert_require_clear, plan_complete_degreecert) 

# Function for percentages ----
cal_percentage <- function(question){
  df %>% 
    group_by({{question}}) %>% 
    summarize(n = n()) %>% 
    mutate(percent = paste0(round(100 * n/sum(n),1), "%"))
}


# Iterating through all the values and store----
Calculations <- df %>% 
  map(cal_percentage)


# Exporting file ----
write.csv(Calculations, "Fall 2018 Survey- Advising Calculations.csv", row.names = FALSE)
