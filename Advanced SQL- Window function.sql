---- Count up-to-previous day number of animals of the same species
-- using subqueries
SELECT 	a1.species, 
	a1.name, 
	a1.primary_color, 
	a1.admission_date,
	(	SELECT 	COUNT (*) 
		FROM 	animals AS a2
		WHERE 	a2.species = a1.species
				AND
				a2.admission_date < a1.admission_date
	) AS up_to_previous_day_species_animals
FROM 	animals AS a1
ORDER BY 	a1.species ASC,
		a1.admission_date ASC;
		
---- Count up-to-previous day number of animals of the same species
-- using Window function
SELECT species, 
		name, 
		primary_color, 
		admission_date,
		COUNT (*) 
		OVER(PARTITION BY species
			ORDER BY  admission_date ASC
			ROWS BETWEEN UNBOUNDED PRECEDING
			AND
			1 PRECEDING
			) AS up_to_previous_day
FROM animals
ORDER BY species ASC,
		admission_date ASC;
		
-- admitted more than 1 animal in the same day
SELECT species, admission_date, COUNT(*)
FROM animals
GROUP BY species, admission_date
HAVING COUNT(*) > 1;

--taking care of this day that 2 animals were addopted
--we use range instead of rows to have an order in species adopted in same day
SELECT species, 
		name, 
		primary_color, 
		admission_date,
		COUNT (*) 
		OVER(PARTITION BY species
			ORDER BY  admission_date ASC
			RANGE BETWEEN UNBOUNDED PRECEDING
			AND
			'1 day' PRECEDING
			) AS up_to_previous_day
FROM animals
ORDER BY species ASC,
		admission_date ASC;
		
--The earliest admission date of all animals whose names have a dictionary sort order that is lower than the current animal's name.
SELECT MIN(admission_date) OVER (ORDER BY name ASC GROUPS BETWEEN UNBOUNDED PRECEDING and 1 PRECEDING)
FROM animals;

--The earliest admission date of all animals whose names have a dictionary sort order that is lower than the current animal's name. Animals with the same name will be sorted arbitrarily.
SELECT MIN(admission_date) OVER (ORDER BY name ASC ROWS BETWEEN UNBOUNDED PRECEDING and 1 PRECEDING)
FROM animals;

--SELECT MIN(admission_date) OVER (PARTITION BY species ORDER BY birth_date DESC)
FROM animals;
SELECT MIN(admission_date) OVER (PARTITION BY species ORDER BY birth_date DESC)
FROM animals;

-- Routine Checkups
SELECT 	*
FROM routine_checkups;

