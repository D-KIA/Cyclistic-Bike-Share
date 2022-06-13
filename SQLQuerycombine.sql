USE Cyclistic
---------------------------------------------------------------------------PREPARE------------------------------------------------------------------------------------

-------------------------------------------Creating New table to combine data of 12 month
CREATE TABLE One_Year_Cyclistic_Data (
ride_id nvarchar(255), rideable_type nvarchar(255), started_at datetime, ended_at datetime, 
start_station_name nvarchar(255), start_station_id nvarchar(255), end_station_name nvarchar(255), end_station_id nvarchar(255),
start_lat float, start_lng float, end_lat float, end_lng float, member_casual nvarchar(255)
)

---------------------------------------Changing inconsistant data types across tables

ALTER TABLE [Cyclistic].dbo.['202104-divvy-tripdata$']
ALTER COLUMN end_station_id nvarchar(255);

ALTER TABLE [Cyclistic].dbo.['202107-divvy-tripdata$']
ALTER COLUMN end_station_id nvarchar(255);

ALTER TABLE [Cyclistic].dbo.['202107-divvy-tripdata$']
ALTER COLUMN start_station_id nvarchar(255);

ALTER TABLE [Cyclistic].dbo.['202111-divvy-tripdata$']
ALTER COLUMN start_station_id nvarchar(255);


-----------------------------------------Inserting monthly tables into new table

INSERT INTO One_Year_Cyclistic_Data (ride_id, rideable_type, started_at, ended_at, 
start_station_name, start_station_id, end_station_name, end_station_id,
start_lat, start_lng, end_lat, end_lng, member_casual
)
(
SELECT *
FROM ['202104-divvy-tripdata$']
UNION
SELECT *
FROM ['202105-divvy-tripdata$']
UNION
SELECT *
FROM ['202106-divvy-tripdata$']
UNION
SELECT *
FROM ['202107-divvy-tripdata$']
UNION
SELECT *
FROM ['202108-divvy-tripdata$']
UNION
SELECT *
FROM ['202109-divvy-tripdata$']
UNION
SELECT *
FROM ['202110-divvy-tripdata$']
UNION
SELECT *
FROM ['202111-divvy-tripdata$']
UNION
SELECT *
FROM ['202112-divvy-tripdata$']
UNION
SELECT *
FROM ['202201-divvy-tripdata$']
UNION
SELECT *
FROM ['202202-divvy-tripdata$']
UNION
SELECT *
FROM ['202203-divvy-tripdata$']
)

--------------------------------------------Change Date Format

--Starting Date

SELECT *, convert(DATE, started_at) as StartDate, convert(TIME(0), started_at) as StartTime
FROM [Cyclistic].dbo.[One_Year_Cyclistic_Data]

ALTER TABLE [Cyclistic].dbo.[One_Year_Cyclistic_Data]
ADD StartDate DATE

UPDATE [Cyclistic].dbo.[One_Year_Cyclistic_Data]
SET StartDate = convert(DATE, started_at)

ALTER TABLE [Cyclistic].dbo.[One_Year_Cyclistic_Data]
ADD StartTime TIME(0)

UPDATE [Cyclistic].dbo.[One_Year_Cyclistic_Data]
SET StartTime = convert(TIME(0), started_at)



----Ending Date

SELECT convert(DATE, ended_at) as EndDate, convert(TIME(0), ended_at) as EndTime
FROM [Cyclistic].dbo.[One_Year_Cyclistic_Data]


ALTER TABLE [Cyclistic].dbo.[One_Year_Cyclistic_Data]
ADD EndDate DATE

UPDATE [Cyclistic].dbo.[One_Year_Cyclistic_Data]
SET EndDate = convert(DATE, ended_at)

ALTER TABLE [Cyclistic].dbo.[One_Year_Cyclistic_Data]
ADD EndTime TIME(0)

UPDATE [Cyclistic].dbo.[One_Year_Cyclistic_Data]
SET EndTime = convert(TIME(0), ended_at)



----------------------------------------------------------------------------------PROCESS---------------------------------------------------------------------------
---------------------------------------------Checking data

--NULL Check
SELECT SUM(CASE WHEN end_station_name IS NULL THEN 1 ELSE 0 END) AS NullEndName, SUM(CASE WHEN end_station_id IS NULL THEN 1 ELSE 0 END) AS NullEndID, 
		SUM(CASE WHEN start_station_name IS NULL THEN 1 ELSE 0 END) AS NullStartName, SUM(CASE WHEN start_station_id IS NULL THEN 1 ELSE 0 END) AS NullStartID
