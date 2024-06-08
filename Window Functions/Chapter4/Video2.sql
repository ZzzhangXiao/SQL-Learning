--------------------------------------
-- LinkedIn Learning -----------------
-- Advanced SQL - Window Functions ---
-- Ami Levin 2020 --------------------
-- .\Code Demos\Chapter4\Video2.sql --
--------------------------------------

-- Routine Checkups
SELECT 	*
FROM	routine_checkups;

-- Average species heart rates
-- CAST: convert the result of AVG to "AS DECIMAL --
-- (5,2): 5 digits(left + right of dp), 2 scale (2dp) --
SELECT 	species, 
		name,
		checkup_time, 
		heart_rate,
		CAST ( 
				AVG (heart_rate) 
				OVER (PARTITION BY species)
			 AS DECIMAL (5, 2)
			 ) AS species_average_heart_rate
FROM	routine_checkups
ORDER BY 	species ASC,
			checkup_time ASC;

-- Nesting attempt
SELECT 	species, 
		name, 
		checkup_time, 
		heart_rate,
		EVERY (Heart_rate >= 	AVG (heart_rate)  -- cannot nest window function
								OVER (PARTITION BY species)
				) 
		OVER (PARTITION BY species, name) AS consistently_at_or_above_average
FROM	routine_checkups
ORDER BY 	species ASC,
			checkup_time ASC;

-- Split with CTE: CTE creates a temporary set of table can be used in other SELECT --
-- Example -- 
-- WITH sample_cte 
-- AS (
-- SELECT 
--    	column1, 
-- 	column2 
-- FROM 
--	your_table
-- WHERE 
-- 	condition = 'something'
-- )
-- SELECT 
-- 	column1, 
-- 	column2
-- FROM 
-- 	sample_cte;

WITH species_average_heart_rates
AS
(
SELECT 	species,
		name, 
		checkup_time, 
		heart_rate, 
		CAST (
					AVG (heart_rate) 
					OVER (PARTITION BY species) 
				AS DECIMAL (5, 2)
			 ) AS species_average_heart_rate
FROM	routine_checkups
)
SELECT	species,
		name, 
		checkup_time, 
		heart_rate,
		EVERY (heart_rate >= species_average_heart_rate) 
		OVER (PARTITION BY species, name) AS consistently_at_or_above_average
FROM 	species_average_heart_rates
ORDER BY 	species ASC,
			checkup_time ASC;

-- Use as filter attempt
WITH species_average_heart_rates
AS
(
SELECT 	species, 
		name, 
		checkup_time, 
		heart_rate, 
		AVG (heart_rate) 
		OVER (PARTITION BY species) AS species_average_heart_rate
FROM	routine_checkups
)
SELECT	species, 
		name, 
		checkup_time, 
		heart_rate
FROM 	species_average_heart_rates
WHERE 	EVERY (heart_rate >= species_average_heart_rate) 
		OVER (PARTITION BY species, name)
ORDER BY 	species ASC,
			checkup_time ASC;

-- !!!!! Separate into CTEs
WITH species_average_heart_rates -- first CTE
AS
(
SELECT 	species, 
		name, 
		checkup_time, 
		heart_rate, 
		CAST (	AVG (heart_rate) 
				OVER (PARTITION BY species) 
			 AS DECIMAL (5, 2)
			 ) AS species_average_heart_rate
FROM	routine_checkups
),
with_consistently_at_or_above_average_indicator
AS
(
SELECT	species, 
		name, 
		checkup_time, 
		heart_rate,
		species_average_heart_rate,
		EVERY (heart_rate >= species_average_heart_rate) -- after splitting to CTE, avoid the issue of cannot nest AVG in this window function
		OVER (PARTITION BY species, name) AS consistently_at_or_above_average
FROM 	species_average_heart_rates
)
SELECT 	DISTINCT species, -- unique combination of all columns specified here
		name,
		heart_rate,
		species_average_heart_rate
FROM 	with_consistently_at_or_above_average_indicator -- can refer to the defined CTE here
WHERE 	consistently_at_or_above_average
ORDER BY 	species ASC,
			heart_rate DESC;

