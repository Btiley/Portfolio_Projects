-- Viewing structure of tables and columns

SELECT TOP 10 * FROM Portfolio_Project..CovidDeaths
SELECT TOP 10 * FROM Portfolio_Project..CovidVaccinations WHERE continent is not null ORDER BY location

--Select columns that will be used in analysis from CovidDeaths table

Select Location, date, total_cases, new_cases, total_deaths,population	
FROM Portfolio_Project..CovidDeaths 
WHERE location IN ('Australia','United States','United Kingdom')
order by 1,2

-- Percentage of deaths vs Total number of cases per day 

SELECT continent,location,date,total_cases,total_deaths,ROUND(total_deaths/total_cases * 100,3) as death_percentage
FROM Portfolio_Project..CovidDeaths
WHERE location IN ('Australia','United States','United Kingdom')
ORDER BY 1,2

-- Percentage of Covid cases vs Population per day 

SELECT continent,location,date,population,total_cases,ROUND(total_cases/population * 100,3) as Covid_Percentage FROM Portfolio_Project..CovidDeaths 
WHERE location IN ('Australia','United States','United Kingdom')
ORDER BY 1,2,3

--Looking at the percentage of population who got Covid (The highest number of total cases)

SELECT continent,location,population as Population,MAX(total_cases) as HighestInfectionCount,ROUND(MAX(total_cases)/population * 100,3) as Infection_Percentage FROM Portfolio_Project..CovidDeaths 
WHERE location IN ('Australia','United States','United Kingdom','China','India')
GROUP BY continent,location,population
ORDER BY Infection_Percentage DESC

--Highest death count by country

SELECT continent,location,MAX(cast(total_deaths as int)) as TotalDeathCount FROM Portfolio_Project..CovidDeaths 
WHERE continent is not null
AND location IN ('Australia','United States','United Kingdom','China','India')
GROUP BY continent,location
ORDER BY TotalDeathCount DESC

-- Highest death count by conitinent

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount FROM Portfolio_Project..CovidDeaths 
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Drill down effect, by continent, by location 

-- GLOBAL NUMBERS 

-- Global percentage of deaths vs cases per day
SELECT date,SUM(new_cases) as Global_Cases, SUM(cast(new_deaths as int)) as Global_Deaths, ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100,3) as DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Global percentage of deaths vs cases per day

SELECT date, SUM(new_cases) as Global_Cases, SUM(cast(new_deaths as int)) as Global_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Running total of number of vacinations per day by location.

SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations
,SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.location Order by CD.location,CD.date) as RunningVacTotal
FROM Portfolio_Project..CovidDeaths CD
JOIN Portfolio_Project..CovidVaccinations CV
ON CD.location = CV.location 
and CD.date = CV.date
WHERE CD.continent is not null AND CD.location = 'Australia'
order by 2,3

-- Running total of percent of population vaccinated by location. 
With PopvSVac(Continent,Location,Date,Population, New_Vaccinations, RunningVacTotal)
as
(
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations
,SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.location Order by CD.location,CD.date) as RunningVacTotal
FROM Portfolio_Project..CovidDeaths CD
JOIN Portfolio_Project..CovidVaccinations CV
ON CD.location = CV.location 
and CD.date = CV.date
WHERE CD.continent is not null 
)

SELECT *, (RunningVacTotal/(Population)*100) as RunningPercentVaccinated
FROM PopvsVaC
WHERE location = 'China'

-- Use a temp table
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),

Date datetime,
Population numeric,
New_vaccinations numeric, 
RunningVacTotal numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations
,SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.location Order by CD.location,CD.date) as RunningVacTotal
FROM Portfolio_Project..CovidDeaths CD
JOIN Portfolio_Project..CovidVaccinations CV
ON CD.location = CV.location 
and CD.date = CV.date
--WHERE CD.continent is not null 
--order by 2,3

SELECT *, (RunningVacTotal/(Population)*100) as RunningPercentVaccinated
FROM #PercentPopulationVaccinated
WHERE location = 'Australia'

--Creating Views to store data for later visualizations
DROP VIEW if exists PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated as 
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations
,SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.location Order by CD.location,CD.date) as RunningVacTotal
FROM Portfolio_Project..CovidDeaths CD
JOIN Portfolio_Project..CovidVaccinations CV
ON CD.location = CV.location 
and CD.date = CV.date
WHERE CD.continent is not null 
--order by 2,3

SELECT * FROM PercentPopulationVaccinated


-- Work view/ work table set aside to be used consistently






--Query Ideas--


-- Tests performed vs positive rate


