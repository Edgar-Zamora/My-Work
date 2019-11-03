library(tidyverse)
library(rvest)
library(stringr)
install.packages("statebins", repos = "https://cinc.rud.is")
library(statebins)
library(knitr)
library(kableExtra)
library(formattable)

#Getting URLS
url <- "https://www.nytimes.com/interactive/2019/10/31/us/politics/trump-impeachment-inquiry-house-vote.html?module=inline"

table <- url %>% 
  read_html() %>% 
  html_nodes(".g-multi-table")

names <- table %>% 
  html_nodes(".g-name") %>% 
  html_text() %>% 
  tibble() %>% 
  rename("Names" = ".") %>% 
  slice(-1, -199, -434)

votes <- table %>% 
  html_nodes(".g-cell-block") %>% 
  html_text() %>%
  tibble() %>% 
  rename("Votes" = ".")

votes <- str_trim(votes$Votes, side = "both") 

votes <- votes %>% 
  tibble() %>% 
  rename("Votes" = ".") 


#### New Column for Party
Rep <- (1:197)
Demo <- (198:431)
Ind <- 432

names <- names %>% 
  mutate(Party = ifelse(seq_len(nrow(names)) %in% Rep, "R",
         ifelse(seq_len(nrow(names)) %in% Demo, "D", "I")))

complete <- bind_cols(names, votes) %>% 
  separate(Names,c("Names","State","District"),"\\s(?=\\S+\\s+(?=\\d))|\\s+(?=\\d)") %>% 
  mutate(State = recode(State,
                        Ala. = "Alabama", Alaska = "Alaska", Ariz. = "Arizona",
                        Ark.  = "Arkansas", Calif. = "California", Colo. = "Colorado",
                        Conn. = "Connecticut",Del.  = "Delaware", Fla.  = "Florida",
                        Ga.   = "Georgia", Hawaii = "Hawaii", Idaho = "Idaho",
                        Ill.  = "Illinois", Ind.  = "Indiana",Iowa  = "Iowa",
                        Kan.  = "Kansas", Ky.   = "Kentucky",La.   = "Louisiana",
                        Mass. = "Massachusetts", Md.   = "Maryland", Me.   = "Maine",
                        Mich. = "Michigan", Minn. = "Minnesota",Miss. = "Mississippi", 
                        Mo.   = "Missouri", Mont. = "Montana", N.C.  = "North Carolina",  
                        N.D.  = "North Dakota", N.H.  = "New Hampshire", N.J.  = "New Jersey",
                        N.M.  = "New Mexico", N.Y.  = "New York", Neb.  = "Nebraska",
                        Nev.  = "Nevada", Ohio  = "Ohio",  Okla. = "Oklahoma",
                        Ore.  = "Oregon",Pa.   = "Pennsylvania",R.I.  = "Rhode Island",
                        S.C.  = "South Carolina",S.D.  = "South Dakota",Tenn. = "Tennessee",
                        Tex.  = "Texas",Utah  = "Utah",  Va.   = "Virginia",
                        Vt.   = "Vermont", W.Va. = "West Virginia", Wash. = "Washington",
                        Wis.  = "Wisconsin",Wyo.  = "Wyoming"),
         Votes = recode(Votes,
                        Y = 1,
                        N = -1,
                        NV = 0))

x <- complete %>% 
  group_by(State) %>% 
  summarize(Total = sum(Votes)) %>% 
  mutate(Party = if_else(Total > 0, "D", "R")) %>% 
  print(n = Inf)

mid <- mean(x$Total)

ggplot(x, aes(state = State, fill = Total)) +
  geom_statebins(border_col="grey90", border_size = .2) +
  labs(title = "How The House Voted On The Trump Impeachment Rule",
       subtitle = 'A "Ya" is a 1 while a "Nay" is -1 with non-voters as 0') +
  scale_fill_gradient2(low = "red", high = "blue", midpoint = -1) +
  theme(panel.background = element_blank(),
        axis.ticks = element_blank(), 
        axis.text = element_blank(),
        plot.title = element_text(size = 23))

x %>% 
  group_by(State,Total) %>% 
  arrange(State) %>% 
  print(n = Inf) %>% 
  kable() %>% 
  kable_styling(full_width = FALSE, c("condensed", "hover")) %>% 
  footnote(general = 'Total is a calculation that sums "Ya" (1), "Nay" (-1), or "Never Voted" (0).')
  




