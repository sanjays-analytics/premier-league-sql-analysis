# Premier League Match Analysis (SQL)

A SQL project analyzing 10 seasons of Premier League match data, from 2016/17 through 2025/26. Follows the same tiered structure as the IPL Cricket SQL project: basic, intermediate, and advanced queries, moving from simple filtering through joins and into window functions.

**Status: in progress. Basic tier complete. Intermediate and advanced tiers to follow.**

## Data source

Match data comes from [DataHub.io's English Premier League dataset](https://datahub.io/football/english-premier-league). The 10 seasons used here all include full match statistics: goals, half time scores, shots, shots on target, fouls, corners, cards, and referee.

## Schema

The source CSVs are flat, one row per match, with home and away statistics sitting in separate columns. Rather than query that structure directly, the data was normalized into three tables:

- **teams**: one row per club. 34 teams appear across the 10 seasons, reflecting normal promotion and relegation.
- **matches**: one row per fixture, with home and away teams stored as foreign keys rather than repeated as text.
- **team_match_stats**: one row per team per match, rather than separate home and away columns. This means a stat like shots or cards can be aggregated per team with a plain GROUP BY, instead of averaging two different columns together.

This mirrors the same normalization approach used in the Melbourne Foot Traffic project, applied here to a different domain.

## Files

- `schema_and_load.sql`: creates the three tables and populates them from the raw season CSVs. The CSVs themselves were imported into staging tables using MySQL Workbench's Table Data Import Wizard before this script runs.
- `basic_queries.sql`: the basic tier questions, with each query preceded by the question it answers.

## Basic tier findings

- 34 distinct teams appeared across the 10 seasons.
- 3,800 total matches, exactly 380 per season, confirming a clean import with no missing or duplicated fixtures.
- Home teams won 44.6% of matches, away teams won 32.1%, and 23.2% ended in draws. A clear home advantage, consistent with established football analytics.
- Average yellow cards per match: 3.51, in line with typical Premier League disciplinary patterns.
- A Taylor was the most active referee in the dataset, officiating 295 of the 3,800 matches, about 7.8% of all fixtures.

## Next steps

Intermediate tier: joins across all three tables, top team performance per season, and comparisons between home and away form.

Advanced tier: window functions for winning and losing streaks, and season over season trend analysis.
