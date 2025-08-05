Select *
FROM [SQL Learn].dbo.CovidDeaths
ORDER BY 3,4

--Select *
--FROM [SQL Learn].[dbo].[CovidVaccinations]
--ORDER BY 3,4

--Select the data we will be using
Select Location, date, total_cases, new_cases, total_deaths, population
FROM [SQL Learn].dbo.CovidDeaths
ORDER BY 1,2

-- Look at Total cases vs total deaths
-- shows likelihood of dying if you get covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [SQL Learn].dbo.CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

-- look at total cases vs population
Select Location, date, total_cases, population, (total_cases/population)*100 as CovidInfectionPercentage
FROM [SQL Learn].dbo.CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

--Country has highest infection rates
Select Location, population, MAX(total_cases) as HighestInfectonCount, MAX(total_cases/population)*100 as HighestCovidInfectionPercentage
FROM [SQL Learn].dbo.CovidDeaths
GROUP BY Location, population
ORDER BY HighestCovidInfectionPercentage desc

-- Country with higest death count
Select Location, MAX(total_deaths) as HighestDeathCount
FROM [SQL Learn].dbo.CovidDeaths
where continent is not null
GROUP BY Location
ORDER BY HighestDeathCount desc

-- See summary by continent
Select continent, MAX(total_deaths) as HighestDeathCount
FROM [SQL Learn].dbo.CovidDeaths
where continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc

-- Global numbers
Select SUM(new_cases) as total_cases, sum(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as percentage
FROM [SQL Learn].dbo.CovidDeaths
where continent is not null
ORDER BY 1,2

-- USE CTE for further calculation, -- Join Deaths and Vaccination table and look at total population vs. Vaccinations
WITH POPVAC (continent, location, date, population, new_vaccinations, RollingVaccination)
AS 
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(VAC.new_vaccinations) OVER (partition by DEA.location ORDER BY DEA.location, DEA.date) AS RollingVaccination
FROM [SQL Learn].dbo.CovidDeaths DEA
JOIN [SQL Learn].dbo.CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null
)

SELECT *, (RollingVaccination/population)*100 AS percentage
FROM POPVAC


--create a temp table
DROP TABLE IF exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(continent nvarchar(50),
location nvarchar(50),
date date,
population numeric,
new_vaccinations numeric,
RollingVaccination numeric)

INSERT INTO #PercentagePopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(VAC.new_vaccinations) OVER (partition by DEA.location ORDER BY DEA.location, DEA.date) AS RollingVaccination
FROM [SQL Learn].dbo.CovidDeaths DEA
JOIN [SQL Learn].dbo.CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null

SELECT *, (RollingVaccination/population)*100 AS percentage
FROM #PercentagePopulationVaccinated



--create a view to store data for later visuals
USE [SQL Learn];
GO
CREATE VIEW New_PercentagePopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(VAC.new_vaccinations) OVER (partition by DEA.location ORDER BY DEA.location, DEA.date) AS RollingVaccination
FROM [SQL Learn].dbo.CovidDeaths DEA
JOIN [SQL Learn].dbo.CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null;
GO

SELECT *
FROM New_PercentagePopulationVaccinated