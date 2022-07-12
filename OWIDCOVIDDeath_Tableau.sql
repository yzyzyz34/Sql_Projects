-- Death percentage globally 
Create VIEW TableauCOVID1 AS
SELECT SUM(new_cases) AS total_cases, sum(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases) *100 as DeathPercentage
FROM OWIDCOVIDDeath
WHERE continent is not null 
ORDER BY 1,2

-- Total death count by continent
CREATE VIEW TableauCOVID2 AS
Select location, SUM(new_deaths ) as TotalDeathCount
From OWIDCOVIDDeath
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc

-- Percent population infected by country 
CREATE VIEW tableauCOVID3 AS
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From OWIDCOVIDDeath
Group by Location, Population
order by PercentPopulationInfected desc

-- Dynamic percent population infected by country 
CREATE VIEW tableauCOVID4 as
Select Location,Population ,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From OWIDCOVIDDeath
Group by Location, Population, date
order by PercentPopulationInfected desc