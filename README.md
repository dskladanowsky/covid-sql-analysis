# COVID-19 Time Series Data Analysis - README

## Introduction
This project focuses on analyzing COVID-19 deaths and vaccinations using SQL queries. The data has been obtained from [Our World in Data](https://ourworldindata.org/covid-deaths) and has been modified for future reference. The dataset consists of two tables:
- **CovidDeaths**: Contains information on total cases, deaths, and population data.
- **CovidVaccinations**: Contains vaccination data.

## Data Preparation
To optimize query performance, the following indexes were created:
```sql
CREATE NONCLUSTERED INDEX IX_Location
ON CovidDeaths (Location);

CREATE NONCLUSTERED INDEX IX_Date
ON CovidDeaths (Date);
```
These indexes improve the efficiency of queries filtering by `Location` and `Date`.

## Data Exploration
To understand the dataset structure, we retrieve all records:
```sql
SELECT * FROM CovidDeaths ORDER BY 3, 4;
SELECT * FROM CovidVaccinations ORDER BY 3, 4;
```

## Analysis Queries

### Total Deaths
1. **COVID-19 Fatality Rate Calculation**
```sql
SELECT Location, Date, Total_cases, Total_deaths,  
  ROUND((CAST(total_deaths AS FLOAT)/total_cases)*100, 3) as FatalityRate
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;
```
- This query calculates the fatality rate (percentage of deaths per total cases) for each country.

2. **Ranking Countries by Fatality Rate (As of August 30, 2023)**
```sql
SELECT Location, ROUND((CAST(total_deaths AS FLOAT)/total_cases)*100, 3) as FatalityRate
FROM CovidDeaths
WHERE Date LIKE '2023-08-30' AND continent IS NOT NULL
ORDER BY 2 DESC;
```
- This ranks countries based on their fatality rate.

3. **Ranking Continents by Fatality Rate (As of August 30, 2023)**
```sql
SELECT Location, ROUND((CAST(total_deaths AS FLOAT)/total_cases)*100, 3) as FatalityRate
FROM CovidDeaths
WHERE Date LIKE '2023-08-30' AND continent IS NULL
ORDER BY 2 DESC;
```
- Aggregates data at the continent level.

4. **Ranking Countries by Total Deaths (As of August 30, 2023)**
```sql
SELECT Location, CAST(total_deaths AS INT) as TotalDeathCount
FROM CovidDeaths
WHERE Date LIKE '2023-08-30' AND continent IS NOT NULL
ORDER BY 2 DESC;
```
- Displays total deaths per country.

### Total Cases and Population
1. **COVID-19 Contraction Rate Calculation**
```sql
SELECT Location, Date, Total_cases, Population,  
  ROUND((CAST(total_cases AS FLOAT)/Population)*100, 3) as ContractionRate
FROM CovidDeaths
ORDER BY 1, 2;
```
- Calculates the percentage of the population that has contracted COVID-19.

2. **Ranking Countries by Contraction Rate (As of August 30, 2023)**
```sql
SELECT Location, ROUND((CAST(total_cases AS FLOAT)/Population)*100, 3) as ContractionRate
FROM CovidDeaths
WHERE Date LIKE '2023-08-30' AND continent IS NOT NULL
ORDER BY 2 DESC;
```
- Lists the most affected countries based on contraction rate.

3. **Daily COVID-19 Death Percentage by Date**
```sql
SELECT date, SUM(new_cases) as DailyNewCases, SUM(new_deaths) as DailyNewDeaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN 0  
        ELSE ROUND((CAST(SUM(new_deaths) AS FLOAT) / SUM(new_cases)) * 100, 3)
    END as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;
```
- Tracks daily death percentages.

### Vaccinations
1. **Total Count of Vaccinated People**
```sql
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
    SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (PARTITION BY cv.location ORDER BY cv.location, cv.date ROWS UNBOUNDED PRECEDING) as PeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv ON cd.location=cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2, 3;
```
- Calculates cumulative vaccination numbers.

2. **Using a Common Table Expression (CTE) to Calculate Vaccination Percentage**
```sql
WITH PeopleVaccinatedDaily (continent, location, date, population, new_vaccinations, PeopleVaccinated) AS (
    SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
        SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (PARTITION BY cv.location ORDER BY cv.location, cv.date ROWS UNBOUNDED PRECEDING) as PeopleVaccinated
    FROM CovidDeaths cd
    JOIN CovidVaccinations cv ON cd.location=cv.location AND cd.date = cv.date
    WHERE cd.continent IS NOT NULL
)
SELECT *, (PeopleVaccinated/population)*100 as VaccinationRate
FROM PeopleVaccinatedDaily;
```
- Uses a CTE to calculate cumulative vaccinations and vaccination rate.

3. **Creating a View for Vaccination Data**
```sql
CREATE VIEW PeopleVaccinatedDaily AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
    SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (PARTITION BY cv.location ORDER BY cv.location, cv.date ROWS UNBOUNDED PRECEDING) as PeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv ON cd.location=cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;
```
- Creates a view for easier data retrieval.

## Conclusion
This project provides insights into the impact of COVID-19 by analyzing fatality rates, contraction rates, and vaccination trends. The queries help rank countries and continents based on different metrics, making it easier to track the pandemic's progression over time.

---

