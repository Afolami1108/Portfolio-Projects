-- Austin Police Department (APD)

SELECT *
FROM APD;

-- Deleting all Null values

DELETE 
FROM APD 
WHERE Incident_Number is null;


-- Converting  Response_Datetime to 12 Hours Date_time 

ALTER TABLE APD ADD Response_Datetime2 DATETIME;

UPDATE APD
SET Response_Datetime2 = TRY_CONVERT(datetime, Response_Datetime,0);

ALTER TABLE APD
ADD Response_Datetime3 VARCHAR(20);

UPDATE APD
SET Response_Datetime3 = FORMAT(Response_Datetime2, 'MM/dd/yyyy hh:mm tt');

ALTER TABLE APD
DROP COLUMN Response_Datetime, Response_Datetime2;


-- Converting First_Unit_Arrived_Datetime to 12 Hours Date_time

ALTER TABLE APD ADD First_Unit_Arrived_Datetime2 DATETIME;

UPDATE APD
SET First_Unit_Arrived_Datetime2 = TRY_CONVERT(datetime, First_Unit_Arrival_Datetime,0);

ALTER TABLE APD
ADD First_Unit_Arrived_Datetime3 VARCHAR(20);

UPDATE APD
SET First_Unit_Arrived_Datetime3 = FORMAT(First_Unit_Arrived_Datetime2, 'MM/dd/yyyy hh:mm tt');


ALTER TABLE APD
DROP COLUMN First_Unit_Arrival_Datetime, First_Unit_Arrived_Datetime2;




-- Converting Call_Closed_Datetime to 12 Hours Date_time

ALTER TABLE APD ADD Call_Closed_Datetime2 DATETIME;

UPDATE APD
SET Call_Closed_Datetime2 = TRY_CONVERT(datetime, Call_Closed_Casetime,0);

ALTER TABLE APD
ADD Call_Closed_Datetime3 VARCHAR(20);

UPDATE APD
SET Call_Closed_Datetime3 = FORMAT(Call_Closed_Datetime2, 'MM/dd/yyyy hh:mm tt');


ALTER TABLE APD
DROP COLUMN Call_Closed_casetime, Call_Closed_Datetime2;

--- Key Questions

--1 •	What is the total number of incidents that occurred in each sector?

SELECT Sector, COUNT(*) AS Total_Incidents
FROM APD
GROUP BY Sector
ORDER BY Total_Incidents DESC;


--2 •	What are the top 5 busiest geographic areas in terms of 911 calls, and what is the average response time for each of these areas?

SELECT TOP 5 Geo_ID, COUNT(*) Busiest_Geographic, ROUND(AVG(Response_Time),2) AS AVG_Response_Time
FROM APD
GROUP BY Geo_ID
ORDER BY Busiest_Geographic DESC;


--3 •	Identify sectors where mental health-related incidents make up more than 30% of the total incidents.

SELECT Sector,
	SUM(CASE WHEN Mental_Health_Flag = 'Mental Health Incident' THEN 1 ELSE 0 END) As Mental_Health_Incidents,
	COUNT(*) AS Total_Incidents,
	ROUND(CAST(SUM(CASE WHEN Mental_Health_Flag = 'Mental Health Incident' THEN 1 ELSE 0 END)*100 AS FLOAT) / COUNT(*),2) AS Per_of_Mental_Health_Incidents
FROM APD
GROUP BY Sector 
HAVING ROUND(CAST(SUM(CASE WHEN Mental_Health_Flag = 'Mental Health Incident' THEN 1 ELSE 0 END)*100 AS FLOAT) / COUNT(*),2) > 30;


--4 •	What are the busiest days of the week, and how do the Mental Health Flag differ across those days?

SELECT Response_Day_of_Week, COUNT(*) Total_Incidents, Mental_Health_Flag
FROM APD
GROUP BY Response_Day_of_Week, Mental_Health_Flag
ORDER BY Response_Day_of_Week;


--5 •	What is the average response time for all incidents involving mental health issues?

SELECT ROUND(AVG(Response_Time),2) AS AVG_Response_Time_for_incidents_involving_Mental_Health
FROM APD
WHERE Mental_Health_Flag = 'Mental Health Incident';


--6 •	Which Mental Health Flag have response times that are above the overall average response time?

