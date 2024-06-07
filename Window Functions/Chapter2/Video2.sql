--------------------------------------
-- LinkedIn Learning -----------------
-- Advanced SQL - Window Functions ---
-- Ami Levin 2020 --------------------
-- .\Code Demos\Chapter2\Video2.sql--
----------------------------------------------------------------------
-- Pay attention to the difference of the results they display--
-- out of 100 animal data observations, 75 hav admission date aft 2017-01-01--
-- so observe the number of rows and the number in col: number_of_animals--
---------------------------------------------------------------------------
-- OVER ()

-- 1: 100 rows--

SELECT 	species, 
		name, 
		primary_color, 
		admission_date
FROM 	animals
ORDER BY admission_date ASC; 

-- 2: 100 rows, 100 number_of_animals--

SELECT 	species, 
		name, 
		primary_color, 
		admission_date,
		(	SELECT COUNT (*) -- count #animals and put in a new column
			FROM animals
		) AS number_of_animals -- each row will have same # in this column (not desired)
FROM 	animals
ORDER BY admission_date ASC;

--3: 100 rows, 100 number_of_animals--

SELECT 	species, 
		name, 
		primary_color, 
		admission_date,
	-- window function: perform calculations on a set of rows
		COUNT (*)  -- "COUNT(*) OVER ()" AS: window function
		OVER () AS number_of_animals -- "OVER()" == "FROM animals"
FROM 	animals
ORDER BY admission_date ASC;

-- FILTER

-- 4: 100 rows, 75 number_of_animals--

SELECT 	species, 
		name, 
		primary_color, 
		admission_date,
		(	SELECT 	COUNT (*) 
			FROM 	animals
			WHERE 	admission_date >= '2017-01-01'
		) AS number_of_animals -- all rows same # in this col
FROM 	animals
ORDER BY admission_date ASC;

-- 5: 75 rows, 75 number_of_animals--

SELECT 	species, 
		name, 
		primary_color, 
		admission_date,
		(	SELECT 	COUNT (*) 
			FROM 	animals
			WHERE 	admission_date >= '2017-01-01'
		) AS number_of_animals
FROM 	animals
WHERE 	admission_date >= '2017-01-01'
ORDER BY admission_date ASC;

-- 6: 100 rows, 75 number_of_animals--

SELECT 	species, 
		name, 
		primary_color, 
		admission_date,
		COUNT (*) 
		FILTER (WHERE admission_date >= '2017-01-01')
		OVER () AS number_of_animals
FROM 	animals
ORDER BY admission_date ASC;

-- 7: 75 rows, 75 number_of_animals (not 100) -- 
SELECT 	species,
		name, 
		primary_color, 
		admission_date,
		COUNT (*)
		OVER () AS number_of_animals -- number = 75 not 100
FROM 	animals	
WHERE 	admission_date >= '2017-01-01' -- defines the rows to include: hence the scope of this query is 75
ORDER BY admission_date ASC;
