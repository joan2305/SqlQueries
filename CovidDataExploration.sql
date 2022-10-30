SELECT
	Location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM
	CovidDeaths
ORDER BY
	1,2

-- Likelihood of dying if getting covid in the country by looking at death percentage
SELECT
	Location,
	date,
	total_cases,
	total_deaths,
	[Death Percentage] = (total_deaths/total_cases)*100
FROM
	CovidDeaths
WHERE
	location like '%states%'
ORDER BY
	1,2

-- Percentage of people getting covid in the country
SELECT
	Location,
	date,
	population,
	total_cases,
	[Infection Percentage] = (total_cases/population)*100
FROM
	CovidDeaths
WHERE
	location like '%states%'
ORDER BY
	1,2

-- Countries with highest infection rate --> total cases per population
SELECT
	Location,
	population,
	[Highest Infection] = MAX(total_cases),
	[Infection Percentage] = MAX((total_cases/population)*100)
FROM 
	CovidDeaths
GROUP BY
	location,
	population
ORDER BY
	4 DESC

SELECT
	Location, 
	[Total Deaths] = MAX(CAST(total_deaths AS int))
FROM 
	CovidDeaths
WHERE
	continent is null
GROUP BY
	location
ORDER BY
	[Total Deaths] DESC

-- Total Death per continent 
-- Continent with the highest death per population
SELECT
	continent, 
	[Total Deaths] = MAX(CAST(total_deaths AS int))
FROM 
	CovidDeaths
WHERE
	continent is not null
GROUP BY
	continent
ORDER BY
	[Total Deaths] DESC

-- Global numbers
SELECT
	SUM(new_cases) as [Total Cases],
	SUM(CAST(new_deaths as int)) as [Total Deaths],
	[Death Percentage] = (SUM(CAST(new_deaths as int))/SUM(new_cases)*100)
FROM
	CovidDeaths
WHERE
	continent is not null
ORDER BY
	1,2


-- Total population vs vaccinations
SELECT 
	cd.continent,
	cd.location,
	cd.date,
	population,
	cv.new_vaccinations,
	[Rolling People Vaccinated] = SUM(CONVERT (int, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date)
FROM
	CovidDeaths cd JOIN CovidVaccinations cv 
	ON cd.location = cv.location AND cd.date = cv.date
WHERE
	cd.continent is not null
ORDER BY
	2,3

--CTE
with totalVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT 
	cd.continent,
	cd.location,
	cd.date,
	population,
	cv.new_vaccinations,
	SUM(CONVERT (int, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
FROM
	CovidDeaths cd JOIN CovidVaccinations cv 
	ON cd.location = cv.location AND cd.date = cv.date
WHERE
	cd.continent is not null
)
SELECT *,
	(RollingPeopleVaccinated/Population)*100
FROM totalVac
ORDER BY 2,3

--using temp table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT 
	cd.continent,
	cd.location,
	cd.date,
	population,
	cv.new_vaccinations,
	SUM(CONVERT (int, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
FROM
	CovidDeaths cd JOIN CovidVaccinations cv 
	ON cd.location = cv.location AND cd.date = cv.date

SELECT *,
	(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated
ORDER BY 2,3

-- For Visualizations
GO
CREATE VIEW GlobalNumbers
AS
SELECT
	SUM(new_cases) as [Total Cases],
	SUM(CAST(new_deaths as int)) as [Total Deaths],
	[Death Percentage] = (SUM(CAST(new_deaths as int))/SUM(new_cases)*100)
FROM
	CovidDeaths
WHERE
	continent is not null

GO
CREATE VIEW PercentPopulationVaccinated
AS
SELECT 
	cd.continent,
	cd.location,
	cd.date,
	population,
	cv.new_vaccinations,
	SUM(CONVERT (int, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
FROM
	CovidDeaths cd JOIN CovidVaccinations cv 
	ON cd.location = cv.location AND cd.date = cv.date
WHERE
	cd.continent IS NOT NULL