SELECT Mental_Health_Flag, ROUND(AVG(Response_Time),2) AS AVG_Response_Time
FROM APD
GROUP BY Mental_Health_Flag
HAVING ROUND(AVG(Response_Time),2) > (SELECT ROUND(AVG(Response_Time),2) FROM APD);


--7 •	Find the geographic areas where the average number of units dispatched is greater than the average number of units dispatched across all areas.
 
 SELECT Geo_ID, ROUND(AVG(Number_of_Units_Arrived),2) AS  Unit_Dispatched
 FROM APD
 GROUP BY Geo_ID
 HAVING ROUND(AVG(Number_of_Units_Arrived),2) > (SELECT ROUND(AVG(Number_of_Units_Arrived),2) FROM APD);


 --8 •	Which sectors have the highest percentage of reclassified calls (where the final problem description differs from the initial one)?

 SELECT Sector,
 SUM(CASE WHEN Initial_Problem_Description <> Final_Problem_Description THEN 1 ELSE 0 END) AS Reclassified_Calls,
 COUNT(*) AS Total_Calls,
 ROUND(CAST(SUM(CASE WHEN Initial_Problem_Description <> Final_Problem_Description THEN 1 ELSE 0 END) *100 AS FLOAT) / COUNT(*),2) AS Percent_of_Reclassified_Calls 
 FROM APD
 GROUP BY Sector
 ORDER BY Percent_of_Reclassified_Calls DESC;

 --9 •	What is the cumulative number of calls throughout each day, and how does this cumulative total change by sector?

 SELECT Response_Day_of_Week, Sector, COUNT(*) Cumulative_calls
 FROM APD
 GROUP BY Sector, Response_Day_of_Week
 ORDER BY Response_Day_of_Week


 --10 •	For each sector, rank the geographic areas by total number of 911 calls and show the response time for each area.
 
 SELECT sector,Geo_ID,
 COUNT(*) AS total_calls,
 sum(Response_Time),
 ROW_NUMBER() OVER (PARTITION BY sector ORDER BY COUNT(*) DESC) AS rank
 FROM APD
 GROUP BY sector, Geo_ID
 ORDER BY sector, rank; 

 -----OR

  SELECT sector,Geo_ID,
 COUNT(*) AS total_calls,
 sum(DATEDIFF(MINUTE,cast(response_datetime as time), cast(First_Unit_Arrived_Datetime as time))),
 ROW_NUMBER() OVER (PARTITION BY sector ORDER BY COUNT(*) DESC) AS rank
 FROM APD
 GROUP BY sector, Geo_ID
 ORDER BY sector,rank;

--11 •	What are the most common Mental Health Flag that occur between 10 PM and 6 AM?

 SELECT Mental_Health_Flag, COUNT(*) Total_Incidents
 FROM APD
 WHERE CAST(Response_Datetime AS TIME) >= '22:00:00' OR CAST(Response_Datetime AS TIME) < '06:00:00'
 GROUP BY Mental_Health_Flag
 ORDER BY Total_Incidents DESC;

--12 •	What percentage of incidents required more than 3 units to be dispatched?

SELECT COUNT(*) Total_incidents,
SUM(CASE WHEN Number_of_Units_Arrived > 3 THEN 1 ELSE 0 END) AS more_than_3_Units_Dispatched,
ROUND(CAST(SUM(CASE WHEN Number_of_Units_Arrived > 3 THEN 1 ELSE 0 END)*100 AS FLOAT) / COUNT(*),2) AS Percentage_of_more_than_3_Units_Dispatched
FROM APD;


--13 •	How do response times compare across different priorities for each Mental Health Flag?

SELECT Priority_Level, Mental_Health_Flag, SUM(Response_Time)
FROM APD
GROUP BY  Priority_Level, Mental_Health_Flag
ORDER BY Priority_Level;


--14 •	Which geographic areas have the highest number of incidents involving officer injuries or fatalities?

SELECT Geo_ID, SUM([Officer_Injured/Killed_Count]) AS Officer_Injuries_OR_Fatalities
FROM APD
GROUP BY Geo_ID
ORDER BY Officer_Injuries_OR_Fatalities DESC;


--15 •	Which council districts have the highest average response times?

SELECT Council_District, ROUND(AVG(Response_Time),2) AS Average_Response
FROM APD
GROUP BY Council_District
ORDER BY Average_Response DESC;