FROM One_Year_Cyclistic_Data

--Spelling Check
SELECT DISTINCT rideable_type
FROM [Cyclistic].dbo.[One_Year_Cyclistic_Data]


SELECT DISTINCT member_casual
FROM [Cyclistic].dbo.[One_Year_Cyclistic_Data]

--Space Check
SELECT *
FROM [Cyclistic].dbo.[One_Year_Cyclistic_Data]
WHERE end_station_name LIKE '% ' OR end_station_name LIKE '% '

--Wrong Date
SELECT COUNT(*)
FROM One_Year_Cyclistic_Data
WHERE ended_at < started_at 

--------------------------------------------------------------------------------Adding New Column TravelTime as Difference ended_at and started_at 
SELECT top 100 ((DATEDIFF(MINUTE, started_at , ended_at))), StartTime, EndTime
FROM [Cyclistic].dbo.[One_Year_Cyclistic_Data]

Alter TABLE One_Year_Cyclistic_Data
ADD TravelTime FLOAT

Update One_Year_Cyclistic_Data
SET TravelTime = DATEDIFF(MINUTE, started_at , ended_at)


-----------------------------------------------------------------Deleting NULL Values Records
DELETE FROM One_Year_Cyclistic_Data
WHERE start_station_name IS NULL OR end_station_name IS NULL


-----------------------------------------------------------------ANALYSIS---------------------------------------------------------------


--------------------------------------------------------Comparing Two Types Of Memberships 
SELECT member_casual,
COUNT(member_casual) AS member_casual_count
FROM One_Year_Cyclistic_Data
GROUP BY member_casual

--------------------------------------------------------------Average Ride Duration

----Overall
SELECT ROUND(AVG(TravelTime),0) AS avg_ride_duration
FROM One_Year_Cyclistic_Data

SELECT DATENAME(WEEKDAY, StartDate) AS Week_Day, ROUND(AVG(TravelTime),0) AS avg_ride_duration
FROM One_Year_Cyclistic_Data
Group BY DATENAME(WEEKDAY, StartDate)


----For Member
SELECT ROUND(AVG(TravelTime),0) AS avg_ride_duration_for_members
FROM One_Year_Cyclistic_Data
WHERE member_casual = 'member'

SELECT DATENAME(WEEKDAY, StartDate) AS Week_Day, ROUND(AVG(TravelTime),0) AS avg_ride_duration
FROM One_Year_Cyclistic_Data
WHERE member_casual = 'member'
Group BY DATENAME(WEEKDAY, StartDate)

----For Casual
SELECT ROUND(AVG(TravelTime),0) AS avg_ride_duration_for_casual
FROM One_Year_Cyclistic_Data
WHERE member_casual = 'casual'

SELECT DATENAME(WEEKDAY, StartDate) AS Week_Day, ROUND(AVG(TravelTime),0) AS avg_ride_duration
FROM One_Year_Cyclistic_Data
WHERE member_casual = 'casual'
Group BY DATENAME(WEEKDAY, StartDate)

---------------------------------------------------------------Preffered Bike Type
----Overall
SELECT rideable_type, COUNT(rideable_type) AS Count
FROM One_Year_Cyclistic_Data
GROUP BY rideable_type

----For Members
SELECT rideable_type, COUNT(rideable_type) AS Count_For_Members
FROM One_Year_Cyclistic_Data
WHERE member_casual = 'member'
GROUP BY rideable_type

----For Casual
SELECT rideable_type, COUNT(rideable_type) AS Count_For_Casual
FROM One_Year_Cyclistic_Data
WHERE member_casual = 'casual'
GROUP BY rideable_type
---------------------------------------------------------------Most Used Pick up Point

--Overall
SELECT TOP 10 start_station_name, COUNT(start_station_name) AS Count
FROM One_Year_Cyclistic_Data
GROUP BY start_station_name
ORDER BY Count(start_station_name) Desc

----For Members
SELECT TOP 10 start_station_name, COUNT(start_station_name) AS Count_For_Members
FROM One_Year_Cyclistic_Data
WHERE member_casual = 'member'
GROUP BY start_station_name
ORDER BY Count(start_station_name) Desc

----For Casuals
SELECT TOP 10 start_station_name, COUNT(start_station_name) AS Count_For_Casual
FROM One_Year_Cyclistic_Data
WHERE member_casual = 'casual'
GROUP BY start_station_name
ORDER BY Count(start_station_name) Desc

