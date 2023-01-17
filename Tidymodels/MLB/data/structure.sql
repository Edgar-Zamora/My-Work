ROLLBACK;

BEGIN;

CREATE TABLE IF NOT EXISTS game_data (
  gm_number numeric,
  season numeric not null,
  team text not null,
  date date,
  month numeric,
  day numeric,
  weekday text,
  start_time time,
  day_night text,
  weekend numeric,
  attendance numeric,
  away_home text
);

TRUNCATE game_data;

-- Comments about table and columns
COMMENT ON TABLE game_data IS 'Table about features regarding every indivudal game during a season';
COMMENT ON COLUMN game_data.season IS 'Year of season';
COMMENT ON COLUMN game_data.away_home IS 'Indicator of whether game was home or away';
COMMENT ON COLUMN game_data.attendance IS 'Attendance of game. There may be zeros';
COMMENT ON COLUMN game_data.weekend IS 'Binary value indicating whether the game was on a weekend';
COMMENT ON COLUMN game_data.day_night IS 'Binary value indicating whether the game was a night or day game';
COMMENT ON COLUMN game_data.start_time IS 'Time of when the game start. 12 hour';
COMMENT ON COLUMN game_data.weekday IS 'Day of week on which game took place';
COMMENT ON COLUMN game_data.day IS 'Numerical day of the week';
COMMENT ON COLUMN game_data.month IS 'Numerical month';
COMMENT ON COLUMN game_data.date IS 'Date of game. YYYY/MM/DD';
COMMENT ON COLUMN game_data.team IS 'Abbrevation of home team';
COMMENT ON COLUMN game_data.gm_number IS 'Game sequence in the season';

\copy game_data from 'game_data.txt' CSV HEADER DELIMITER '|' ENCODING 'latin1'

