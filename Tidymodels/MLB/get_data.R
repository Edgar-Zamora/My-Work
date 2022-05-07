#' Getting game outcome data 
#'
#' @param team Name of the MLB team
#' @param season Season of MLB season
#'
#' @return Returns a df of outcome data for entire MLB team 
#' @export
#'
#' @examples
get_outcome <- function(team, season) {
  
  url <- paste0("https://www.baseball-reference.com/teams/", team, "/", season, "-schedule-scores.shtml")
  session <- bow(url)
  
  
  scrape(session) |> 
    html_element("table") |> 
    html_table() |>  
    clean_names() |> 
    filter(tm != "Tm") |> 
    select(gm_number, opp, w_l, r, ra, inn) |> 
    mutate(
      walkoff = case_when(str_detect(w_l, "wo") ~ 1,
                          TRUE ~ 0),
      forfeit = case_when(str_detect(w_l, "&V") ~ 1,
                          TRUE ~ 0),
      w_l = str_remove_all(w_l, "-wo|&V"),
      inn = case_when(inn == "" ~ 0,
                      TRUE ~ as.numeric(inn)),
      extra_innings = case_when(inn >= 9 ~ 1,
                                TRUE ~ 0),
      won_prev_game = case_when(lag(w_l) == "W" ~ 1,
                                TRUE ~ 0),
      team = team,
      season = season) |> 
    rename(
      win_lose = w_l
    )
  
}




#' MLB team names
#'
#' @description Table contains information about each team including their official 
#' name, abbreviated name, team colors and other information.
#' @return
#' @export
#'
#' @examples
#' 
get_team_names <- function() {
  
  mlbstatsR::get_mlb_teams() |> 
    select(name, liga, division, team, primary, secondary, logo) |> 
    as_tibble() |> 
    rename(
      full_team_name = name,
      league_name = liga,
      team_abb = team,
      primary_color = primary,
      secondary_color = secondary
    )
  
}





#' Getting game data
#'
#' @description Table contains information regarding game data that does not pertain to the outcome. Things
# such as weekday (month, day), time, day and more.
#' @param team Name of the MLB team
#' @param season Season of MLB season
#'
#' @return
#' @export
#'
#' @examples
get_game_data <- function(team, season) {
  
  url <- paste0("https://www.baseball-reference.com/teams/", team, "/", season, "-schedule-scores.shtml")
  session <- bow(url)
  
  
  scrape(session) |> 
    html_element("table") |> 
    html_table() |>  
    clean_names() |> 
    filter(tm != "Tm") |> 
    separate(col = date, into = c('weekday', "month", "day"), sep = "\\s") |> 
    mutate(across(weekday, ~str_remove_all(., "[:punct:]")),
           month = match(month, month.abb),
           date = ymd(paste0(season, "0", month, day)),
           weekend = case_when(weekday %in% c("Saturday, Sunday") & (weekday == "Friday" & time > "5:00") ~ 1,
                               TRUE ~ 0),
           attendance = as.numeric(str_remove_all(attendance, "[:punct:]")),
           season = season,
           team = team,
           away_home = case_when(x_2 == "@" ~ "away",
                                 TRUE ~ "home")) |> 
    select(gm_number, season, team, date, month, day, weekday, time, d_n, weekend, attendance,
           away_home) |> 
    rename(
      day_night  = d_n,
      start_time = time
    )
  
}




#' Getting pitcher data
#' 
#' @description Table containing information on winning, losing, and saving pitcher for
#' each game
#' @param team Name of the MLB team
#' @param season Season of MLB season
#'
#' @return
#' @export
#'
#' @examples
get_pitcher_data <- function(team, season) {
  
  url <- paste0("https://www.baseball-reference.com/teams/", team, "/", season, "-schedule-scores.shtml")
  session <- bow(url)
  
  scrape(session) |> 
    html_element("table") |> 
    html_table() |>  
    clean_names() |> 
    filter(tm != "Tm") |>
    mutate(team = team,
           season = season,
           across(where(is.character), str_trim),
           away_home = case_when(x_2 == "@" ~ "away",
                                 TRUE ~ "home")) |> 
    select(season, gm_number, opp, win, loss, save, away_home) 
  
  
}



#' Getting MLB team standings
#'
#' @description Table containing information about a MLB at each game
#' @param team Name of the MLB team
#' @param season Season of MLB season
#'
#' @return
#' @export
#'
#' @examples
get_standings <- function(team, season) {
  
  url <- paste0("https://www.baseball-reference.com/teams/", team, "/", season, "-schedule-scores.shtml")
  session <- bow(url)
  
  scrape(session) |> 
    html_element("table") |> 
    html_table() |>  
    clean_names() |> 
    filter(tm != "Tm") |> 
    select(gm_number, w_l_2, rank, gb, c_li, streak) |> 
    separate(col = w_l_2, into = c("wins", "losses"), sep = "-") |> 
    mutate(games_back = as.numeric(str_extract(gb, "\\d.*")),
           games_back = case_when(str_detect(gb, "up") ~ games_back,
                                  gb == "Tied" ~ 0,
                                  TRUE ~ games_back * -1),
           across(c(wins, losses), as.numeric),
           win_per = wins/(wins + losses),
           win_streak = str_count(streak, "\\+"),
           losing_streak = str_count(streak, "\\-"),
           team = team,
           season = season) |> 
    rename(division_rank = rank)
  
}


