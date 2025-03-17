--The information was obtained from https://ourworldindata.org/covid-deaths and modified for future reference. Two separate tables, CovidDeaths and CovidVaccinations, were derived from the original dataset.

USE Covid;

--Data Preparation

CREATE NONCLUSTERED INDEX IX_Location
ON CovidDeaths (Location);

CREATE NONCLUSTERED INDEX IX_Date
ON CovidDeaths (Date);


SELECT * 
FROM CovidDeaths
ORDER BY 3, 4;

SELECT * 
FROM CovidVaccinations
ORDER BY 3, 4;

SELECT Location, Date, Total_cases, New_cases, Total_deaths, Population
FROM CovidDeaths
ORDER BY 1, 2;

---- Total Deaths

-- Calculation of COVID-19 Fatality Rate for each country
SELECT Location, Date, Total_cases, Total_deaths,  
  ROUND((CAST(total_deaths AS FLOAT)/total_cases)*100, 3) as FatalityRate
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1, 2;

-- Determining the Ranking of Countries by COVID-19 Fatality Rate as of August 30, 2023
SELECT Location,    
  ROUND((CAST(total_deaths AS FLOAT)/total_cases)*100, 3) as FatalityRate
FROM CovidDeaths
WHERE Date LIKE '2023-08-30' AND continent is not null
ORDER BY 2 DESC;

-- Determining the Ranking of Continents by COVID-19 Fatality Rate as of August 30, 2023
SELECT Location,    
  ROUND((CAST(total_deaths AS FLOAT)/total_cases)*100, 3) as FatalityRate
FROM CovidDeaths
WHERE Date LIKE '2023-08-30' AND continent is null AND iso_code NOT IN ('OWID_HIC', 'OWID_LIC', 'OWID_LMC', 'OWID_UMC', 'OWID_EUN', 'OWID_WRL')
ORDER BY 2 DESC;

-- Ranking Countries by COVID-19 Total Deaths as of August 30, 2023
SELECT Location, CAST(total_deaths as int) as TotalDeathCount
FROM CovidDeaths
WHERE Date LIKE '2023-08-30' AND continent is not null
ORDER BY 2 DESC;

-- Ranking Continents by COVID-19 Total Deaths as of August 30, 2023
SELECT Location, CAST(total_deaths as int) as TotalDeathCount
FROM CovidDeaths
WHERE Date LIKE '2023-08-30' AND continent is null AND iso_code NOT IN ('OWID_HIC', 'OWID_LIC', 'OWID_LMC', 'OWID_UMC', 'OWID_EUN', 'OWID_WRL')
ORDER BY 2 DESC;

-- Ranking Income Class by COVID-19 Total Deaths as of August 30, 2023SELECT Location,    
SELECT Location, CAST(total_deaths as int) as TotalDeathCount
FROM CovidDeaths
WHERE Date LIKE '2023-08-30' AND iso_code IN ('OWID_HIC', 'OWID_LIC', 'OWID_LMC', 'OWID_UMC')
ORDER BY 2 DESC;

-- Determining the Ranking of Income Class by COVID-19 Fatality Rate as of August 30, 2023
SELECT Location,    
  ROUND((CAST(total_deaths AS FLOAT)/total_cases)*100, 3) as FatalityRate
FROM CovidDeaths
WHERE Date LIKE '2023-08-30' AND iso_code IN ('OWID_HIC', 'OWID_LIC', 'OWID_LMC', 'OWID_UMC')
ORDER BY 2 DESC;

---- Total Cases and Population ----

-- Calculation of COVID-19 Contraction Rate for each country
SELECT Location, Date, Total_cases, Population,  
  ROUND((CAST(total_cases AS FLOAT)/Population)*100, 3) as ContractionRate
FROM CovidDeaths
ORDER BY 1, 2;

