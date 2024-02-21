SELECT * FROM PortfolioProject.CovidDeaths ORDER BY 3,4;

-- Specify NULL for rows with no values for the column 'continent'
UPDATE CovidDeaths SET continent = NULL WHERE continent IS NULL OR continent = '';

SELECT location,RecordDate,total_cases,new_cases,total_deaths,population FROM CovidDeaths WHERE continent is not NULL ORDER BY 1,2;

-- Checking Total cases vs Total Deaths 

SELECT location,RecordDate,total_cases,total_deaths, ((total_deaths/total_cases)*100) AS DeathPercentage FROM CovidDeaths WHERE continent is not NULL ORDER BY 1,2;

-- Checking the Death percentage For India 
-- shows the probability of dying for Covid positive people
SELECT location,RecordDate,total_cases,total_deaths, ((total_deaths/total_cases)*100) AS DeathPercentage FROM CovidDeaths WHERE location = "India" and continent is not NULL ORDER BY 1,2 ;

-- Total cases Vs Population In India
-- Shows what % of the population got covid
SELECT location,RecordDate,total_cases,population, ((total_cases/population)*100) AS InfectionRate FROM CovidDeaths WHERE location = "India" and continent is not NULL ORDER BY 1,2 ;

-- Checking Countries with hightest Infection Rates(Percentage of Population Infected with Covid)

-- SELECT location,RecordDate,total_cases,population, ((total_cases/population)*100) AS InfectionRate FROM CovidDeaths WHERE location="Andorra" and continent is not NULL ORDER BY InfectionRate DESC;
SELECT location,population,MAX(total_cases) AS MAXInfectedPeople, MAX((total_cases/population)*100) AS MAXInfectionRate FROM CovidDeaths  WHERE continent is not NULL GROUP BY location,population ORDER BY MAXInfectionRate DESC;

-- Displaying Countries with Highest Death Counts

SELECT location,population,MAX(total_deaths)AS MAXDeathCounts FROM CovidDeaths WHERE continent is not NULL GROUP BY location, population ORDER BY MAXDeathCounts DESC;

-- Checking the Maximum Death Counts as per Continents

SELECT continent, MAX(total_deaths)AS MAXDeathCounts FROM CovidDeaths WHERE continent is not NULL GROUP BY continent ORDER BY MAXDeathCounts DESC;

-- Checking new cases and Death Percentage on a Global basis

SELECT RecordDate, SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage FROM CovidDeaths WHERE continent is NOT NULL GROUP BY RecordDate ORDER BY 1; 
SELECT SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage FROM CovidDeaths WHERE continent is NOT NULL ORDER BY 1; 

-- JOIN the two datasets Covid Deaths and Covid Vaccinations
UPDATE CovidVaccine SET continent=NULL WHERE continent is NULL OR continent='';

SELECT * FROM CovidDeaths as dea JOIN CovidVaccine as vac ON dea.location=vac.location and dea.RecordDate=vac.Recorddate;


-- Show total population vs New vaccinations given
SELECT dea.continent, dea.location, dea.RecordDate, dea.population, vac.new_vaccinations FROM CovidDeaths as dea JOIN CovidVaccine as vac ON dea.location=vac.location and dea.RecordDate=vac.Recorddate WHERE dea.continent is NOT NULL ORDER BY 2,3;

SELECT dea.continent, dea.location, dea.RecordDate, dea.population, vac.new_vaccinations,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location ,dea.RecordDate) AS CumulativeVaccinations FROM CovidDeaths as dea JOIN CovidVaccine as vac ON dea.location=vac.location and dea.RecordDate=vac.Recorddate WHERE dea.continent is not NULL ORDER BY 2,3;

-- CREATE CTE
WITH PopulationVsVaccinations(Continent,Location,Date,Population,NewVaccinations,CumulativeVaccinations)
AS
(
	SELECT dea.continent, dea.location, dea.RecordDate, dea.population, vac.new_vaccinations,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location ,dea.RecordDate) AS CumulativeVaccinations FROM CovidDeaths as dea JOIN CovidVaccine as vac ON dea.location=vac.location and dea.RecordDate=vac.Recorddate WHERE dea.continent is not NULL
)
SELECT *, (CumulativeVaccinations/Population)*100 AS PercentPopVaccinated FROM PopulationVsVaccinations;

-- CREATE CTE
WITH PopulationVsVaccinations(Continent,Location,Date,Population,NewVaccinations,CumulativeVaccinations)
AS
(
	SELECT dea.continent, dea.location, dea.RecordDate, dea.population, vac.new_vaccinations,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location ,dea.RecordDate) AS CumulativeVaccinations FROM CovidDeaths as dea JOIN CovidVaccine as vac ON dea.location=vac.location and dea.RecordDate=vac.Recorddate WHERE dea.continent is not NULL
)SELECT Location,Population,(MAX(CumulativeVaccinations)/Population)*100 AS PercentPopVaccinated FROM PopulationVsVaccinations GROUP BY Location, Population;

DROP TABLE IF EXISTS POPULATIONvsVaccinations;
CREATE TEMPORARY TABLE POPULATIONvsVaccinations
(   Continent varchar(255),
	Location varchar(255),
    Date date,
    Population numeric,
    NewVaccinations numeric,
    CumulativeVaccinations numeric)
   
INSERT INTO POPULATIONvsVaccinations
SELECT dea.continent, 
       dea.location, 
       dea.RecordDate, 
       dea.population , 
       vac.new_vaccinations, 
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.RecordDate) AS CumulativeVaccinations 
FROM CovidDeaths AS dea 
JOIN CovidVaccine AS vac ON dea.location = vac.location AND dea.RecordDate = vac.Recorddate 
WHERE dea.continent IS NOT NULL;


SELECT *, (CumulativeVaccinations/Population)*100 AS PercentPopVaccinated FROM PopulationVsVaccinations;

-- Creating a view to store data for later use
CREATE VIEW PopulationVaccinated AS
SELECT dea.continent, dea.location, dea.RecordDate, dea.population, vac.new_vaccinations,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location ,dea.RecordDate) AS CumulativeVaccinations FROM CovidDeaths as dea JOIN CovidVaccine as vac ON dea.location=vac.location and dea.RecordDate=vac.Recorddate WHERE dea.continent is not NULL;
