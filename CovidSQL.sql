SELECT *
FROM Portfolio..CovidDeaths
WHERE continent is not null
ORDER BY 3,4
SELECT *
FROM Portfolio..CovidVaccinations
ORDER BY 3,4
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..CovidDeaths
ORDER BY 1,2

-- Percentage of Total Death in The Philippines
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM Portfolio..CovidDeaths
WHERE location like '%Ph%'
ORDER BY 1,2

-- Total Cases vs Population
-- Total Population got Covid in The Philippines
SELECT location, date, total_cases, population, (total_cases/population)*100 as Cases_Percentage
FROM Portfolio..CovidDeaths
--WHERE location like '%Ph%'
ORDER BY 1,2

--Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Portfolio..CovidDeaths
--WHERE location like '%Ph%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Countries with Highest Death Count compared to Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Continent with Highest Death Count compared to Population
--Showing the continents with highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio..CovidDeaths
--WHERE location like '%Ph%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Total Vaccination and Population
WITH PopVsVac (continent, location, date, population, new_vacciations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER BY dea.location) 
as RollingPeopleVaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT * ,(RollingPeopleVaccinated/Population)*100
FROM PopVsVac


-- Temporary Table
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location) 
as RollingPeopleVaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * ,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Create view for Visualization

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location) 
as RollingPeopleVaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3