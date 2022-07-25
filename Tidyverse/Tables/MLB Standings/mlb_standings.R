# Load packages
library(tidyverse)
library(gt)
library(gtExtras)
library(webshot2)


# WD: My-work/Tidymodel/MLB
current_season <- read_csv("data/game_data.csv") |> 
  filter(season == 2022)


teams <- mlbstatsR::get_mlb_teams() |> 
  select(team, name, division, logo) |> 
  tibble()


year <- 2022


plan(multisession, workers = 4)
current_year <- future_map2_dfr(.x = teams$team, .y = year, get_outcome, .progress = TRUE)

next_game <- current_year |> 
  filter(!win_lose %in% c("W", "L")) |> 
  mutate(across(gm_number, as.numeric)) |>
  group_by(season, team) |> 
  slice_min(gm_number, n = 1) |> 
  transmute(next_game = paste(opp, str_to_upper(win_lose)))

  

standings_data <- current_year |> 
  filter(win_lose %in% c("W", "L")) |> 
  mutate(across(c(r, ra), as.numeric)) |> 
  group_by(season, team) |> 
  summarise(
    games_played = n(),
    wins = length(which(win_lose == "W")),
    losses = games_played - wins,
    pct = wins/games_played,
    rs = sum(r),
    ra = sum(ra),
    diff = rs - ra
  ) |> 
  left_join(next_game, by = c("season", "team"))

  

mlb_standings <- standings_data |> 
  ungroup() |> 
  left_join(teams, by = "team") |> 
  mutate(team_name = paste("<div class='teams'> <img class ='team-img' src='", logo, "'>", name, "</div>"),
         diff = case_when(diff > 0 ~ paste0('<span style="color:green;">+', diff, "</span>"),
                                            TRUE ~ paste0('<span style="color:red;">', diff, "</span>"))) |> 
  select(team_name, wins, losses, pct, rs, ra, diff, next_game, division) |> 
  group_by(division) |> 
  arrange(desc(pct)) |> 
  gt() |> 
  fmt_markdown(
    columns = c(team_name, diff)
  ) |> 
  fmt_number(
    columns = pct,
    decimals = 3
  ) |> 
  tab_style(
    style = list(
      cell_fill(color = "#041D42"),
      cell_text(color = "white")
    ),
    locations = cells_row_groups()
  ) |> 
  tab_style(
    style = cell_fill(color = "#F7F7F7"),
    locations = cells_body(
      columns = c(team_name, pct)
    )
  ) |> 
  tab_style(
    style = cell_borders(
      sides = "right",
      color = "#D2D2D2",
      weight = px(3)
    ),
    locations = cells_body(
      columns = team_name
    )
  ) |> 
  tab_style(
    style = cell_borders(
      sides = "right",
      color = "#D2D2D2",
      weight = px(2)
    ),
    locations = cells_body(
      columns = c(pct, diff)
    )
  ) |> 
  tab_style(
    style = cell_text(
      font = google_font(name = 'Helvetica')
    ),
    locations = cells_body(
      columns = everything()
    )
  ) |> 
  tab_options(
    table_body.hlines.color = "#D2D2D2",
    table_body.hlines.width = "2px",
    table.border.top.color = "white",
    table.border.bottom.color = "white",
    heading.border.bottom.color = "white",
    column_labels.border.top.color = "white"
  ) |> 
  cols_label(
    "wins" = "W",
    "losses" = "L",
    "pct" = "PCT",
    "rs" = "RS",
    "ra" = "RA",
    "diff" = "DIFF",
    'next_game' = "Next Game",
    "team_name" = ""
  ) |> 
  tab_header(
    title = "Standings"
  ) |> 
  cols_width(
    wins:diff ~ px(75),
    team_name ~ px(275),
    next_game ~ px(125)
  ) |> 
  cols_align(
    align = "center",
    columns = wins:diff
  ) |> 
  tab_footnote(
    footnote = "Times are in EST",
    locations = cells_column_labels(
      columns = next_game
    )
  ) |> 
  row_group_order(
    groups = c("AL East", "AL Central", "AL West",
               "NL East", "NL Central", "NL West")
  ) |> 
  text_transform(
    locations = cells_body(
      columns = pct
    ),
    fn = function(x) {
      str_remove(as.character(x), "^0")
    }
  ) |> 
  opt_align_table_header(
    align = "left"
  ) |> 
  opt_css(
    css = "
    
    .team-img {
    width: 1.5rem;
    height: 1.5rem;
    margin-right: 15px;
    }
    
    .teams {
    display: flex;
    align-items: center;
    }
    
    "
  )
  

# Saving tables
gtsave_extra(mlb_standings , "mlb_standings.png", vwidth = 2500)


