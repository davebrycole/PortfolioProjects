SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--SELECT Data to be used in this project

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

--Comparison of the Total Cases vs Total Deaths 

SELECT location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM PortfolioProject..covidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

--Comparison of the Total Cases vs Percentage of Population got Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Cameroon%'
WHERE continent is NOT NULL
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate Compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is NOT NULL
Group by Location, Population
order by PercentPopulationInfected desc

--Display of Countries with Highest Death Count per population 

SELECT Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is NOT NULL
Group by Location
order by TotalDeathCount desc

--Comparison of Death Count by Continent 


SELECT Continent, sum(new_deaths) AS TotalDeathCount
from PortfolioProject..CovidDeaths
where continent!=''
group by continent;


--Overview of the Global Numbers 

SELECT date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM PortfolioProject..covidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

--Total Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths AS int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE location like'%states%'
WHERE continent is NOT NULL
--Group By Date 
Order by 1,2;


--Looking at Total Population vs Vaccinations

SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS cumulative_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations,
       SUM(Convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) AS cumulative_vaccinations 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

--USE CTE

WIth PopvsVac (Continent, Location, date, Population, new_vaccinations, cumulative_vaccinations)
AS
(
SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations,
       SUM(Convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) AS cumulative_vaccinations 
--, (cumulative_vaccinations/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (cumulative_vaccinations/Population)*100
FROM PopvsVac



--TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric,
new_vaccinations numeric,
cumulative_vaccinations numeric,
)

INSERT INTO  #PercentPopulationVaccinated 
SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations,
       SUM(Convert(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) AS cumulative_vaccinations 
--, (cumulative_vaccinations/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date 
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (cumulative_vaccinations/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later Data Visualizations

DROP View PercentPopulationVaccinated 

Create View PercentPopulationVaccinated AS

SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations,
       SUM(Convert(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) AS cumulative_vaccinations 
--, (cumulative_vaccinations/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3


SELECT *
FROM PercentPopulationVaccinated
