-- ============================================================
-- Premier League SQL Analysis
-- Schema creation and data load
-- ============================================================
-- Source: 10 season CSVs (2016/17 to 2025/26) imported via
-- MySQL Workbench's Table Data Import Wizard into staging
-- tables named season-1617, season-1718, etc.
-- This script normalizes that raw data into three tables.
-- ============================================================

CREATE DATABASE IF NOT EXISTS premier_league;
USE premier_league;

-- One row per club
CREATE TABLE teams (
  team_id INT NOT NULL AUTO_INCREMENT,
  team_name VARCHAR(50) NOT NULL,
  PRIMARY KEY (team_id),
  UNIQUE KEY uq_team_name (team_name)
);

-- One row per fixture. Teams stored as foreign keys, not repeated text.
CREATE TABLE matches (
  match_id INT NOT NULL AUTO_INCREMENT,
  match_date DATE,
  season VARCHAR(10),
  home_team_id INT NOT NULL,
  away_team_id INT NOT NULL,
  home_goals INT,
  away_goals INT,
  result VARCHAR(1),
  ht_home_goals INT,
  ht_away_goals INT,
  ht_result VARCHAR(1),
  referee VARCHAR(50),
  PRIMARY KEY (match_id),
  FOREIGN KEY (home_team_id) REFERENCES teams(team_id),
  FOREIGN KEY (away_team_id) REFERENCES teams(team_id)
);

