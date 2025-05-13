-- Football Match exercise
 
/*
The FootballMatch table shows the EPL matches played in 2024/25 season as of 16th March 2025
 
Important Columns
Date - Match Date (dd/mm/yy)
Time - Time of match kick off
HomeTeam- Home Team
AwayTeam - Away Team
FTHG -Full Time Home Team Goals
FTAG - Full Time Away Team Goals
FTR - Full Time Result (H=Home Win, D=Draw, A=Away Win)
 
Full details at https://zomalex.co.uk/datasets/football_match_dataset.html
*/
 
SELECT
    fm.Date
    , fm.HomeTeam
    , fm.AwayTeam
    , fm.FTHG
    , fm.FTAG
    , fm.FTR
FROM
    FootballMatch fm
 
/*
How many games have been played?.  
- In total
- By each team
- By Month
*/
---------------------------------------------------------------

select * from FootballMatch

select count(*) as NumberofMatches from FootballMatch

---------------------------------------------------------------

SELECT Team, COUNT(*) AS GamesPlayed
FROM (
    SELECT HomeTeam AS Team FROM FootballMatch
    UNION ALL
    SELECT AwayTeam AS Team FROM FootballMatch
) AS AllTeams
GROUP BY Team
ORDER BY GamesPlayed DESC;

---------------------------------------------------------------

SELECT 
    MONTH([Date]) as MonthNumber
    ,DATENAME(MONTH, [Date]) as MonthName
    ,COUNT(*) AS GamesPlayed
FROM FootballMatch
GROUP BY Month(Date),DATENAME(MONTH, [Date])
ORDER BY Month(Date),DATENAME(MONTH, [Date]);

SELECT 
     DATENAME(YEAR, [Date]) as YearName
    ,DATENAME(MONTH, [Date]) as MonthName
    --,MONTH([Date]) as MonthNumber
    ,COUNT(*) AS GamesPlayed
FROM FootballMatch
GROUP BY DATENAME(YEAR, [Date]),Month(Date),DATENAME(MONTH, [Date]) 
ORDER BY DATENAME(YEAR, [Date]),Month(Date),DATENAME(MONTH, [Date]);

---------------------------------------------------------------
 
-- How many goals have been scored in total

SELECT
    SUM(FTHG + FTAG) AS TotalGoals
FROM
    FootballMatch;

---------------------------------------------------------------

 -- How many goals have been scored by each team?

SELECT
    Team
    ,SUM(Goals) AS TotalGoals
FROM
    (
            SELECT
            HomeTeam AS Team
            ,FTHG AS Goals
        FROM
            FootballMatch
    UNION ALL
        SELECT
            AwayTeam AS Team
            ,FTAG AS Goals
        FROM
            FootballMatch
) AS AllGoals
GROUP BY Team
ORDER BY Team,TotalGoals DESC;

----- CTE Approach

;WITH cte (Team, Goals) AS
    (
            SELECT
                HomeTeam
            ,FTHG
            FROM
                FootballMatch
        UNION ALL
            SELECT
                AwayTeam
            ,FTAG
            FROM
                FootballMatch
    )

SELECT
    Team
    ,SUM(Goals) AS TotalGoals
FROM
    cte
GROUP BY Team
ORDER BY Team,TotalGoals DESC;

----- Temp Table Approach

DROP TABLE IF EXISTS #leaguetable

SELECT
    HomeTeam as Team
    ,FTHG as Goals
INTO #leaguetable
FROM
    FootballMatch
UNION ALL
SELECT
    AwayTeam as Team
    ,FTAG as Goals
FROM
    FootballMatch

SELECT
    Team
    ,SUM(Goals) AS TeamGoals
FROM
    #leaguetable
GROUP BY Team
ORDER BY Team;

---------------------------------------------------------------

DROP TABLE IF EXISTS #LeagueTable;
 
SELECT
    fm.HomeTeam as Team
    , FTR
    , SUM(fm.FTHG) as GF
    , 1 as GA
INTO #LeagueTable
FROM
    FootballMatch fm
group by fm.HomeTeam, FTR
UNION ALL
SELECT
    fm.AwayTeam
    , FTR
    , SUM(fm.FTAG)
    , 1 
FROM
    FootballMatch fm
group by fm.AwayTeam, FTR  
 
--SELECT * FROM #LeagueTable;
 
SELECT
    t.Team AS Team
    ,count(*) AS Played
    ,SUM(T.GF) AS GF
    ,SUM(T.GA) AS GA
FROM
    #LeagueTable t
GROUP BY t.Team
ORDER BY t.Team

select * from FootballMatch
-------------------------------------------------------

DROP TABLE IF EXISTS #LeagueTable

SELECT 
    HomeTeam AS Team,
    FTHG AS GF,
    FTAG AS GA,
    CASE 
        WHEN FTR = 'H' THEN 1 
        ELSE 0 
    END AS Won,
    CASE 
        WHEN FTR = 'D' THEN 1 
        ELSE 0 
    END AS Draw,
    CASE 
        WHEN FTR = 'A' THEN 1 
        ELSE 0 
    END AS Loss
INTO #LeagueTable
FROM FootballMatch

UNION ALL

SELECT 
    AwayTeam AS Team,
    FTAG AS GF,
    FTHG AS GA,
    CASE 
        WHEN FTR = 'A' THEN 1 
        ELSE 0 
    END AS Won,
    CASE 
        WHEN FTR = 'D' THEN 1 
        ELSE 0 
    END AS Draw,
    CASE 
        WHEN FTR = 'H' THEN 1 
        ELSE 0 
    END AS Loss
FROM FootballMatch

SELECT
    Team,
    COUNT(*) AS Played,
    SUM(Won) AS Wins,
    SUM(Draw) AS Draw,
    SUM(Loss) AS Loss,
    SUM(GF) AS GoalsFor,
    SUM(GA) AS GoalsAgainst,
    SUM(Won) * 3 + SUM(Draw) AS Points
FROM #LeagueTable
GROUP BY Team
ORDER BY Points DESC, GoalsFor DESC;
 