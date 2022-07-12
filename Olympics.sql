## Question 1- Identify the sport that was played in all summer olympics

## 1. Find for total number of summer olympic games
## 2. Find for each sport, how many games were played
## 3. Compare 1 & 2

create temporary table t1
select count(distinct games) as total_summer_games
   from athlete_events
   where season = 'Summer'
   order by games;
   
create temporary table t2
  select distinct sport, games
   from athlete_events
   where season = 'Summer';
   
create temporary table t3
   select sport, count(games) as no_of_games
   from total_summer_sports
   group by sport;

select * from t3
join t1 on t1.total_summer_games = t3.no_of_games;


## Question 2- Fetch the top 5 athletes who have won the most gold medals
CREATE TEMPORARY TABLE t4
SELECT Distinct Name, COUNT(medal) as No_of_gold_medals
FROM athlete_events 
WHERE medal = 'Gold'
GROUP BY Name
ORDER BY No_of_gold_medals DESC;

CREATE TEMPORARY TABLE t5
SELECT * , DENSE_RANK() OVER(ORDER BY No_of_gold_medals DESC) AS Rnk
FROM t4;

SELECT Name, No_of_gold_medals
FROM t5
WHERE Rnk <= 5;

### Question 3: List down total gold, silver and bronze medal won by each country
## Take out records with no medal
CREATE TEMPORARY TABLE t7
SELECT nc.region AS country, Medal, Count(*) as Total_Medals 
FROM athlete_events ae
JOIN noc_regions nc
ON ae.noc = nc.NOC
WHERE Medal <> 'NA'
GROUP BY nc.region, Medal
ORDER BY nc.region, Medal;

### Pivoting table to show the corresponding medals
SELECT country,
       SUM(CASE WHEN Medal = 'Bronze' THEN Total_Medals ELSE 0 END) AS Bronze,
       SUM(CASE WHEN Medal = 'Silver' THEN Total_Medals ELSE 0 END) AS Silver,
       SUM(CASE WHEN Medal = 'Gold' THEN Total_Medals ELSE 0 END) AS Gold
FROM t7
GROUP BY country
ORDER BY country;

### Question 4: Identify which country won the most gold, most silver, and most bronze medal in each Olympic games

CREATE TEMPORARY TABLE t8
SELECT CONCAT(ae.Games, " - ", nc.region) AS games_country, Medal, Count(*) as Total_Medals 
FROM athlete_events ae
JOIN noc_regions nc
ON ae.noc = nc.NOC
WHERE Medal <> 'NA'
GROUP BY games_country, Medal
ORDER BY games_country;

## separating games and country and listing the number of medals won
CREATE TEMPORARY TABLE t10
SELECT SUBSTRING(games_country, 1, position(' - ' IN games_country) - 1) as games,
       SUBSTRING(games_country, position(' - ' IN games_country) + 3) as country,
       SUM(CASE WHEN Medal = 'Bronze' THEN Total_Medals ELSE 0 END) AS Bronze,
       SUM(CASE WHEN Medal = 'Silver' THEN Total_Medals ELSE 0 END) AS Silver,
       SUM(CASE WHEN Medal = 'Gold' THEN Total_Medals ELSE 0 END) AS Gold
FROM t8
GROUP BY games_country
ORDER BY games_country;

## getting the max medal collected for each medal category
SELECT DISTINCT games,  
CONCAT(FIRST_VALUE(Gold) OVER(PARTITION BY games ORDER BY Gold DESC),' - ',
FIRST_VALUE(Country) OVER(PARTITION BY games ORDER BY Gold DESC)) AS Max_Gold,
CONCAT(FIRST_VALUE(Silver) OVER(PARTITION BY games ORDER BY Silver DESC),' - ',
FIRST_VALUE(Country) OVER(PARTITION BY games ORDER BY Silver DESC)) AS Max_Silver,
CONCAT(FIRST_VALUE(Bronze) OVER(PARTITION BY games ORDER BY Bronze DESC),' - ',
FIRST_VALUE(Country) OVER(PARTITION BY games ORDER BY Bronze DESC)) AS Max_Bronze
FROM t10






