select * 
from PortfolioProject..covid_deaths
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covid_deaths
where continent is not null
order by 1,2

--looking at Total cases VS Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases, 0))*100 as DeathPercentage
from PortfolioProject..covid_deaths
where location = 'China'
order by 1,2

--Looking at the Total cases VS the population
--shows what percentage of the population got covid 

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..covid_deaths
--where location = 'Africa'
where continent is not null
order by 1,2

--looking at countries with highest infection rate compared to the population 

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..covid_deaths
--where location = 'Africa'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

--showing countries with Death count per population 

select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..covid_deaths
--where location = 'Africa'
where continent is not null
Group by location
order by TotalDeathCount desc

Create View PercentkakaVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..covid_deaths as dea
join PortfolioProject..covid_vaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3

select *
from PercentkakaVaccinated







--LET'S BREAK THINGS DOWN BY CONTINENT 

--showing the continent with the highest death per population 

select continent, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..covid_deaths
--where location = 'Africa'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL MEMBERS 

SELECT SUM(new_cases)  as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(NULLIF(new_cases, 0))*100 as DeathPercentage
from PortfolioProject..covid_deaths
--where location = 'China'
where continent is not null
--GROUP BY date
order by 1,2

--looking at total population vs vaccinations 

--use CTE

with Popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..covid_deaths as dea
join PortfolioProject..covid_vaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
from Popvsvac


--TEMP TABLE
Drop Table If exists #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
Continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..covid_deaths as dea
join PortfolioProject..covid_vaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
from #PercentPeopleVaccinated

--creating view to store for late visualizations 

Create View PercentPeopleVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..covid_deaths as dea
join PortfolioProject..covid_vaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3