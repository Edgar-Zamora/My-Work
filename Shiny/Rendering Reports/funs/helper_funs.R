# State Summary
state_summry <- superstore %>% 
  select(order_id, order_date, customer_id, state, category,
         sales, quantity, profit) %>% 
  mutate(month = month(order_date)) %>% 
  group_by(state, month) %>% 
  summarise(
    unique_cust = n_distinct(customer_id),
    total_quantity = sum(quantity),
    sales = sum(sales),
    profit = sum(profit)
  ) %>% 
  ungroup() %>% 
  group_by(state) %>% 
  mutate(
    state_profit = sum(profit),
    state_sales = sum(sales),
  ) %>% 
  ungroup() %>% 
  mutate(across(c(month), as.factor))



# State Monthly Sales v. Profit
state_prof_sales <- function(data) {
  
  data %>% 
    select(state, month, sales, profit) %>% 
    pivot_longer(-c(state, month), names_to = "type", values_to = "value") %>% 
    ggplot(aes(month, value, color = type, group = type)) +
    geom_line(size = 2, key_glyph = "timeseries") +
    scale_y_continuous(labels = scales::dollar_format()) +
    scale_color_tableau(name = "Metric",
                        labels = c("Profit", "Sales")) +
    labs(
      x = "",
      y = "",
      title = "Monthly Profit v. Sales"
    ) +
    theme(
      panel.grid = element_blank(),
      panel.background = element_blank(),
      axis.ticks.x = element_blank(),
      legend.key = element_rect(fill = "transparent")
    )
}









