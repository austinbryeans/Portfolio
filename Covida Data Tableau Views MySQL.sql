
/*
Queries used for Tableau Project
*/

-- 1.
SELECT 
	SUM(new_cases) AS total_cases,
    SUM(new_deaths)AS total_deaths,
    (SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- 2. 

-- 

SELECT location, SUM(new_deaths) as total_death_count
FROM covid_deaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Low income', 'Upper middle income', 'Lower middle income')
GROUP BY location
ORDER BY total_death_count DESC;


-- 3. 

SELECT 
	location, 
	population,
    MAX(total_cases) AS total_infection_count,
    (MAX(total_cases/population))*100 AS infection_rate
FROM covid_deaths
GROUP BY location, population
ORDER BY infection_rate DESC;

-- 4.

SELECT 
	location, 
	population,
    date,
    MAX(total_cases) AS total_infection_count,
    (MAX(total_cases/population))*100 AS infection_rate
FROM covid_deaths
GROUP BY location, population, date
ORDER BY infection_rate DESC;