-- ============================================================
-- Premier League SQL Analysis
-- Basic tier queries
-- ============================================================
-- Run schema_and_load.sql first. All queries below assume the
-- teams, matches, and team_match_stats tables already exist
-- and are populated.
-- ============================================================

USE premier_league;


-- Q1. How many distinct teams appear in the dataset?
SELECT COUNT(*) AS team_count
FROM teams;


-- Q2. List every match where the home team scored more than
-- 3 goals, with the home team's name shown instead of its ID.
SELECT m.match_id, m.match_date, m.season,
       ht.team_name AS home_team, m.home_goals,
       m.away_goals
FROM matches m
JOIN teams ht ON m.home_team_id = ht.team_id
WHERE m.home_goals > 3;

-- Q2 (extended). Same as above, with the away team's name
-- also shown for context.
SELECT m.match_id, m.match_date, m.season,
       ht.team_name AS home_team, m.home_goals,
       awtm.team_name AS away_team, m.away_goals
FROM matches m
JOIN teams ht ON m.home_team_id = ht.team_id
JOIN teams awtm ON m.away_team_id = awtm.team_id
WHERE m.home_goals > 3;


-- Q3. How many matches ended in a draw?
SELECT COUNT(*) AS draw_count
FROM matches
WHERE result = 'D';


-- Q4. Which five referees have officiated the most matches?
SELECT referee, COUNT(*) AS matches_officiated
FROM matches
GROUP BY referee
ORDER BY matches_officiated DESC
LIMIT 5;


-- Q5. How many matches were played each season?
-- Sanity check: every season should show exactly 380.
SELECT season, COUNT(*) AS matches_played
FROM matches
GROUP BY season
ORDER BY season;


-- Q6. What is the average number of yellow cards per match?
-- team_match_stats holds one row per team per match, so the
-- two rows for each match are summed first, then averaged,
-- rather than averaging all rows directly.
SELECT AVG(match_total_yellows) AS avg_yellow_cards_per_match
FROM (
  SELECT match_id, SUM(yellow_cards) AS match_total_yellows
  FROM team_match_stats
  GROUP BY match_id
) AS match_totals;


-- Q7. How many matches ended in a home win, an away win, or
-- a draw?
SELECT result, COUNT(*) AS match_count
FROM matches
GROUP BY result
ORDER BY match_count DESC;