-- Determining the Ranking of Countries by COVID-19 Contraction Rate as of August 30, 2023
SELECT Location,    
  ROUND((CAST(total_cases AS FLOAT)/Population)*100, 3) as ContractionRate
FROM CovidDeaths
WHERE Date LIKE '2023-08-30' AND continent is not null
ORDER BY 2 DESC;

-- Ranking Income Class by COVID-19 Contraction as of August 30, 2023SELECT Location,    
SELECT Location, CAST(total_cases as int) as ContractionCount
FROM CovidDeaths
WHERE Date LIKE '2023-08-30' AND iso_code IN ('OWID_HIC', 'OWID_LIC', 'OWID_LMC', 'OWID_UMC')
ORDER BY 2 DESC;

-- Determining the Ranking of Income Class by COVID-19 Contraction Rate as of August 30, 2023
SELECT Location,    
  ROUND((CAST(total_cases AS FLOAT)/population)*100, 3) as ContractionRate
FROM CovidDeaths
WHERE Date LIKE '2023-08-30' AND iso_code IN ('OWID_HIC', 'OWID_LIC', 'OWID_LMC', 'OWID_UMC')
ORDER BY 2 DESC;

-- Daily COVID-19 Death Percentage by Date
SELECT date, SUM(new_cases) as DailyNewCases, SUM(new_deaths) as DailyNewDeaths, 
	CASE
        WHEN SUM(new_cases) = 0 THEN 0  
        ELSE ROUND((CAST(SUM(new_deaths) AS FLOAT) / SUM(new_cases)) * 100, 3)
    END as DeathPercentage
FROM CovidDeaths
WHERE continent is not null AND iso_code NOT IN ('OWID_HIC', 'OWID_LIC', 'OWID_LMC', 'OWID_UMC', 'OWID_EUN', 'OWID_WRL')
GROUP BY date
ORDER BY date

-- Total COVID-19 Death Percentage
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, ROUND((CAST(SUM(new_deaths) AS FLOAT) / SUM(new_cases)) * 100, 3) as TotalDeathPercentage
FROM CovidDeaths
WHERE continent is null AND iso_code NOT IN ('OWID_HIC', 'OWID_LIC', 'OWID_LMC', 'OWID_UMC', 'OWID_EUN', 'OWID_WRL')


--- Vaccinations
--Total count of vacinnated people
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (PARTITION BY cv.location ORDER BY cv.location, cv.date ROWS UNBOUNDED PRECEDING) as PeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv ON cd.location=cv.location AND cd.date = cv.date
WHERE cd.continent is not null AND cd.iso_code NOT IN ('OWID_HIC', 'OWID_LIC', 'OWID_LMC', 'OWID_UMC', 'OWID_EUN', 'OWID_WRL')
ORDER BY 2, 3


--- Vaccinations
--Total count of vacinnated people
With PeopleVaccinatedDaily (continent, location, date, population, new_vaccinations, PeopleVaccinated)
as
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (PARTITION BY cv.location ORDER BY cv.location, cv.date ROWS UNBOUNDED PRECEDING) as PeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv ON cd.location=cv.location AND cd.date = cv.date
WHERE cd.continent is not null AND cd.iso_code NOT IN ('OWID_HIC', 'OWID_LIC', 'OWID_LMC', 'OWID_UMC', 'OWID_EUN', 'OWID_WRL')
--ORDER BY 2, 3
)
SELECT *, (PeopleVaccinated/population)*100
FROM PeopleVaccinatedDaily;

CREATE VIEW PeopleVaccinatedDaily AS 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (PARTITION BY cv.location ORDER BY cv.location, cv.date ROWS UNBOUNDED PRECEDING) as PeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv ON cd.location=cv.location AND cd.date = cv.date
WHERE cd.continent is not null AND cd.iso_code NOT IN ('OWID_HIC', 'OWID_LIC', 'OWID_LMC', 'OWID_UMC', 'OWID_EUN', 'OWID_WRL')
--ORDER BY 2, 3
