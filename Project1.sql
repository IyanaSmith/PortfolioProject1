SELECT *
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
order by 3,4

SELECT *
FROM PortfolioProject1..CovidVaccinations
order by 3,4


--Select data we will use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths (perecentage of people dying vs infected)
--shows likelihood of death after infection per country

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPerecentage
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE '%states%'
order by 1,2

--Total cases vs population (chances of contracting COVID19)
SELECT location, date, total_cases, new_cases, total_deaths, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE '%states%'
order by 1,2

--Looking at countries with highest rate vs population
SELECT location, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS 
PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
--WHERE location LIKE '%states%'
Group by Location, population
ORDER BY PercentPopulationInfected DESC


SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%states%'
Group by Location 
ORDER BY TotalDeathCount DESC

-- Showing which continent has highest death per count population

SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%states%'
Group by continent 
ORDER BY TotalDeathCount DESC

SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject1..CovidDeaths
WHERE continent is null
--WHERE location LIKE '%states%'
Group by location 
ORDER BY TotalDeathCount DESC

--Global numbers
SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPerecentage
FROM PortfolioProject1..CovidDeaths
--WHERE location LIKE '%states%'
where continent is not null
group by date
order by 1,2

SELECT SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPerecentage
FROM PortfolioProject1..CovidDeaths
--WHERE location LIKE '%states%'
where continent is not null
--group by date
order by 1,2


--now to compare vaccinations using JOIN
-- the data type in the "vac.new_vaccinations" column is nvarchar. We must use a CONVERT
--or CAST function to change the data type to integers. 


SELECT dea.continent, dea.location, dea.date,  vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location=vac.location 
	and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- break

-- temp table 

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON Dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated


-- Create view to store data for visulations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON Dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER by 2,3
