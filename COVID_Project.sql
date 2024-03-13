SELECT *
FROM PortfolioProject.dbo.CovidDeaths

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations

--Select Data that we are going to be using. 

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in a specific country 

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location like '%colombia%'
ORDER BY 1,2

-- Looking at the Total Cases vs Population 
-- Shows what percentage of population got COVID 

SELECT Location, Date, total_cases, Population, (total_cases/population)*100 as PopulationPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location like '%colombia%'
ORDER BY 1,2

-- Looking at Countries with the highest infection rates compared to population 

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PencentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY Location, Population
ORDER BY PencentPopulationInfected DESC

-- Showing Countries with the highest death count per population 

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT 

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS 

SELECT Date, SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths
FROM PortfolioProject.dbo.CovidDeaths 
WHERE continent is not null 
GROUP BY Date
ORDER BY 1,2 

-- Looking at Total Population vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations as NewVaccinations
, SUM(new_vaccinations) OVER (Partition by dea.location ORDER BY dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

-- USE CTE Population VS Vaccination 

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition By dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as TotalPopulationVaccinated
FROM PopvsVac 
WHERE New_Vaccinations is not null



--TEMP TABLE 

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric, 
)

 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition By dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 

SELECT *, (RollingPeopleVaccinated/Population)*100 as TotalPopulationVaccinated
FROM #PercentPopulationVaccinated 


--Creating view to store data for later visualizations 

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition By dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null 

SELECT *
FROM PercentPopulationVaccinated

