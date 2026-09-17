-- ============================================================
-- Premier League SQL Analysis
-- Intermediate tier queries
-- ============================================================
-- Run schema_and_load.sql first. Q1 also needs a small helper
-- table, team_season_goals, created below before the question
-- itself. Everything else runs directly against teams,
-- matches, and team_match_stats.
-- ============================================================

USE premier_league;


-- ------------------------------------------------------------
-- Helper table for Q1. A team's goals live in two different
-- columns depending on whether they played home or away, so
-- this reshapes both into one consistent list first, then
-- sums it into one true total per team per season.
-- ------------------------------------------------------------
CREATE TABLE team_season_goals AS
SELECT team_id, season, SUM(goals) AS total_goals
FROM (
  SELECT home_team_id AS team_id, season, home_goals AS goals FROM matches
  UNION ALL
  SELECT away_team_id AS team_id, season, away_goals AS goals FROM matches
) AS team_match_goals
GROUP BY team_id, season;


-- Q1. For each season, which team scored the most total goals,
-- home and away combined?
-- MAX() alone returns the top value but not who it belongs to,
-- so the result is joined back to team_season_goals on both
-- season and total_goals to recover the team.
SELECT tsg.season, t.team_name, tsg.total_goals
FROM team_season_goals tsg
JOIN teams t ON t.team_id = tsg.team_id
JOIN (
  SELECT season, MAX(total_goals) AS max_goals
  FROM team_season_goals
  GROUP BY season
) AS season_max
  ON tsg.season = season_max.season
  AND tsg.total_goals = season_max.max_goals
ORDER BY tsg.season;


-- Q2. Top 5 teams by total wins across all 10 seasons combined.
-- A win depends on role (result = 'H' at home, result = 'A'
-- away), so both are stacked with UNION ALL into one list of
-- individual wins, then counted per team.
SELECT t.team_name, tw.total_wins
FROM (
  SELECT team_id, COUNT(*) AS total_wins
  FROM (
    SELECT home_team_id AS team_id
    FROM matches
    WHERE result = 'H'

    UNION ALL

    SELECT away_team_id AS team_id
    FROM matches
    WHERE result = 'A'
  ) AS all_wins
  GROUP BY team_id
) AS tw
JOIN teams t ON t.team_id = tw.team_id
ORDER BY tw.total_wins DESC
LIMIT 5;


-- Q3. For each team, compare win rate at home vs away, and
-- find the biggest gap between the two.
-- Home and away are built as two separate aggregates, then
-- joined together on team_id so both rates sit on one row and
-- can be subtracted. Match counts are included alongside the
-- rates, since teams with only one season in this window have
-- a much smaller sample and their rates should be read with
-- that in mind.
SELECT t.team_name,
       h.home_matches,
       a.away_matches,
       ROUND(h.home_wins / h.home_matches, 3) AS home_win_rate,
       ROUND(a.away_wins / a.away_matches, 3) AS away_win_rate,
       ROUND((h.home_wins / h.home_matches) - (a.away_wins / a.away_matches), 3) AS home_advantage_gap
FROM (
  SELECT home_team_id AS team_id,
         COUNT(*) AS home_matches,
         SUM(CASE WHEN result = 'H' THEN 1 ELSE 0 END) AS home_wins
  FROM matches
  GROUP BY home_team_id
) AS h
JOIN (
  SELECT away_team_id AS team_id,
         COUNT(*) AS away_matches,
         SUM(CASE WHEN result = 'A' THEN 1 ELSE 0 END) AS away_wins
  FROM matches
  GROUP BY away_team_id
) AS a ON h.team_id = a.team_id
JOIN teams t ON t.team_id = h.team_id
ORDER BY home_advantage_gap DESC;


-- Q4. Which team committed the most fouls, and in how many
-- matches did they play?
-- Ranking by raw total mostly just rewards teams who played
-- more matches, so a per-match rate is included and used for
-- the actual ranking. Teams with fewer than 150 matches in
-- this window are excluded, since a single season is too
-- small a sample to compare fairly against a full 10 seasons.
SELECT t.team_name,
       SUM(tms.fouls) AS total_fouls,
       COUNT(*) AS matches_played,
       ROUND(SUM(tms.fouls) / COUNT(*), 2) AS fouls_per_match
FROM team_match_stats tms
JOIN teams t ON t.team_id = tms.team_id
GROUP BY tms.team_id
HAVING COUNT(*) >= 150
ORDER BY fouls_per_match DESC;


-- Q5. Average shots on target per team, ranked highest to
-- lowest.
-- Same 150 match threshold as Q4, for the same reason. AVG()
-- already returns a per-match rate directly, no manual
-- division needed here.
SELECT t.team_name,
       COUNT(*) AS matches_played,
       ROUND(AVG(tms.shots_on_target), 2) AS average_shots_on_target
FROM team_match_stats tms
JOIN teams t ON t.team_id = tms.team_id
GROUP BY tms.team_id
HAVING matches_played >= 150
ORDER BY average_shots_on_target DESC;
