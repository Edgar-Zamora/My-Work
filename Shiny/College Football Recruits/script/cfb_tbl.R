cfb_recruits %>% 
  filter(year == "2020",
         committed_to == "Oregon") %>% 
  group_by(year, committed_to, state_province) %>% 
  tally() %>% 
  arrange(desc(n)) %>% 
  mutate(state_province = case_when(is.na(state_province) ~ "N/A",
                                    TRUE ~ state_province)) %>% 
  ggplot(aes(n, fct_reorder(fct_rev(state_province), n), label = n)) +
  geom_point(size = 10, colour = '#044520') +
  geom_text(colour = "white") + 
  labs(
    title = "Top Recruits By State",
    x = "",
    y = ""
  ) +
  theme(
    axis.ticks = element_blank(),
    axis.text.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(colour = "#ECECEC"),
    panel.background = element_blank()
  )
