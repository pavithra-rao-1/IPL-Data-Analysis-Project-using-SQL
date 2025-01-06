select * from ipl_matches;

select * from ipl_balls;


--1. matches per season
select YEAR(date) as YEAR,count(distinct id) as No_of_Matches from ipl_matches group by YEAR(date);


--2. most player of match
select top 1 player_of_match, COUNT(player_of_match) as Count from ipl_matches group by player_of_match order by Count desc ;


--3. most player of match each season(1)
WITH RankedPlayers AS (SELECT 
        YEAR(date) AS Year, 
        player_of_match, 
        COUNT(player_of_match) AS Count,
        RANK() OVER (PARTITION BY YEAR(date) ORDER BY COUNT(player_of_match) DESC) AS Rank
    FROM ipl_matches
    GROUP BY YEAR(date), player_of_match)
SELECT Year, player_of_match, Count
FROM RankedPlayers WHERE Rank = 1 ORDER BY Year;


--4. most player of match each season(2)
WITH players AS (SELECT YEAR(date) AS Year, player_of_match, COUNT(player_of_match) AS Count        
FROM ipl_matches
GROUP BY player_of_match, YEAR(date))
SELECT Year, player_of_match, Count FROM players WHERE 
Count = (SELECT MAX(Count)FROM players p2 WHERE p2.Year = players.Year)ORDER BY Year;


--5. most wins by any team
select top 1 winner, COUNT(winner) Count from ipl_matches group by winner order by COUNT(winner) desc;


--6. most wins by any team each season
with players as 
(select year(date) Year, winner, COUNT(winner) Count from ipl_matches group by winner,YEAR(date))
select Year, winner, Count from players where Count = (select MAX(Count) from players p where p.Year = players.Year)
order by Year;


--7. top 5 venue where match is played
select top 5 venue, COUNT(venue) Count from ipl_matches group by venue order by Count desc;


--8. most runs by any batsman
select top 1 batsman, SUM(batsman_runs) Runs from ipl_balls group by batsman order by Runs desc;


--9. most runs by any batsman in each season
with players as 
(select YEAR(iplm.date) Year, iplb.batting_team, iplb.batsman, SUM(iplb.batsman_runs) Runs from ipl_matches iplm 
JOIN ipl_balls iplb ON iplm.id = iplb.id group by iplb.batsman, YEAR(iplm.date),iplb.batting_team)
select YEAR, batsman, batting_team, Runs from players where Runs = (select MAX(Runs) from players p where p.Year = players.Year)
order by Year;


--10. total runs in ipl
select SUM(total_runs) Total_runs_in_IPL from ipl_balls;


--11. most sixes by any batsman
select top 1 batsman, COUNT(batsman_runs) No_of_sixes
from ipl_balls where batsman_runs = 6 
group by batsman
order by No_of_sixes desc;


--12. most fours by any batsman
select top 1 batsman, COUNT(batsman_runs) No_of_sixes 
from ipl_balls where batsman_runs = 4 
group by batsman
order by No_of_sixes desc;


--13. percentage of runs by each batsman
select batsman, SUM(batsman_runs) Total_Runs, 
ROUND((SUM(batsman_runs)*100.0/(select SUM(batsman_runs) from ipl_balls)), 10) 
from ipl_balls group by batsman order by Total_Runs desc;


--14. 3000 runs and highest strike rate
select batsman, 
SUM(batsman_runs) Total_Runs, 
COUNT(*) No_of_balls, 
cast(SUM(batsman_runs) * 100.0/COUNT(*) AS decimal(10,3)) Strike_Rate
from ipl_balls 
group by batsman 
HAVING SUM(batsman_runs) > 3000 
order by Strike_Rate desc;


--15. highest strike rate
select top 1 batsman, 
SUM(batsman_runs) Total_Runs, 
COUNT(*) No_of_balls,
cast(SUM(batsman_runs) * 100.0/COUNT(*) AS decimal(10,3)) Strike_Rate
from ipl_balls 
group by batsman 
HAVING SUM(batsman_runs) > 3000
order by Strike_Rate desc;


--16. lowest economy rate for bowler with atleast 50 overs bowled
SELECT top 1 bowler, 
SUM(batsman_runs) Total_Runs, 
COUNT(CASE WHEN extra_runs = 0 THEN 1 END) / 6 Overs_Bowled,
CAST(SUM(total_runs)/(COUNT(CASE WHEN extra_runs = 0 THEN 1 END) / 6) as decimal(10,2)) Economy_Rate
FROM ipl_balls 
GROUP BY bowler 
having COUNT(CASE WHEN extra_runs = 0 THEN 1 END) / 6 > 50
order by Economy_Rate asc;


