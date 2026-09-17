# Premier League Match Analysis (SQL)

A SQL project analyzing 10 seasons of Premier League match data, from 2016/17 through 2025/26. Follows the same tiered structure as the IPL Cricket SQL project: basic, intermediate, and advanced queries, moving from simple filtering through joins and into window functions.

**Status: in progress. Basic and intermediate tiers complete. Advanced tier to follow.**

## Data source

Match data comes from [DataHub.io's English Premier League dataset](https://datahub.io/football/english-premier-league). The 10 seasons used here all include full match statistics: goals, half time scores, shots, shots on target, fouls, corners, cards, and referee.

## Schema

The source CSVs are flat, one row per match, with home and away statistics sitting in separate columns. Rather than query that structure directly, the data was normalized into three tables:

- **teams**: one row per club. 34 teams appear across the 10 seasons, reflecting normal promotion and relegation.
- **matches**: one row per fixture, with home and away teams stored as foreign keys rather than repeated as text.
- **team_match_stats**: one row per team per match, rather than separate home and away columns. This means a stat like shots or cards can be aggregated per team with a plain GROUP BY, instead of averaging two different columns together.

A fourth table, **team_season_goals**, was added during the intermediate tier as a helper for the top scorer question, one row per team per season with their combined home and away goals already summed.

This mirrors the same normalization approach used in the Melbourne Foot Traffic project, applied here to a different domain.

## Files

- `schema_and_load.sql`: creates the three core tables and populates them from the raw season CSVs. The CSVs themselves were imported into staging tables using MySQL Workbench's Table Data Import Wizard before this script runs.
- `basic_queries.sql`: the basic tier questions, with each query preceded by the question it answers.
- `intermediate_queries.sql`: the intermediate tier questions, same format, including the team_season_goals helper table.

## Basic tier findings

- 34 distinct teams appeared across the 10 seasons.
- 3,800 total matches, exactly 380 per season, confirming a clean import with no missing or duplicated fixtures.
- Home teams won 44.6% of matches, away teams won 32.1%, and 23.2% ended in draws. A clear home advantage, consistent with established football analytics.
- Average yellow cards per match: 3.51, in line with typical Premier League disciplinary patterns.
- A Taylor was the most active referee in the dataset, officiating 295 of the 3,800 matches, about 7.8% of all fixtures.

## Intermediate tier findings

- **Top scorer by season**: Man City led 8 of the 10 seasons, including a 106 goal season in 2017/18, their well documented record breaking title year. Tottenham topped 2016/17 (86 goals) and Liverpool broke City's run in 2024/25 (also 86), matching their real title winning season.
- **Most wins overall (10 seasons combined)**: Man City (269), Liverpool (238), Arsenal (217), Chelsea (195), Man United (189). This lines up with the known "big six" hierarchy over this period, with United sitting lowest of the traditional top clubs, reflecting their well documented decline since 2013.
- **Home advantage by team**: among clubs with a full 10 season history, Arsenal (+0.216), Tottenham (+0.184), and Liverpool (+0.179) show the largest gap between home and away win rate. Man City (+0.121) and Chelsea (+0.079) show the smallest gap among the top clubs, suggesting elite teams rely less on home support than mid table sides do. Teams with only one season in this window (for example Hull, Ipswich, Middlesbrough) show much larger swings, but on a sample of only 19 home and 19 away matches, so those figures are noted rather than treated as reliable trends.
- **Fouls per match** (teams with 150+ matches only, to exclude small single season samples): Watford fouled the most per match (12.18), Man City the least (8.94). Ranking by raw total fouls instead would have been misleading, since it mostly reflects how many matches a team played rather than how foul prone they actually were, Everton had the highest raw total but only a mid table rate once matches played is accounted for.
- **Average shots on target per match** (same 150+ match filter): Man City led (6.30), followed by Liverpool (6.03), consistent with their attacking, possession heavy style over this period. Burnley was lowest (3.33), consistent with a more defensive, counter attacking approach.

## Next steps

Advanced tier: window functions for winning and losing streaks, and season over season trend analysis.
