/* Covid 19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
Data Source: https://ourworldindata.org/covid-deaths
*/

SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- Select Data that we are going to be using

SELECT 
	location, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population
FROM covid_deaths
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT 
	location, 
    date, 
    total_cases, 
    total_deaths,
    (total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths
-- WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Looking at Total Cases vs Total Population
-- Shows what percentage of population got covid
SELECT 
	location, 
    date, 
	population,
    total_cases, 
    (total_cases/population)*100 AS infection_rate
FROM covid_deaths
ORDER BY 1,2;

-- Looking at countries with Highest Infection Rate compared to Population
SELECT 
	location, 
	population,
    MAX(total_cases) AS total_infection_count,
    (MAX(total_cases/population))*100 AS infection_rate
FROM covid_deaths
GROUP BY 1,2
ORDER BY 4 DESC;

-- SHowing Countries with Highest Death Count per Population
SELECT 
	location, 
    MAX(total_deaths) AS total_death_count,
    (MAX(total_deaths/population))*100 AS death_rate
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY total_death_count DESC;

-- BREAKDOWN BY CONTINENT

-- Showing continents with highest death count per population

SELECT 
	continent, 
    MAX(total_deaths) AS total_death_count,
    (MAX(total_deaths/population))*100 AS death_rate
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- GLOBAL NUMBERS

SELECT 
-- 	date,
	SUM(new_cases) AS total_cases,
    SUM(new_deaths)AS total_deaths,
    (SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2;

-- Looking at Total Population vs Vaccinations

SELECT 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccines_given
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- USING CTE to perform calculation on partition by from previous query

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_vaccines_given)
AS (
SELECT 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccines_given
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
)
SELECT 
	*,
    (rolling_vaccines_given/population)*100 AS rolling_percentage_vaccines_given_over_population
FROM pop_vs_vac;

-- USING temp_table instead of CTE

DROP TABLE IF EXISTS percent_population_vaccinated;
CREATE TABLE percent_population_vaccinated
(
continent TEXT,
location TEXT, 
date DATETIME, 
population INT, 
new_vaccinations INT, 
rolling_vaccines_given INT
)
AS 
SELECT 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccines_given
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

SELECT 
	*,
    (rolling_vaccines_given/population)*100 AS rolling_percentage_vaccines_given_over_population
FROM percent_population_vaccinated;

-- Creating view to store data for later visualizations 

CREATE VIEW percent_population_vaccinated_view
AS 
SELECT 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccines_given
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

