SELECT *
FROM SQLPortfolio.dbo.coviddeaths
ORDER BY 3, 4

--SELECT *
--FROM SQLPortfolio.dbo.covidvaccinations
--ORDER BY 3, 4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SQLPortfolio.dbo.coviddeaths
ORDER BY 2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathsPercentage
FROM SQLPortfolio.dbo.coviddeaths
WHERE location like '%Ireland%'
ORDER BY 1,2




-- Looking at Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population) * 100 AS PopulationPercentage
FROM SQLPortfolio.dbo.coviddeaths
WHERE location like '%Bra%'
ORDER BY 1,2

-- Looking at countries with highets infection rate compared population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population) * 100) AS PopulationPercentageInfected
FROM SQLPortfolio.dbo.coviddeaths
--WHERE location like '%Sta%'
GROUP BY Population, Location
ORDER BY 4 DESc


-- Showing the countries with the highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathsCount
FROM SQLPortfolio.dbo.coviddeaths
WHERE continent is Not null
GROUP BY Location
ORDER BY 2 DESC


-- Lets break things down by continent

SELECT Continent, MAX(CAST(total_deaths as int)) AS TotalDeathsCount
FROM SQLPortfolio.dbo.coviddeaths
WHERE continent is not null
GROUP BY Continent
ORDER BY TotalDeathsCount DESC


-- Showing the continents with the highest death count per population

SELECT Continent, MAX(CAST(total_deaths as int)) AS TotalDeathsCount
FROM SQLPortfolio.dbo.coviddeaths
WHERE continent is Not null
GROUP BY Continent
ORDER BY 2 DESC

-- Global numbers

SELECT date, SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS int)) AS TotalNewDeaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM SQLPortfolio.dbo.coviddeaths
--WHERE location like '%New Z%'
WHERE continent is not null
GROUP BY date
Order by 1, 2

SELECT SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS int)) AS TotalNewDeaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM SQLPortfolio.dbo.coviddeaths
--WHERE location like '%New Z%'
WHERE continent is not null
--GROUP BY date
Order by 1, 2

-- Looking at total population vs vaccination (NEW ZEALAND)

SELECT dea.date, dea.location, dea.population, vac.new_vaccinations
FROM SQLPortfolio.dbo.coviddeaths dea
JOIN SQLPortfolio.dbo.covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null AND new_vaccinations is not null
AND dea.location = 'Brazil'


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated, (RollingPeopleVaccinated / population) * 100
FROM SQLPortfolio.dbo.coviddeaths dea
JOIN SQLPortfolio.dbo.covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null AND dea.location = 'New Zealand'
ORDER BY 2, 3

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --(RollingPeopleVaccinated / population) * 100
FROM SQLPortfolio.dbo.coviddeaths dea
JOIN SQLPortfolio.dbo.covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null AND dea.location = 'New Zealand'
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --(RollingPeopleVaccinated / population) * 100
FROM SQLPortfolio.dbo.coviddeaths dea
JOIN SQLPortfolio.dbo.covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null --AND dea.location = 'New Zealand'
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --(RollingPeopleVaccinated / population) * 100
FROM SQLPortfolio.dbo.coviddeaths dea
JOIN SQLPortfolio.dbo.covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null --AND dea.location = 'New Zealand'
--ORDER BY 2, 3


SELECT *
FROM PercentPopulationVaccinated