--16 •	How many incidents involve serious injury or death (either officers or subjects) related to mental health?

 SELECT COUNT(*) Total_Incidents
 FROM APD
 WHERE [Officer_Injured/Killed_Count] > 0  OR [Subject_Injured/Killed_Count]  > 0 
 AND Mental_Health_Flag = 'Mental Health Incident';


 --17 •	Find the average response time for each incident type and compare it with the overall average response time.
 
 SELECT Mental_Health_Flag, ROUND(AVG(Response_Time),2) AS AVG_Response_Time, 
 (SELECT ROUND(AVG(Response_Time),2) FROM APD) AS Overall_AVG_Response_Time
 FROM APD
 GROUP BY Mental_Health_Flag;


 --18 • Which Mental Health Flag have closure times that are longer than the average closure time for all incidents?

 SELECT Mental_Health_Flag, ROUND(AVG(CAST(TRY_CAST(Call_Closed_Datetime AS DATETIME) AS FLOAT)),2) AS average_time
 FROM APD
GROUP BY Mental_Health_Flag
 HAVING ROUND(AVG(CAST(TRY_CAST(Call_Closed_Datetime AS DATETIME) AS FLOAT)),2) > (SELECT 
    Round(AVG(CAST(TRY_CAST(Call_Closed_Datetime AS DATETIME) AS FLOAT)),2) AS average_time FROM APD);


--19 •	For each day of the week, calculate the difference between the average response time for that day and the average response time for all days combined.

SELECT Response_Day_of_Week, ROUND(AVG(CAST(TRY_CAST(Response_Datetime AS DATETIME) AS FLOAT)),2) AS AVG_Response_Time,
(SELECT ROUND(AVG(CAST(TRY_CAST(Response_Datetime AS DATETIME) AS FLOAT)),2) FROM APD) AS Overall_AVG_Response_Time,
ROUND(AVG(CAST(TRY_CAST(Response_Datetime AS DATETIME) AS FLOAT)) - (SELECT AVG(CAST(TRY_CAST(Response_Datetime AS DATETIME) AS FLOAT)) FROM APD),2) AS Difference
FROM APD
GROUP BY Response_Day_of_Week;


--20 •	What are the top 3 most frequent final problem descriptions?

SELECT TOP 3  Final_Problem_Description, COUNT(*) AS count
FROM APD
GROUP BY Final_Problem_Description
ORDER BY COUNT DESC;


--21 •	What are the busiest times of the day, and how do incident types vary by time?

SELECT Response_Day_of_Week,Response_Hour, COUNT(*) AS Total_Incidents
FROM APD
GROUP BY Response_Day_of_Week, Response_Hour
ORDER BY Response_Day_of_Week, Response_Hour;


--22 •	What is the total number of mental health-related incidents, and how has this changed over time?

SELECT distinct YEAR(CAST(Response_Datetime AS DATE)) AS incident_year, COUNT(*) Total_Incidents
FROM APD
WHERE Mental_Health_Flag = 'Mental Health Incident'
GROUP BY  YEAR(CAST(Response_Datetime AS DATE))
ORDER BY incident_year;


--23 •	Which sectors have above-average mental health-related incidents compared to the overall average for all sectors

WITH SectorMentalHealth AS(
SELECT Sector, COUNT(*) AS Sector_Mental_Health_Count
FROM APD
WHERE Mental_Health_Flag = 'Mental Health Incident'
GROUP BY Sector
),
ORA AS (
 SELECT ROUND(AVG(Sector_Mental_Health_Count * 1.0),2) AS Overall_Avg
 FROM SectorMentalHealth
 )
 SELECT SMH.Sector, SMH.Sector_Mental_Health_Count, ORA.Overall_Avg
 FROM SectorMentalHealth SMH
 CROSS JOIN ORA
 WHERE Sector_Mental_Health_Count > Overall_Avg;


--24 •	What is the average time spent on scene by units across different types of incidents?

SELECT Mental_Health_Flag, ROUND(AVG(Units_Time_on_Scene),2) AS AVG_Time_Spent_On_Scene
FROM APD
GROUP BY Mental_Health_Flag;


--25 •	What is the distribution of response times across the sectors, and which sectors have the fastest and slowest response times?

SELECT 
    sector,
    AVG(response_time) AS average_response_time,
    MIN(response_time) AS fastest_response_time,
    MAX(response_time) AS slowest_response_time
FROM APD
GROUP BY sector
ORDER BY Average_response_time ASC;
