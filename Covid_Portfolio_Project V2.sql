
SELECT*
FROM PortfolioProject..Deaths
WHERE continent is not null
ORDER BY 3,4

--SELECT*
--FROM PortfolioProject..Vaccinations
--ORDER BY 3,4

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Deaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at total_cases vs total_deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths,(total_deaths/NULLIF(total_cases,0))*100 as DeathPercentage
FROM PortfolioProject..Deaths
WHERE location like '%India%'
and continent is not null
ORDER BY 1,2

-- Looking at total_cases vs population
-- Shows what percentage of population got covid

SELECT location, date, population, total_cases,(NULLIF(total_cases,0)/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..Deaths
--WHERE location like '%India%'
ORDER BY 1,2


-- Looking at countries with Highest Infection Rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(NULLIF(total_cases,0)/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..Deaths
--WHERE location like '%India%'
GROUP  BY location, population
ORDER BY PercentagePopulationInfected desc

-- Showing Countries with Highest Death Count per population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..Deaths
--WHERE location like '%India%'
WHERE continent is not null
GROUP  BY location
ORDER BY TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT



-- Showing the continents with the highest death count per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..Deaths
--WHERE location like '%India%'
WHERE continent is not null
GROUP  BY continent
ORDER BY TotalDeathCount desc


-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths) / NULLIF(SUM(new_cases), 0)) * 100 AS DeathPercentage
FROM PortfolioProject..Deaths
--WHERE location like '%India%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..Deaths dea
JOIN PortfolioProject..Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3


-- Use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..Deaths dea
JOIN PortfolioProject..Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..Deaths dea
JOIN PortfolioProject..Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not NULL
--ORDER BY 2,3

Select*, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..Deaths dea
JOIN PortfolioProject..Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT*
FROM PercentPopulationVaccinated

