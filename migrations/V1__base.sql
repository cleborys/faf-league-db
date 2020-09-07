DROP TABLE IF EXISTS league_season_score;
DROP TABLE IF EXISTS league_season_subdivision;
DROP TABLE IF EXISTS league_season_division;
DROP TABLE IF EXISTS league_season;
DROP TABLE IF EXISTS league;

CREATE TABLE leaderboard
(
  id              SMALLINT(5) UNSIGNED  NOT NULL PRIMARY KEY,
  technical_name  VARCHAR(255)          NOT NULL UNIQUE
);

CREATE TABLE league
(
  id              SMALLINT(5) UNSIGNED  NOT NULL AUTO_INCREMENT PRIMARY KEY,
  technical_name  VARCHAR(255)          NOT NULL UNIQUE,
  name_key        VARCHAR(255)          NOT NULL,
  description_key VARCHAR(255)          NOT NULL COMMENT "The league's i18n description key",
  create_time     TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time     TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE league_season
(
  id              MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  league_id       SMALLINT(5) UNSIGNED  NOT NULL,
  leaderboard_id  SMALLINT(5) UNSIGNED  NOT NULL,
  start_date      DATETIME              NOT NULL,
  end_date        DATETIME,
  FOREIGN KEY (league_id) REFERENCES league (id),
  FOREIGN KEY (leaderboard_id) REFERENCES leaderboard (id),
  INDEX (start_date, end_date, league_id)
);

CREATE TABLE league_season_division
(
  id                INT(10) UNSIGNED      NOT NULL AUTO_INCREMENT PRIMARY KEY,
  league_season_id  MEDIUMINT(8) UNSIGNED NOT NULL,
  division_index    SMALLINT(5) UNSIGNED  NOT NULL,
  name_key          VARCHAR(255)          NOT NULL,
  description_key   VARCHAR(255)          NOT NULL COMMENT "The division's i18n flavor text key",
  FOREIGN KEY (league_season_id) REFERENCES league_season (id)
);

CREATE TABLE league_season_division_subdivision
(
  id                INT(10) UNSIGNED      NOT NULL AUTO_INCREMENT PRIMARY KEY,
  league_season_division_id  INT(10) UNSIGNED NOT NULL,
  subdivision_index    SMALLINT(5) UNSIGNED  NOT NULL,
  name_key          VARCHAR(255)          NOT NULL,
  description_key   VARCHAR(255)          NOT NULL COMMENT "The subdivision's i18n flavor text key",
  min_rating        FLOAT                 NOT NULL,
  max_rating        FLOAT                 NOT NULL,
  highest_score     INT                   NOT NULL,
  FOREIGN KEY (league_season_division_id) REFERENCES league_season_division (id)
);

CREATE TABLE league_season_score
(
  login_id          MEDIUMINT(8) UNSIGNED NOT NULL,
  league_season_id  MEDIUMINT(8) UNSIGNED NOT NULL,
  subdivision_id       INT(10) UNSIGNED,
  score             INT,
  game_count        INT                   NOT NULL DEFAULT 0,
  PRIMARY KEY (login_id, league_season_id),
  FOREIGN KEY (subdivision_id) REFERENCES league_season_division_subdivision (id),
  UNIQUE INDEX (login_id, score, league_season_id)
);
