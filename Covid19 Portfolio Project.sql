SELECT * 
FROM ['Covid Deaths$']
ORDER BY 3,4

SELECT * 
FROM ['Covid Vaccination$']
ORDER BY 3,4


SELECT location, date, total_cases,new_cases, total_deaths, population
FROM ['Covid Deaths$']
ORDER BY 1,2



--Total Cases vs Total Deaths
--Shows the Likelyhood of dying if a person is affected by Covid based on Country 

SELECT location, date, total_cases, total_deaths , (total_deaths/total_cases)*100 AS DeathPercentage
FROM ['Covid Deaths$']
WHERE location LIKE ('%States%')
ORDER BY 1,2


-- Total Cases vs Population
-- Percanetage of Population that got Covid 

SELECT location, date, population,total_cases, (total_cases/population)*100 AS PercentOfPopulationInfected
FROM ['Covid Deaths$']
-- WHERE location LIKE ('%States%')
ORDER BY 1,2

-- Countries with Highest Infection Rate by population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercecntOfPopulationInfected
FROM ['Covid Deaths$']
-- WHERE location LIKE ('%States%')
GROUP BY location, population
ORDER BY PercecntOfPopulationInfected DESC



-- Countries with the Highest Death Count 

SELECT location, population, MAX(CAST(total_deaths AS INT)) as TotalDeathCount --, MAX((total_deaths/population))*100 AS PercecntOfPopulationInfected
FROM ['Covid Deaths$']
-- WHERE location LIKE ('%States%')
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

-- Death Count in Continent

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount 
FROM ['Covid Deaths$']
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM (CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST (new_deaths AS INt))/SUM(new_cases)*100 AS DeathPercentage
FROM ['Covid Deaths$']
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 


-- Total Numbers
SELECT SUM(new_cases) as total_cases, SUM (CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST (new_deaths AS INt))/SUM(new_cases)*100 AS DeathPercentage
FROM ['Covid Deaths$']
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2 



--   JOIN COVID DEATH DATA WITH VACCINE DATA 


-- Total Population vs Vaccination

WITH PopVsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated) AS

(SELECT dea.continent, dea.location, dea.date, dea.population, CONVERt(INT,vac.new_vaccinations), 
SUM(CONVERT (INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollinPeopleVaccinated
FROM ['Covid Deaths$'] dea
JOIN ['Covid Vaccination$'] vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

)

SELECT *, (RollingPeopleVaccinated/Population)*100 as PopulationVaccinationPercentage
FROM PopVsVac
ORDER BY 2,3


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, CONVERT (INT,vac.new_vaccinations), 
SUM(CONVERT (INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM ['Covid Deaths$'] dea
JOIN ['Covid Vaccination$'] vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated
ORDER BY 2,3

-- Creating View to Store Data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
	SELECT dea.continent, dea.location, dea.date, dea.population, CONVERT (INT,vac.new_vaccinations) as New_Vaccinatuions, 
	SUM(CONVERT (INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM ['Covid Deaths$'] dea
	JOIN ['Covid Vaccination$'] vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL

SELECT * 
FROM PercentPopulationVaccinated