--17. total no. of matches 2008-2020
select COUNT(distinct id) No_of_Matches from ipl_matches;


--18. total no. of matches win by each team
select winner, COUNT(*) No_of_Wins from ipl_matches where winner != 'NA' group by winner order by No_of_Wins desc;


--19. does toss winning affect match winners
select team1, team2, 
COUNT(*) No_of_Matches, 
COUNT(case when toss_winner = winner then 1 end) Toss_win_Match_win,
cast(COUNT(case when toss_winner = winner then 1 end) * 1.0/COUNT(*) as decimal(10,5)) Ratio
from ipl_matches 
group by team1,team2
order by team1, team2;


--20. Toss/Win Ratio
select team1, team2, 
COUNT(*) No_of_Matches, 
COUNT(case when toss_winner = winner then 1 end) Toss_win_Match_win,
cast(COUNT(case when toss_winner = winner then 1 end) * 1.0/COUNT(*) as decimal(10,5)) Ratio
from ipl_matches 
group by team1,team2
order by team1,team2;


--21. average score of each team per season
select year(iplm.date) Year, batting_team, 
SUM(total_runs) Total_Runs,
COUNT(DISTINCT iplm.id) AS No_of_Matches,
cast(SUM(total_runs)*1.0/COUNT(DISTINCT iplm.id)AS decimal(10,3)) Average_Runs
from ipl_balls iplb 
join ipl_matches iplm on iplb.id = iplm.id 
group by batting_team, year(iplm.date)
order by Year;

--22. how many times each team score above 200
with players as(select id, batting_team, 
sum(total_runs) Total_Runs 
from ipl_balls
group by batting_team,id
having sum(total_runs) > 200)
select batting_team, COUNT(Total_Runs) No_of_times_Scored_Above_200 from players group by batting_team;


/*UPDATE ipl_matches
SET team1 = CASE WHEN team1 = 'Rising Pune Supergiants' THEN 'Rising Pune Supergiant' ELSE team1 END,
    team2 = CASE WHEN team2 = 'Rising Pune Supergiants' THEN 'Rising Pune Supergiant' ELSE team2 END;*/


--23. Centuries in Indian Premier League
with players as (select batsman, SUM(batsman_runs) Total_Runs 
from ipl_balls 
group by batsman,id 
having SUM(batsman_runs) >= 100)
select batsman, COUNT(Total_Runs) Centuries from players group by batsman order by Centuries desc;


--24. Top Ten Highest Scores in Indian Premier League
select top 10 batting_team, sum(total_runs) Runs from ipl_balls group by batting_team, id order by Runs desc;


--25. Players with most centuries in Indian Premier League
with players as (select batsman, SUM(batsman_runs) Total_Runs 
from ipl_balls 
group by batsman,id 
having SUM(batsman_runs) >= 100)
select top 1 batsman, COUNT(Total_Runs) Centuries from players group by batsman order by Centuries desc;


--26.  Highest wicket takers in Indian Premier League
select top 1 bowler, SUM(cast(is_wicket AS int)) Wickets from ipl_balls group by bowler order by Wickets desc;


--27. Overall Five wicket hauls in Indian Premier League
with player as(select id, bowler, SUM(cast(is_wicket AS int)) Wickets 
from ipl_balls 
group by bowler,id
having SUM(cast(is_wicket AS int)) >= 5)
select year(iplm.date) Year, p.bowler, p.Wickets, iplm.team1+' vs '+iplm.team2 as Team1_VS_Team2 from player p join ipl_matches iplm on p.id = iplm.id
order by p.Wickets;


--28. Bowlers with most five wicket hauls in Indian Premier League
with player as(select id, bowler, SUM(cast(is_wicket AS int)) Wickets 
from ipl_balls 
group by bowler,id
having SUM(cast(is_wicket AS int)) >= 5)
select top 5 year(iplm.date) Year, p.bowler, COUNT(Wickets) Five_wicket_hauls
from player p join ipl_matches iplm on p.id = iplm.id 
group by p.bowler, year(iplm.date)
order by Five_wicket_hauls desc;


--29. Batsman dismissed by Harbhajan most time in IPL
select batsman, dismissal_kind Harbhajan_dismissal from ipl_balls where bowler = 'Harbhajan Singh' and dismissal_kind != 'NA';


--30. Players who has taken most catches in IPL
select top 5 fielder, COUNT(*) No_of_Catches from ipl_balls where dismissal_kind = 'caught' group by fielder order by No_of_Catches desc;
