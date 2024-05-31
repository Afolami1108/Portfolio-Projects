select *
from CovidDeaths
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
where location = 'nigeria'
order by 1,2


--Looking at Total Cases vs Population
-- Shows what percentage of population got covid
Select location, date, total_cases, Population, (total_cases/population)*100 as PercentageofInfectedPopulation
From CovidDeaths
--where location = 'nigeria'
order by 1,2

--Looking at Countries with Highest Infection Rate Compared to Population
select location, population, max(total_cases) as HigestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from CovidDeaths
--where location = 'nigeria'
group by location, population
order by 4 desc

--showing countries with Highest Death count per population
select location, population, max(cast(total_deaths as int)) as HigestDeathCount, max((total_deaths/population))*100 as PercentagePopulationDead
from CovidDeaths
--where location = 'nigeria'
where continent is not null
group by location, population
order by 3 desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location = 'nigeria'
where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

SELECT  sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as NewDeaths, (sum(cast(new_deaths as int))/ sum(new_cases))*100 as DeathPercentagePerNewCases                                                     
FROM CovidDeaths
WHERE continent IS not null
--group by date
order by 1,2


-- Looking at Total Population vs Vaccination
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)
from CovidDeaths Dea
join CovidVaccine Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
Where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (continent,Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)
from CovidDeaths Dea
join CovidVaccine Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
Where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE
Drop table if exists #temp_PercentPopulationVaccinated
Create Table #temp_PercentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date  datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccination numeric)

Insert into #temp_PercentPopulationVaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)
from CovidDeaths Dea
join CovidVaccine Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
Where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccination/Population)*100
from #temp_PercentPopulationVaccinated

--Creating View to stpre data for later visualization

Create View PercentPopulationVaccinated as 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)
from CovidDeaths Dea
join CovidVaccine Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
Where dea.continent is not null
--order by 2,3

select*
from PercentPopulationVaccinated