--write a query that shows animal's species, name, check up time and heart rate. 
--It should also include the Boolean column that evaluates to true for animals
--which every one of their heart rate measurements was either equal to, or larger
--than the average heart rate for their species. 
-- Split with CTE
WITH species_average_heart_rates
AS
(SELECT species,
		name, 
		checkup_time, 
		heart_rate, 
		CAST (AVG (heart_rate) 
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

-- Separate into CTEs
WITH species_average_heart_rates
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
		EVERY (heart_rate >= species_average_heart_rate) 
		OVER (PARTITION BY species, name) AS consistently_at_or_above_average
FROM 	species_average_heart_rates
)
SELECT 	DISTINCT species,
		name,
		heart_rate,
		species_average_heart_rate
FROM 	with_consistently_at_or_above_average_indicator
WHERE 	consistently_at_or_above_average
ORDER BY 	species ASC,
			heart_rate DESC;
			
--/* Create a query to report monthly adoption fees revenue.
-- The query needs to show every month and every year with adoptions, 
-- the total monthly adoption fees and the percent of 
-- this month's revenue from the total annual revenue for the same year. */
WITH monthly_grouped_adoptions AS
(	SELECT DATE_PART ('year', adoption_date) AS year,
			DATE_PART ('month', adoption_date) AS month,
			SUM (adoption_fee) AS month_total
	FROM 	adoptions
	GROUP BY 	DATE_PART ('year', adoption_date), 
				DATE_PART ('month', adoption_date))
SELECT 	*,
		CAST 	(100 * month_total 
				 / 	SUM (month_total) 
					OVER (PARTITION BY year) 
				AS DECIMAL (5, 2)
				) AS annual_percent
FROM 	monthly_grouped_adoptions
ORDER BY 	year ASC, month ASC;

/* 
----------------------------------------------------
-- Warm up challenge - Annual vaccinations report --
----------------------------------------------------

Write a query that returns all years in which animals were vaccinated, and the total number of vaccinations given that year.
In addition, the following two columns should be included in the results:
1. The average number of vaccinations given in the previous two years.
2. The percent difference between the current year's number of vaccinations, and the average of the previous two years.
For the first year, return a NULL for both additional columns.

Hint: Cast averages and division expressions to DECIMAL (5, 2)

Expected result sorted by year ASC:
---------------------------------------------------------------------------------------------
|	year	|	number_of_vaccinations	|	previous_2_years_average	|	percent_change	|
|-----------|---------------------------|-------------------------------|-------------------|
|	2,016	|					11		|					[NULL]		|		[NULL]		|
|	2,017	|					23		|					11.00		|		209.09		|
|	2,018	|					32		|					17.00		|		188.24		|
|	2,019	|					29		|					27.50		|		105.45		|
---------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
-- Extra challenge: Try to find an alternative solution and post it in the Q&A section. ----------------------
-- Solutions that either perform better, are simpler, or highly creative, will receive an honorary mention. --
--------------------------------------------------------------------------------------------------------------
*/

WITH annual_vaccinations
AS
(
SELECT	CAST (DATE_PART ('year', vaccination_time) AS INT) AS year,
		COUNT (*) AS number_of_vaccinations
FROM 	vaccinations
GROUP BY DATE_PART ('year', vaccination_time)
)
-- SELECT * FROM annual_vaccinations ORDER BY year; -- Uncomment to execute preceding CTE
,annual_vaccinations_with_previous_2_year_average
AS
(
SELECT 	*,
		CAST (AVG (number_of_vaccinations) 
			   OVER (ORDER BY year ASC
					 RANGE BETWEEN 2 PRECEDING AND 1 PRECEDING 
					 -- Watch out for frame type...
					) 
			AS DECIMAL (5, 2)
			 )
		AS previous_2_years_average
FROM 	annual_vaccinations
-- WHERE year <> 2018 -- remove comment to check difference between ROWS and RANGE above
)
-- SELECT * FROM annual_vaccinations_with_previous_2_year_average ORDER BY year;
SELECT 	*,
		CAST ((100 * number_of_vaccinations / previous_2_years_average) 
			 AS DECIMAL (5, 2)
			 ) AS percent_change
FROM 	annual_vaccinations_with_previous_2_year_average
ORDER BY year ASC;

/*
------------------------------------------
-- Animals temperature exception report --
------------------------------------------

Write a query that returns the top 25% of animals per species that had the fewest “temperature exceptions”.
Ignore animals that had no routine checkups.
A “temperature exception” is a checkup temperature measurement that is either equal to or exceeds +/- 0.5% from the specie's average.
If two or more animals of the same species have the same number of temperature exceptions, those with the more recent exceptions should be returned.
There is no need to return additional tied animals over the 25% mark.
If the number of animals for a species does not divide by 4 without remainder, you may return 1 more animal, but not less.

Hint: CAST averages to DECIMAL (5, 2).

Expected results sorted by species ASC, number_of_exceptions DESC, latest_exception DESC:
---------------------------------------------------------------------------------
|	species	|	name		|	number_of_exceptions	|	latest_exception	|
|-----------|---------------|---------------------------|-----------------------|
|	Cat		|	Cleo		|					1		|	2019-09-20 09:45:00	|
|	Cat		|	Cosmo		|					0		|				[NULL]	|
|	Cat		|	Kiki		|					0		|				[NULL]	|
|	Cat		|	Penny		|					0		|				[NULL]	|
|	Cat		|	Patches		|					0		|				[NULL]	|
|	Dog		|	Gizmo		|					1		|	2019-10-07 08:51:00	|
|	Dog		|	Riley		|					1		|	2019-07-25 10:48:00	|
|	Dog		|	Mocha		|					1		|	2019-05-14 11:10:00	|
|	Dog		|	Emma		|					1		|	2019-05-07 11:09:00	|
|	Dog		|	Samson		|					1		|	2019-03-27 09:04:00	|
|	Dog		|	Bailey		|					0		|				[NULL]	|
|	Dog		|	Luke		|					0		|				[NULL]	|
|	Dog		|	Benny		|					0		|				[NULL]	|
|	Dog		|	Boomer		|					0		|				[NULL]	|
|	Dog		|	Rusty		|					0		|				[NULL]	|
|	Dog		|	Millie		|					0		|				[NULL]	|
|	Dog		|	Beau		|					0		|				[NULL]	|
|	Rabbit	|	Humphrey	|					1		|	2018-12-19 08:32:00	|
|	Rabbit	|	April		|					0		|				[NULL]	|
---------------------------------------------------------------------------------
*/


WITH checkups_with_temperature_differences
AS
(
SELECT 	species,
		name,
		temperature,
		checkup_time,
		CAST ( 	AVG (temperature) 
				OVER (PARTITION BY species) 
			 	AS DECIMAL (5,2)
			 ) AS species_average_temperature,
		CAST (	temperature - 	AVG (temperature) 
								OVER (PARTITION BY species)
			 	AS DECIMAL (5, 2) 
			 ) AS difference_from_average
FROM 	routine_checkups
)
-- SELECT * FROM checkups_with_temperature_differences ORDER BY species, difference_from_average;
,temperature_differences_with_exception_indicator
AS
(
SELECT	*,
		CASE 
		WHEN ABS (difference_from_average / species_average_temperature) >= 0.005
			THEN 1
		ELSE 0
		END AS is_temperature_exception
FROM 	checkups_with_temperature_differences
)
-- SELECT * FROM temperature_differences_with_exception_indicator ORDER BY species, difference_from_average;
,grouped_animals_with_exceptions
AS 
(
SELECT	species,
		name,
		SUM (is_temperature_exception) AS number_of_exceptions,
		MAX (	CASE 
				WHEN is_temperature_exception = 1 
					THEN checkup_time
				ELSE NULL
				END
			) AS latest_exception
FROM 	temperature_differences_with_exception_indicator
GROUP BY 	species,
			name
)
-- SELECT * FROM grouped_animals_with_exceptions ORDER BY species, number_of_exceptions;
,animal_exceptions_with_ntile
AS
(
SELECT 	*,
		NTILE (4)
		OVER (	PARTITION BY species 
				ORDER BY number_of_exceptions ASC, -- try DESC,
						 latest_exception DESC -- try ASC
			 ) AS ntile
FROM 	grouped_animals_with_exceptions
)
-- SELECT * FROM animal_exceptions_with_ntile ORDER BY species, number_of_exceptions, latest_exception DESC;
SELECT 	species,
		name,
		number_of_exceptions,
		latest_exception
FROM 	animal_exceptions_with_ntile
WHERE 	ntile = 1 -- try 4
ORDER BY 	species ASC,
			number_of_exceptions DESC,
			latest_exception DESC;


-----------------		
-- Alternative --
-----------------
-- Using a grouped derived table instead of an aggregate window function
WITH checkups_with_temperature_differences
AS
(
SELECT 	rc.species,
		name,
		temperature,
		checkup_time,
		species_average_temperature,
		(temperature - species_average_temperature) AS difference_from_average
FROM 	routine_checkups AS rc
		INNER JOIN
		(	SELECT	species,
					CAST ( AVG (temperature) AS DECIMAL (5, 2)) AS species_average_temperature
			FROM 	routine_checkups
			GROUP BY species
		) AS at -- Average Temperatures
			ON rc.species = at.species
)	
-- SELECT * FROM checkups_with_temperature_differences ORDER BY species, difference_from_average;
-- Using CROSS JOIN LATERAL instead of a SELECT expression.
-- Very useful in many cases, remember this one.
,temperature_differences_with_exception_indicator
AS
(
SELECT	*
FROM 	checkups_with_temperature_differences AS cw
		CROSS JOIN LATERAL
		(	VALUES (	CASE 
						WHEN ABS (cw.difference_from_average / cw.species_average_temperature) >= 0.005
							THEN TRUE
						ELSE NULL
						END
					)
		) AS exceptions (is_temperature_exception)
)
-- SELECT * FROM temperature_differences_with_exception_indicator ORDER BY species, difference_from_average;
,grouped_animals_with_exceptions
AS 
(
SELECT	species,
		name,
		COUNT (is_temperature_exception) AS number_of_exceptions,
		-- Count of Booleans - remember this trick too.
		MAX (	CASE 
				WHEN is_temperature_exception
					THEN checkup_time
				ELSE NULL
				END
			) AS latest_exception
FROM 	temperature_differences_with_exception_indicator
GROUP BY 	species,
			name
)
-- SELECT * FROM grouped_animals_with_exceptions ORDER BY species, number_of_exceptions;
,animal_exceptions_with_ranking
AS
(
SELECT 	*,
		PERCENT_RANK()
		OVER (	PARTITION BY species 
				ORDER BY number_of_exceptions ASC,
						 latest_exception DESC
			 ) AS rank
FROM 	grouped_animals_with_exceptions
)
-- SELECT * FROM animal_exceptions_with_ntile ORDER BY species, number_of_exceptions, latest_exception DESC;
SELECT 	species,
		name,
		number_of_exceptions,
		latest_exception
FROM 	animal_exceptions_with_ranking
WHERE 	rank <= 0.25
		-- Do you think this solution complies with the challenge requirements?
		-- If not, can you think of a situation where it will fail?
ORDER BY 	species ASC,
			number_of_exceptions DESC,
			latest_exception DESC;
			
			
/*
------------------------------------
-- Top improved adoption quarters --
------------------------------------

Write a query that returns the top 5 most improved quarters in terms of the number of adoptions, both per species, and overall.
Improvement means the increase in number of adoptions compared to the previous calendar quarter.
The first quarter in which animals were adopted for each species and for all species, does not constitute an improvement from zero, and should be treated as no improvement.
In case there are quarters that are tied in terms of adoption improvement, return the most recent ones.

Hint: Quarters can be identified by their first day.
Expected results sorted by species ASC, adoption_difference_from_previous_quarter DESC and quarter_start ASC:
---------------------------------------------------------------------------------------------------------------------
|	species			|	year	|	quarter	|	adoption_difference_from_previous_quarter	|	quarterly_adoptions	|
|-------------------|-----------|-----------|-----------------------------------------------|-----------------------|
|	All species		|	2019	|		3	|										7		|				11		|
|	All species		|	2018	|		2	|										4		|				8		|
|	All species		|	2019	|		4	|										3		|				14		|
|	All species		|	2017	|		3	|										2		|				3		|
|	All species		|	2018	|		1	|										2		|				4		|
|	Cat				|	2019	|		4	|										4		|				6		|
|	Cat				|	2018	|		3	|										2		|				3		|
|	Cat				|	2019	|		2	|										2		|				2		|
|	Cat				|	2018	|		1	|										1		|				2		|
|	Cat				|	2019	|		3	|										0		|				2		|
|	Dog				|	2019	|		3	|										7		|				8		|
|	Dog				|	2018	|		2	|										4		|				6		|
|	Dog				|	2017	|		3	|										2		|				2		|
|	Dog				|	2018	|		1	|										2		|				2		|
|	Dog				|	2019	|		1	|										1		|				4		|
|	Rabbit			|	2019	|		1	|										2		|				2		|
|	Rabbit			|	2017	|		4	|										1		|				1		|
|	Rabbit			|	2018	|		2	|										1		|				1		|
|	Rabbit			|	2019	|		4	|										1		|				2		|
|	Rabbit			|	2019	|		3	|										0		|				1		|
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*/


SELECT 	EXTRACT('quarter' FROM CURRENT_TIMESTAMP),
		EXTRACT('year' FROM CURRENT_TIMESTAMP);

WITH adoption_quarters
AS
(
SELECT 	Species,
		MAKE_DATE (	CAST (DATE_PART ('year', adoption_date) AS INT),
					CASE 
						WHEN DATE_PART ('month', adoption_date) < 4
							THEN 1
						WHEN DATE_PART ('month', adoption_date) BETWEEN 4 AND 6
							THEN 4
						WHEN DATE_PART ('month', adoption_date) BETWEEN 7 AND 9
							THEN 7
						WHEN DATE_PART ('month', adoption_date) > 9
							THEN 10
					END,
					1
				 ) AS quarter_start
FROM 	adoptions
)
-- SELECT * FROM adoption_quarters ORDER BY species, quarter_start;
,quarterly_adoptions
AS
(
SELECT 	COALESCE (species, 'All species') AS species,
		quarter_start,
		COUNT (*) AS quarterly_adoptions,
		COUNT (*) - COALESCE (
					-- For quarters with no previous adoptions use 0, not NULL 
							 	FIRST_VALUE (COUNT (*))
							 	OVER (PARTITION BY species
							 		  ORDER BY quarter_start ASC
								   	  RANGE BETWEEN 	INTERVAL '3 months' PRECEDING 
														AND 
														INTERVAL '3 months' PRECEDING
						 			 )
							, 0)
		AS adoption_difference_from_previous_quarter,
-- 		COUNT (*) OVER (PARTITION BY quarter_start) AS quarter_total_all_species, -- use with GROUP BY quarter_start, species
		CASE 	
			WHEN	quarter_start =	FIRST_VALUE (quarter_start) 
									OVER (PARTITION BY species
										  ORDER BY quarter_start ASC
										  RANGE BETWEEN 	UNBOUNDED PRECEDING
															AND
															UNBOUNDED FOLLOWING
										 )
			THEN 	0
			ELSE 	NULL
		END 	AS zero_for_first_quarter
FROM 	adoption_quarters
GROUP BY	GROUPING SETS 	((quarter_start, species), 
							 (quarter_start)
							)
)
-- SELECT * FROM quarterly_adoptions ORDER BY species, quarter_start;
,quarterly_adoptions_with_rank
AS
(
SELECT 	*,
		RANK ()
		OVER (	PARTITION BY species
				ORDER BY 	COALESCE (zero_for_first_quarter, adoption_difference_from_previous_quarter) DESC,
							-- First quarters are 0, all others NULL
							quarter_start DESC)
		AS quarter_rank
FROM 	quarterly_adoptions
)
-- SELECT * FROM quarterly_adoptions_with_rank ORDER BY species, quarter_rank, quarter_start;
SELECT 	species,
		CAST (DATE_PART ('year', quarter_start) AS INT) AS year,
		CAST (DATE_PART ('quarter', quarter_start) AS INT) AS quarter,
		adoption_difference_from_previous_quarter,
		quarterly_adoptions
FROM 	quarterly_adoptions_with_rank
WHERE 	quarter_rank <= 5
ORDER BY 	species ASC,
			adoption_difference_from_previous_quarter DESC,
			quarter_start ASC;

/* 
---------------------------------------------------------------------------------------
-- Triple bonus points challenge - Annual average animal species vaccinations report --
---------------------------------------------------------------------------------------
-- !!! DISCLAIMER !!! This one is far from trivial, so be patient and careful. --------
---------------------------------------------------------------------------------------
Write a query that returns all years in which animals were vaccinated, and the total number of vaccinations given that year, per species.
In addition, the following three columns should be included in the results:
1. The average number of vaccinations per shelter animal of that species in that year.
2. The average number of vaccinations per shelter animal of that species in the previous 2 years.
3. The percent difference between columns 1 and 2 above.

----------------
-- Guidelines --
----------------

1. The average number of animals in any given year should take into account when animals were admitted, and when they were adopted.
To simplify the solution, it should be done on a yearly resolution.
This means that you should consider an animal that was admitted on any date as if it was admitted on January 1st of that year.
Similarly, consider an animal that was adopted on any date as if it was adopted on January 1st of that year.
For example - If in 2016, the first year, 10 cats and 5 dogs were admitted, and 2 cats and 2 dogs were adopted, consider the number of shelter animals for 2016 to be 8 cats, 3 dogs and 0 rabbits.
This carries over to the next year for which you will need to add admissions, subtract adoptions, and so on.
Of course, if you want to calculate this on a daily basis and only then average it out for the year, you are welcome to do so for extra bonus points.
My suggested solution does not.

2. Consider that there may be years without adoptions or without admissions for any species.
You may assume that there are no years without both adoptions and admissions for a species.
For my suggested solution it does not matter, but it may for others.

3. There may also be years without vaccinations for any species, but you are not required to show them.

Recommendation: Cast averages and expressions with division operators to DECIMAL (5, 2)
Expected result sorted by species ASC, year ASC:

--------------------------------------------------------------------------------------------------------------------------------------------
|	species	|	year	|	number_of_vaccinations	|	average_vaccinations_per_animal	|	previous_2_years_average	|	percent_change |
|-----------|-----------|---------------------------|-------------------------------------------------------------------|------------------|
|	Cat		|	2016	|					2		|							0.5		|					[NULL]		|		[NULL]     |
|	Cat		|	2017	|					7		|							0.78	|					0.5			|		156        |
|	Cat		|	2018	|					9		|							1.29	|					0.64		|		201.56     |
|	Cat		|	2019	|					10		|							1.25	|					1.04		|		120.19     |
|	Dog		|	2016	|					7		|							0.44	|					[NULL]		|		[NULL]     |
|	Dog		|	2017	|					15		|							0.56	|					0.44		|		127.27     |
|	Dog		|	2018	|					18		|							0.6		|					0.5			|		120        |
|	Dog		|	2019	|					17		|							0.85	|					0.58		|		146.55     |
|	Rabbit	|	2016	|					2		|							1		|					[NULL]		|		[NULL]     |
|	Rabbit	|	2017	|					1		|							0.2		|					1			|		20         |
|	Rabbit	|	2018	|					5		|							1		|					0.6			|		166.67     |
|	Rabbit	|	2019	|					2		|							1		|					0.6			|		166.67     |
--------------------------------------------------------------------------------------------------------------------------------------------

*/


WITH annual_admitted_animals
AS
(
SELECT	species,
		DATE_PART ('year', admission_date) AS year,
		COUNT(*) AS admitted_animals
FROM 	animals
GROUP BY 	species,
			DATE_PART ('year', admission_date)
)
-- SELECT * FROM annual_admitted_animals ORDER BY species, admission_year;
,annual_adopted_animals
AS
(
SELECT	species,
		DATE_PART ('year', adoption_date) AS year,
		COUNT(*) AS adopted_animals
FROM 	adoptions AS a
GROUP BY 	species,
			DATE_PART ('year', adoption_date)
)
-- SELECT * FROM annual_adopted_animals ORDER BY species, adoption_year;
,annual_number_of_shelter_species_animals
AS
(
SELECT 	COALESCE (adm.year, ado.year) AS year,
		COALESCE (adm.species, ado.species) AS species,
		adm.admitted_animals,
		ado.adopted_animals,
		-- Above 2 columns not needed for solution, leaving for clarity
		COALESCE (	SUM (admitted_animals)
					OVER W
				 , 0
				 )
		-
		COALESCE (	SUM (adopted_animals)
					OVER W
				 , 0
				 )
		AS number_of_animals_in_shelter
FROM 	annual_admitted_animals AS adm
		FULL OUTER JOIN 
		-- We need to accommodate years without adoptions and years without admissions
		-- If there was a year without either, then the number of animals remains the same
		annual_adopted_animals AS ado
			ON 	adm.species = ado.species
				AND
				adm.year = ado.year
WINDOW W AS ( PARTITION BY COALESCE (adm.species, ado.species)
			  ORDER BY COALESCE (adm.year, ado.year) ASC
			  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
			  -- We can use either RANGE or ROWS since year is unique within a species partition, 
			  -- and the frame is unbounded preceding to current row
			 )
)
-- SELECT * FROM annual_number_of_shelter_species_animals ORDER BY species, year;
,annual_vaccinations
AS
(
SELECT	species,
		DATE_PART ('year', vaccination_time) AS year,
		COUNT (*) AS number_of_vaccinations
FROM 	vaccinations
GROUP BY 	species,
			DATE_PART ('year', vaccination_time)
)
-- SELECT * FROM annual_vaccinations ORDER BY species, year;
,annual_average_vaccinations_per_animal
AS
(
SELECT 	av.species,
		av.year,
		av.number_of_vaccinations,
		CAST ( 
				(number_of_vaccinations / number_of_animals_in_shelter) 
			 AS DECIMAL (5, 2)
			 ) AS average_vaccinations_per_animal
FROM 	annual_vaccinations AS av
		LEFT OUTER JOIN
		-- Requirements state we need to show only years where animals were vaccinated so a LEFT join is enough
		annual_number_of_shelter_species_animals AS an 
			ON 	an.species = av.species
				AND 
				an.YEAR = av.year
)
-- SELECT * FROM annual_average_vaccinations_per_animal ORDER BY species, year;
,annual_average_vaccinations_per_animal_with_previous_2_years_average
AS 
(
SELECT 	*,
		CAST ( AVG (average_vaccinations_per_animal) 
			   OVER ( PARTITION BY species
			   		  ORDER BY year ASC
					  RANGE BETWEEN 2 PRECEDING AND 1 PRECEDING 
						-- Watch out for frame type...
					 ) 
				AS DECIMAL (5, 2)
			)
		AS previous_2_years_average
FROM 	annual_average_vaccinations_per_animal
)
SELECT 	*,
		CAST ( (100 * average_vaccinations_per_animal / previous_2_years_average) 
			 AS DECIMAL (5, 2)
			 ) AS percent_change
FROM 	annual_average_vaccinations_per_animal_with_previous_2_years_average
ORDER BY 	species ASC,
			year ASC
			
			
11/12/2023 Mehrnoosh Hasanzade			
