-- Select data that are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM OWIDCOVIDDeath
ORDER BY 1,2

-- Total Cases vs Total Deaths, Fatality Rate in Canada
-- Shows the likelyhood of dying if contract COVID in Canada over time 
CREATE VIEW DeathPercentage_Canada AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS DeathPercentage 
FROM OWIDCOVIDDeath
WHERE location = 'Canada'
ORDER BY 1,2

CREATE VIEW MaxDeathPercentage_Canada AS
SELECT MAX((total_deaths/total_cases) *100) AS MaxDeathPercentage 
FROM OWIDCOVIDDeath
WHERE location = 'Canada'

			-- By 2022-06-29, Canada has total COVID cases of 3,948,112 with a death rate stabled around 1.06%. Dropped from the all time high 9.18%.


-- Total Cases vs Population 
-- Shows the percentage of population got COVID 
CREATE VIEW InfactionPercentage_Canada AS
SELECT location, date, total_cases, population, (total_cases/population) *100 AS InfectionPercentage 
FROM OWIDCOVIDDeath
WHERE location = 'Canada'
ORDER BY 1,2

-- Shows the countries with the highest infection rate
		
ALTER TABLE OWIDCOVIDDeath
MODIFY total_cases INTEGER
		-- Modifies the data type of total_cases to INTEGER
CREATE VIEW HighestInfectionPercentage AS
SELECT location, population, MAX(total_cases) as TotalInfectionCount, MAX((total_cases/population) *100) AS HighestInfectionPercentage 
FROM OWIDCOVIDDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestInfectionPercentage DESC

			-- As of 2022-06-29, 10.37% of the Canadian population have got COVID since the pandemic starts. Compared to United States and United Kingdom, having 26.28% and 33.39% population infected respectively. 

-- Shows the highest death count per population 
CREATE VIEW PopulationDeathPercentage_Canada AS
SELECT location, date, total_deaths, population, (total_deaths/population) *100 AS PopulationDeathPercentage 
FROM OWIDCOVIDDeath
WHERE location = 'Canada'
ORDER BY 1,2

ALTER TABLE OWIDCOVIDDeath
MODIFY total_deaths INTEGER

CREATE VIEW TotalPopulationDeathPercentage AS
SELECT location, population, MAX(total_deaths) as TotalDeathCount, MAX((total_deaths/population) *100) AS TotalDeathPercentage 
FROM OWIDCOVIDDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathPercentage DESC

		-- As of 2022-06-29, 0.11% of the Canadian population passed from COVID. Compared to United States and United Kingdom, 0.31% and 0.26% of the population were loss. 
		
-- GROUP BY CONTINENT 
-- Shows continents with the highest death count per population 
CREATE VIEW TotalDeathPercentage_Continent
SELECT continent, MAX(total_deaths) as TotalDeathCount, MAX((total_deaths/population) *100) AS TotalDeathPercentage 
FROM OWIDCOVIDDeath
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY totaldeathcount DESC
		-- As of 2022-06-29, North America has an overall death percentage per population of 0.31%.
		
-- Gloabal Numbers 
ALTER TABLE OWIDCOVIDDeath
MODIFY new_cases INTEGER 
ALTER TABLE OWIDCOVIDDeath
MODIFY new_deaths INTEGER 

		-- Global cases by day since 2020-01-01
CREATE VIEW GlobalDeathPercentage AS
SELECT date, SUM(new_cases) AS GlobalTotalCases, SUM(new_deaths) AS GlobalTotalDeaths, (SUM(new_deaths)/SUM(new_cases)) *100 AS GlobalDeathPercentage 
FROM OWIDCOVIDDeath
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


		-- Global total cases as of 2022-06-29
SELECT SUM(new_cases) AS GlobalTotalCases, SUM(new_deaths) AS GlobalTotalDeaths, (SUM(new_deaths)/SUM(new_cases)) *100 AS GlobalDeathPercentage 
FROM OWIDCOVIDDeath
WHERE continent IS NOT NULL
ORDER BY 1,2

		-- As of 2022-06-29, the overall fatality rate of COVID across the globe is 1.15%.
		-- There were a significant drop (quartered) of global death percentage since the begining of 2022. 
		-- Potential explanations:
				-- Vast application of Vaccinations (will be examined later) 
				-- Lower fatelity rate of the recent COVID variants 
				-- Herd immunity 
				-- Change/manipulations in reporting policies (Includes: selftest reporting requirements, the defination of COVID related deaths, carrier vs symptem...)
				-- Change/manipulations in testing policies  (Includes: regional testing policies, tests per capita, test kit availability...)
				-- Ohter errors 

-- VACCINATION DATA EXPLORATION 

SELECT *
FROM OWIDCOVIDDeath AS D
JOIN OWIDCOVIDVaccinations AS V
ON D.location = V.location 
AND D.date =V.date

-- Shows the total population vs vaccinaiton 

ALTER TABLE OWIDCOVIDVaccinations
MODIFY new_vaccinations INTEGER 

SELECT
	D.continent,
	D.location,
	D.date,
	D.population,
	V.new_vaccinations,
	SUM( V.new_vaccinations ) OVER ( PARTITION BY D.location ORDER BY D.location ROWS UNBOUNDED PRECEDING ) AS RollingVaccinations 
FROM
	OWIDCOVIDDeath AS D
	JOIN OWIDCOVIDVaccinations AS V ON D.location = V.location 
	AND D.date = V.date 
WHERE
	D.continent IS NOT NULL 
ORDER BY
	2,3


WITH PopulationvsVaccination AS 
(
SELECT
	D.continent,
	D.location,
	D.date,
	D.population,
	V.new_vaccinations,
	SUM( V.new_vaccinations ) OVER ( PARTITION BY D.location ORDER BY D.location ROWS UNBOUNDED PRECEDING ) AS RollingVaccinations 
FROM
	OWIDCOVIDDeath AS D
	JOIN OWIDCOVIDVaccinations AS V ON D.location = V.location 
	AND D.date = V.date 
WHERE
	D.continent IS NOT NULL 
ORDER BY
	2,3
)

SELECT * , (RollingVaccinations/population)*100 AS VaccinationPercent
FROM PopulationvsVaccination
WHERE location = 'canada'

		/* The Canadian vaccination percentage is over 225%, which can be explained by multiple doses of vaccination received by a large portion of the population. 
		It is supported by the Government of Canada: /https://health-infobase.canada.ca/covid-19/vaccination-coverage/; Currently, 85% of the Canadian population is fully vaccinated.
		According to the Government of Canada, December 2021 was the time when the vaccination percentage crossed the 80% mark, which indicated the catholicity of the vaccination could be a factor in the drop in the COVID fatality rate. */
		
	
	
	-- Creating View to store data for Visualisation 

CREATE VIEW PercentPopulationVaccinated AS	
SELECT
	D.continent,
	D.location,
	D.date,
	D.population,
	V.new_vaccinations,
	SUM( V.new_vaccinations ) OVER ( PARTITION BY D.location ORDER BY D.location ROWS UNBOUNDED PRECEDING ) AS RollingVaccinations 
FROM
	OWIDCOVIDDeath AS D
	JOIN OWIDCOVIDVaccinations AS V ON D.location = V.location 
	AND D.date = V.date 
WHERE
	D.continent IS NOT NULL 
ORDER BY
	2,3