-- One row per team per match, rather than separate home/away
-- columns. This lets stats like shots or cards be aggregated per
-- team with a plain GROUP BY, instead of averaging two columns.
CREATE TABLE team_match_stats (
  stat_id INT NOT NULL AUTO_INCREMENT,
  match_id INT NOT NULL,
  team_id INT NOT NULL,
  is_home TINYINT,
  shots INT,
  shots_on_target INT,
  fouls INT,
  corners INT,
  yellow_cards INT,
  red_cards INT,
  PRIMARY KEY (stat_id),
  FOREIGN KEY (match_id) REFERENCES matches(match_id),
  FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

-- ------------------------------------------------------------
-- Populate teams: distinct home and away team names across
-- all 10 seasons, deduplicated with UNION.
-- ------------------------------------------------------------
INSERT INTO teams (team_name)
SELECT HomeTeam FROM `season-1617` UNION SELECT AwayTeam FROM `season-1617`
UNION SELECT HomeTeam FROM `season-1718` UNION SELECT AwayTeam FROM `season-1718`
UNION SELECT HomeTeam FROM `season-1819` UNION SELECT AwayTeam FROM `season-1819`
UNION SELECT HomeTeam FROM `season-1920` UNION SELECT AwayTeam FROM `season-1920`
UNION SELECT HomeTeam FROM `season-2021` UNION SELECT AwayTeam FROM `season-2021`
UNION SELECT HomeTeam FROM `season-2122` UNION SELECT AwayTeam FROM `season-2122`
UNION SELECT HomeTeam FROM `season-2223` UNION SELECT AwayTeam FROM `season-2223`
UNION SELECT HomeTeam FROM `season-2324` UNION SELECT AwayTeam FROM `season-2324`
UNION SELECT HomeTeam FROM `season-2425` UNION SELECT AwayTeam FROM `season-2425`
UNION SELECT HomeTeam FROM `season-2526` UNION SELECT AwayTeam FROM `season-2526`;

-- ------------------------------------------------------------
-- Populate matches: one block per season, joining team names
-- to their new team_id and hard-coding the season string,
-- since the source CSVs don't include one. UNION ALL is used
-- since every match is a genuinely distinct row.
-- ------------------------------------------------------------
INSERT INTO matches (match_date, season, home_team_id, away_team_id, home_goals, away_goals, result, ht_home_goals, ht_away_goals, ht_result, referee)
SELECT r.Date, '2016/17', ht.team_id, at.team_id, r.FTHG, r.FTAG, r.FTR, r.HTHG, r.HTAG, r.HTR, r.Referee
FROM `season-1617` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
UNION ALL
SELECT r.Date, '2017/18', ht.team_id, at.team_id, r.FTHG, r.FTAG, r.FTR, r.HTHG, r.HTAG, r.HTR, r.Referee
FROM `season-1718` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
UNION ALL
SELECT r.Date, '2018/19', ht.team_id, at.team_id, r.FTHG, r.FTAG, r.FTR, r.HTHG, r.HTAG, r.HTR, r.Referee
FROM `season-1819` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
UNION ALL
SELECT r.Date, '2019/20', ht.team_id, at.team_id, r.FTHG, r.FTAG, r.FTR, r.HTHG, r.HTAG, r.HTR, r.Referee
FROM `season-1920` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
UNION ALL
SELECT r.Date, '2020/21', ht.team_id, at.team_id, r.FTHG, r.FTAG, r.FTR, r.HTHG, r.HTAG, r.HTR, r.Referee
FROM `season-2021` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
UNION ALL
SELECT r.Date, '2021/22', ht.team_id, at.team_id, r.FTHG, r.FTAG, r.FTR, r.HTHG, r.HTAG, r.HTR, r.Referee
FROM `season-2122` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
UNION ALL
SELECT r.Date, '2022/23', ht.team_id, at.team_id, r.FTHG, r.FTAG, r.FTR, r.HTHG, r.HTAG, r.HTR, r.Referee
FROM `season-2223` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
UNION ALL
SELECT r.Date, '2023/24', ht.team_id, at.team_id, r.FTHG, r.FTAG, r.FTR, r.HTHG, r.HTAG, r.HTR, r.Referee
FROM `season-2324` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
UNION ALL
SELECT r.Date, '2024/25', ht.team_id, at.team_id, r.FTHG, r.FTAG, r.FTR, r.HTHG, r.HTAG, r.HTR, r.Referee
FROM `season-2425` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
UNION ALL
SELECT r.Date, '2025/26', ht.team_id, at.team_id, r.FTHG, r.FTAG, r.FTR, r.HTHG, r.HTAG, r.HTR, r.Referee
FROM `season-2526` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam;

-- ------------------------------------------------------------
-- Populate team_match_stats: two rows per match, one for the
-- home team and one for the away team, matched back to the
-- correct match_id by date, season, and both team IDs.
-- ------------------------------------------------------------
INSERT INTO team_match_stats (match_id, team_id, is_home, shots, shots_on_target, fouls, corners, yellow_cards, red_cards)
SELECT m.match_id, ht.team_id, 1, r.HS, r.HST, r.HF, r.HC, r.HY, r.HR
FROM `season-1617` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2016/17'
UNION ALL
SELECT m.match_id, at.team_id, 0, r.`AS`, r.AST, r.AF, r.AC, r.AY, r.AR
FROM `season-1617` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2016/17'
UNION ALL
SELECT m.match_id, ht.team_id, 1, r.HS, r.HST, r.HF, r.HC, r.HY, r.HR
FROM `season-1718` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2017/18'
UNION ALL
SELECT m.match_id, at.team_id, 0, r.`AS`, r.AST, r.AF, r.AC, r.AY, r.AR
FROM `season-1718` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2017/18'
UNION ALL
SELECT m.match_id, ht.team_id, 1, r.HS, r.HST, r.HF, r.HC, r.HY, r.HR
FROM `season-1819` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2018/19'
UNION ALL
SELECT m.match_id, at.team_id, 0, r.`AS`, r.AST, r.AF, r.AC, r.AY, r.AR
FROM `season-1819` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2018/19'
UNION ALL
SELECT m.match_id, ht.team_id, 1, r.HS, r.HST, r.HF, r.HC, r.HY, r.HR
FROM `season-1920` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2019/20'
UNION ALL
SELECT m.match_id, at.team_id, 0, r.`AS`, r.AST, r.AF, r.AC, r.AY, r.AR
FROM `season-1920` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2019/20'
UNION ALL
SELECT m.match_id, ht.team_id, 1, r.HS, r.HST, r.HF, r.HC, r.HY, r.HR
FROM `season-2021` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2020/21'
UNION ALL
SELECT m.match_id, at.team_id, 0, r.`AS`, r.AST, r.AF, r.AC, r.AY, r.AR
FROM `season-2021` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2020/21'
UNION ALL
SELECT m.match_id, ht.team_id, 1, r.HS, r.HST, r.HF, r.HC, r.HY, r.HR
FROM `season-2122` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2021/22'
UNION ALL
SELECT m.match_id, at.team_id, 0, r.`AS`, r.AST, r.AF, r.AC, r.AY, r.AR
FROM `season-2122` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2021/22'
UNION ALL
SELECT m.match_id, ht.team_id, 1, r.HS, r.HST, r.HF, r.HC, r.HY, r.HR
FROM `season-2223` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2022/23'
UNION ALL
SELECT m.match_id, at.team_id, 0, r.`AS`, r.AST, r.AF, r.AC, r.AY, r.AR
FROM `season-2223` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2022/23'
UNION ALL
SELECT m.match_id, ht.team_id, 1, r.HS, r.HST, r.HF, r.HC, r.HY, r.HR
FROM `season-2324` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2023/24'
UNION ALL
SELECT m.match_id, at.team_id, 0, r.`AS`, r.AST, r.AF, r.AC, r.AY, r.AR
FROM `season-2324` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2023/24'
UNION ALL
SELECT m.match_id, ht.team_id, 1, r.HS, r.HST, r.HF, r.HC, r.HY, r.HR
FROM `season-2425` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2024/25'
UNION ALL
SELECT m.match_id, at.team_id, 0, r.`AS`, r.AST, r.AF, r.AC, r.AY, r.AR
FROM `season-2425` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2024/25'
UNION ALL
SELECT m.match_id, ht.team_id, 1, r.HS, r.HST, r.HF, r.HC, r.HY, r.HR
FROM `season-2526` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2025/26'
UNION ALL
SELECT m.match_id, at.team_id, 0, r.`AS`, r.AST, r.AF, r.AC, r.AY, r.AR
FROM `season-2526` r JOIN teams ht ON ht.team_name = r.HomeTeam JOIN teams at ON at.team_name = r.AwayTeam
JOIN matches m ON m.home_team_id = ht.team_id AND m.away_team_id = at.team_id AND m.match_date = r.Date AND m.season = '2025/26';

-- ------------------------------------------------------------
-- Verify row counts before dropping the staging tables.
-- Expected: 34 teams, 3800 matches, 7600 stats rows.
-- ------------------------------------------------------------
SELECT (SELECT COUNT(*) FROM teams) AS team_count,
       (SELECT COUNT(*) FROM matches) AS match_count,
       (SELECT COUNT(*) FROM team_match_stats) AS stat_count;

DROP TABLE `season-1617`, `season-1718`, `season-1819`, `season-1920`, `season-2021`,
           `season-2122`, `season-2223`, `season-2324`, `season-2425`, `season-2526`;
