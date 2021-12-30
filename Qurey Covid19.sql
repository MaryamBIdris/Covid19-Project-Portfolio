--To view all data we have in our CovidDeaths table

SELECT*
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL

--To view all data we have in our CovidVaccinations table

SELECT*
FROM PortfolioProject1..CovidVaccinations
WHERE continent IS NOT NULL

--BREAK DOWN BY LOCATION
--To break down our data from our CovidDeaths table by location we use

SELECT location,date,population,total_cases,new_cases,total_deaths
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--total death percentage case

SELECT location,date,total_cases,total_deaths,((total_deaths/total_cases)*100) as death_percentage
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
--AND location LIKE '%United Kingdom%'
ORDER BY 1,2

--cases population percentage

SELECT location,date,population,total_cases,((total_cases/population)*100) as case_per_poppulation
FROM PortfolioProject1..CovidDeaths
--WHERE location LIKE '%United Kingdom%'
ORDER BY 1,2


--Countries with highest infection rate when compared to population

SELECT location,population, MAX(total_cases) as highest_infection_count,MAX((total_cases/population)*100) as percentage_population_infected
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY percentage_population_infected DESC

--Showing countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths as int)) as total_death_count
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

--BREAKDOWN BY CONTINENT 

--continents with hightest death count

SELECT continent, MAX(CAST(total_deaths as int)) as highest_death_count
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC

--Alternatively try 

SELECT location, MAX(CAST(total_deaths as int)) as highest_death_count
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NULL AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY highest_death_count DESC

--Percentage of Continents with highest infection 

SELECT continent, MAX(total_cases) as highest_infection_count,MAX((total_cases/population)*100) as percentage_population_infected
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY percentage_population_infected DESC

--GLOBAL NUMBERS

--global numbers per day

SELECT date,SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS INT)) AS total_deaths,
SUM(CAST(new_deaths AS INT))/ SUM(new_cases)*100 as death_percentage
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
--AND location LIKE '%United Kingdom%'
GROUP BY date
ORDER BY 1,2

--Total global figures

SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS INT)) AS total_deaths,
SUM(CAST(new_deaths AS INT))/ SUM(new_cases)*100 as death_percentage
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
--AND location LIKE '%United Kingdom%'
ORDER BY 1,2

--Joining our 2 tables CovidDeaths and Covid Vaccinations to see the data we have

SELECT*
FROM PortfolioProject1..CovidDeaths 
JOIN PortfolioProject1..CovidVaccinations 
ON CovidDeaths.location=CovidVaccinations.location AND CovidDeaths.date=CovidVaccinations.date
WHERE CovidDeaths.continent IS NOT NULL
Order by 2,3

-- to see total population vs vaccinated
 
SELECT dea.continent,dea.location,vac.date,dea.population,vac.new_vaccinations
FROM PortfolioProject1..CovidDeaths AS dea
JOIN PortfolioProject1..CovidVaccinations AS vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL
ORDER BY 2,3

--to see the rolling people vaccinated

SELECT dea.continent,dea.location,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_vaccinated
FROM PortfolioProject1..CovidDeaths AS dea
JOIN PortfolioProject1..CovidVaccinations AS vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL
ORDER BY 2,3

--Total Population vs Total vaccinated using CTE

WITH popvsvac (continent,location,date,population,new_vaccinations,rolling_vaccination) 
AS
(SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_vaccination
FROM PortfolioProject1..CovidDeaths AS dea
JOIN PortfolioProject1..CovidVaccinations AS vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL AND population IS NOT NULL)
--ORDER BY 2,3
SELECT*, (rolling_vaccination/population)*100 AS vaccination_percent
FROM popvsvac

--Alternatively Using Temp Table


DROP Table IF EXISTS #population_vaccinated_percent
CREATE TABLE #population_vaccinated_percent
(continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
rolling_vaccination numeric)

INSERT INTO #population_vaccinated_percent
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_vaccination
FROM PortfolioProject1..CovidDeaths AS dea
JOIN PortfolioProject1..CovidVaccinations AS vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL AND population IS NOT NULL
--ORDER BY 2,3
SELECT*, (rolling_vaccination/population)*100 AS vaccination_percent
FROM #population_vaccinated_percent

--create view to use for visualisation

CREATE VIEW 
population_vaccinated_percent AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_vaccination
FROM PortfolioProject1..CovidDeaths AS dea
JOIN PortfolioProject1..CovidVaccinations AS vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL AND population IS NOT NULL
--ORDER BY 2,3

--Data we are going to visualise in Tabllue

SELECT location,continent,date,population,total_cases,new_cases,total_deaths
FROM PortfolioProject1..CovidDeaths
WHERE continent='Europe'
ORDER BY 1,2


SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS INT)) AS total_deaths,
SUM(CAST(new_deaths AS INT))/ SUM(new_cases)*100 as death_percentage
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
--AND location LIKE '%United Kingdom%'
ORDER BY 1,2

SELECT location,population, MAX(total_cases) as highest_infection_count,MAX((total_cases/population)*100) as percentage_population_infected
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL AND population IS NOT NULL
GROUP BY location,population
ORDER BY percentage_population_infected DESC

SELECT location,date,population,MAX(total_cases) as highest_infection_count,MAX((total_cases/population)*100) as percentage_population_infected
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population, date
ORDER BY percentage_population_infected DESC










