--SELECT
--	*
--	FROM PortfolioProject..CovidVaccinations$

--SELECT
--	iso_code,
--	continent,
--	count(new_tests) AS total_test
--	FROM PortfolioProject..CovidVaccinations$
--	GROUP BY iso_code, continent
--	HAVING continent IS NOT NULL
--	ORDER BY total_test DESC 

SELECT
	*
	FROM PortfolioProject..CovidDeaths$

SELECT
	LOCATION,
	COUNT(total_cases),
	COUNT(new_cases),
	COUNT(total_deaths)
	FROM PortfolioProject..CovidDeaths$
	GROUP BY location

SELECT
	location,
	date, 
	total_cases, 
	new_cases,
	total_deaths,
	population
	FROM PortfolioProject..CovidDeaths$
	ORDER BY 1,2

-- Total cases and total deaths -> Death Percentage

SELECT
	location,
	date, 
	total_cases, 
	total_deaths,
	ROUND((total_deaths/total_cases)*100,2) AS death_percentage
	FROM PortfolioProject..CovidDeaths$
	WHERE location LIKE '%states%'
	ORDER BY 1,2

-- Total Cases and Population
-- What is the percentage of population that contracted COVID

SELECT
	location,
	date,
	total_cases,
	population,
	(total_cases/population)*100 AS cases_per_population
	FROM PortfolioProject..CovidDeaths$
	WHERE location LIKE '%states%'
	ORDER BY 1,2

-- Look at the countries with the highest infection rate
-- Percentage of population that were infected with COVID

SELECT
	location,
	MAX(total_cases) AS infection_count,
	MAX(total_cases/population)*100 AS cases_per_population
	FROM PortfolioProject..CovidDeaths$
	GROUP BY location
	ORDER BY cases_per_population DESC

-- Countries with highest death count per population

SELECT
	location,
	MAX(cast(total_deaths AS BIGINT)) AS total_death_count
	FROM PortfolioProject..CovidDeaths$
	WHERE continent IS NOT NULL
	GROUP BY location
	ORDER BY total_death_count DESC
	
-- CONTINENT

SELECT
	continent,
	MAX(cast(total_deaths AS BIGINT)) AS total_death_count
	FROM PortfolioProject..CovidDeaths$
	WHERE continent IS NOT NULL
	GROUP BY continent
	ORDER BY total_death_count DESC
	
-- Global Numbers

SELECT
	date,
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS BIGINT)) AS deaths,
	(SUM(CAST(new_deaths AS BIGINT))/SUM(new_cases))*100 AS death_percentage
	FROM PortfolioProject..CovidDeaths$
	WHERE continent IS NOT NULL
	GROUP BY date
	ORDER BY 1,2 

-- Total WorldWide

SELECT
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS BIGINT)) AS deaths,
	(SUM(CAST(new_deaths AS BIGINT))/SUM(new_cases))*100 AS death_percentage
	FROM PortfolioProject..CovidDeaths$
	WHERE continent IS NOT NULL
	ORDER BY 1,2 

-- Total Population vs Total Vaccination


SELECT
	death.continent,
	death.location,
	death.date,
	death.population, 
	vaccination.new_vaccinations,
	SUM(CAST(vaccination.new_vaccinations AS BIGINT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPopulationVaccination
	FROM PortfolioProject..CovidDeaths$ AS death
	JOIN PortfolioProject..CovidVaccinations$ AS vaccination
	ON death.location = vaccination.location AND death.date = vaccination.date 
	WHERE death.continent IS NOT NULL 
	ORDER BY 2,3
	

-- Common Table Expression

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPopulationVaccination)
AS 
(
SELECT
	death.continent,
	death.location,
	death.date,
	death.population, 
	vaccination.new_vaccinations,
	SUM(CAST(vaccination.new_vaccinations AS BIGINT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPopulationVaccination
	FROM PortfolioProject..CovidDeaths$ AS death
	JOIN PortfolioProject..CovidVaccinations$ AS vaccination
	ON death.location = vaccination.location AND death.date = vaccination.date 
	WHERE death.continent IS NOT NULL
)

SELECT 
	*,
	(RollingPopulationVaccination/population)*100 AS population_vaccination
	FROM PopvsVac