---------------------------------------------------------------Most Used Drop Point

--Overall
SELECT TOP 10 end_station_name, COUNT(end_station_name) AS Count
FROM One_Year_Cyclistic_Data
GROUP BY end_station_name
ORDER BY Count(end_station_name) Desc

--For members
SELECT TOP 10 end_station_name, COUNT(end_station_name) AS Count_For_Members
FROM One_Year_Cyclistic_Data
WHERE member_casual = 'member'
GROUP BY end_station_name
ORDER BY Count(end_station_name) Desc

--For casuals
SELECT TOP 10 start_station_name, COUNT(start_station_name) AS Count_For_Casual
FROM One_Year_Cyclistic_Data
WHERE member_casual = 'casual'
GROUP BY start_station_name
ORDER BY Count(start_station_name) Desc

-------------------------------------------------------------Ride In Different Days Of Week
--Overall 
SELECT DATENAME(WEEKDAY, StartDate) AS Week_DAY, COUNT(DATENAME(WEEKDAY, StartDate)) AS Ride_Count
FROM One_Year_Cyclistic_Data
GROUP BY DATENAME(WEEKDAY, StartDate)
ORDER BY COUNT(DATENAME(WEEKDAY, StartDate)) DESC

--For Members
SELECT DATENAME(WEEKDAY, StartDate) AS Week_DAY, COUNT(DATENAME(WEEKDAY, StartDate)) AS Members_Ride_Count
FROM One_Year_Cyclistic_Data
WHERE member_casual = 'member'
GROUP BY DATENAME(WEEKDAY, StartDate)
ORDER BY COUNT(DATENAME(WEEKDAY, StartDate)) DESC

--For Casuals
SELECT DATENAME(WEEKDAY, StartDate) AS Week_DAY, COUNT(DATENAME(WEEKDAY, StartDate)) AS Casual_Ride_Count
FROM One_Year_Cyclistic_Data
WHERE member_casual = 'casual'
GROUP BY DATENAME(WEEKDAY, StartDate)
ORDER BY COUNT(DATENAME(WEEKDAY, StartDate)) DESC


---------------------------------------------------------------Monthly Evaluation
----Overall 
SELECT DATENAME(MONTH, StartDate) AS Month, COUNT(DATENAME(WEEKDAY, StartDate)) AS Ride_Count
FROM One_Year_Cyclistic_Data
GROUP BY DATENAME(MONTH, StartDate)
ORDER BY COUNT(DATENAME(MONTH, StartDate)) DESC

----For Members
SELECT DATENAME(MONTH, StartDate) AS Month, COUNT(DATENAME(WEEKDAY, StartDate)) AS Member_Ride_Count
FROM One_Year_Cyclistic_Data
WHERE member_casual = 'member'
GROUP BY DATENAME(MONTH, StartDate)
ORDER BY COUNT(DATENAME(MONTH, StartDate)) DESC

----For Casual
SELECT DATENAME(MONTH, StartDate) AS Month, COUNT(DATENAME(WEEKDAY, StartDate)) AS Casual_Ride_Count
FROM One_Year_Cyclistic_Data
WHERE member_casual = 'casual'
GROUP BY DATENAME(MONTH, StartDate)
ORDER BY COUNT(DATENAME(MONTH, StartDate)) DESC

------------------------------------------------------------------Same Start And End VS Different Start And End 

--Same Start Station And End Station (Overall)
SELECT ROUND(AVG(TravelTime),0) AS avg_ride_duration_for_same_start_and_end_station
FROM One_Year_Cyclistic_Data
WHERE start_station_name = end_station_name

--For member_casual
SELECT member_casual, ROUND(AVG(TravelTime),0) AS avg_ride_duration_for_same_start_and_end_station
FROM One_Year_Cyclistic_Data
WHERE start_station_name = end_station_name
Group BY member_casual


--Different Start Station And End Station
SELECT ROUND(AVG(TravelTime),0) AS avg_ride_duration_for_different_start_and_end_station
FROM One_Year_Cyclistic_Data
WHERE start_station_name <> end_station_name

--For member_casual
SELECT member_casual, ROUND(AVG(TravelTime),0) AS avg_ride_duration_for_different_start_and_end_station
FROM One_Year_Cyclistic_Data
WHERE start_station_name <> end_station_name
Group BY member_casual


