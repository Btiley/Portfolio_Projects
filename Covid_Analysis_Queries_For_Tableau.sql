/*
Queries used for Tableau Project
*/
-- 1. Global death percenage 

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM [COVID_19 Portfolio Project]..CovidDeaths
WHERE continent is not null 
--GROUP BY date
ORDER BY 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--FROM [COVID_19 Portfolio Project]..CovidDeaths
----WHERE location like '%states%'
--WHERE location = 'World'
----GROUP BY date
--ORDER BY 1,2

-- 2. TotalDeathCount per continent

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM [COVID_19 Portfolio Project]..CovidDeaths
WHERE continent is null 
and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc


-- 3. Percentage of population infected (at highest infection count) per location

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM [COVID_19 Portfolio Project]..CovidDeaths
WHERE location not in ('World', 'European Union', 'International')
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


-- 4. Percent population infected per day by location 


SELECT Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM [COVID_19 Portfolio Project]..CovidDeaths
WHERE location not in ('World', 'European Union', 'International')
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected desc



