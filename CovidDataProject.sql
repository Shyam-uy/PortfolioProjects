-- Covid 19 Data Exploration using Microsoft SQL Server 

select *
from CovidDataProject..CovidDeaths
order by 3,4


select *
from CovidDataProject..CovidVaccinations
order by 3,4

-- Selecting required Data to begin with

select location, date, total_cases, new_cases, total_deaths, new_deaths
from CovidDataProject..CovidDeaths
where location = 'India'
order by 1,2


-- Total Cases vs Total Deaths
-- Liklihood of dying if someone tested positive

-- In India

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDataProject..CovidDeaths
where location='India'
order by location, date

-- In USA

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDataProject..CovidDeaths
where  location like '%state%'
order by location, date


-- Countries sorted by highest number of cases in a single Day

select location, MAX(cast(new_cases as int)) as HighestCasesPercentage
from CovidDataProject..CovidDeaths
where continent is not null
group by location
order by HighestCasesPercentage desc

-- Conclusion: India reported maximum number of Cases in a single day


-- Total cases vs Population (country wise)
-- Shows percentage of population infected with covid

-- Population data is in CovidVaccinations table, so using Join

select dea.location, dea.date, vac.population, dea.total_cases, (total_cases/population)*100 as PercentagePopultaionInfected
from CovidDataProject..CovidDeaths dea
join CovidDataProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
order by location, date


-- Countries with Highest Death Count per Population

select location, MAX(convert(int,total_deaths)) as HighestDeathPercentage
from CovidDataProject..CovidDeaths
where continent is not null
group by location
order by HighestDeathPercentage desc

-- Conclusion: USA, Brazil and India have maximum number of losses due to Covid


-- Total Death Count by Continent

select continent, MAX(convert(int, total_deaths)) as TotalDeathCount
From CovidDataProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Conclusion: North America lost most lives due to Covid


-----------------------------------------------------------------------------------------------------------
-- Now, let's talk about vaccinations

-- Total Population vs Total Vaccination
-- Shows percentage of people who have recieved at least one dose of vaccine

select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location) as PeopleVaccinated
from CovidDataProject..CovidDeaths dea
join CovidDataProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by PeopleVaccinated desc

-- Conclusion: India has 2nd highest number of people vaccinated. While China is on top and US at 3rd.


-- Let's use WITH Clause to find percentage of people who got vaccinated

with PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location) as PeopleVaccinated
from CovidDataProject..CovidDeaths dea
join CovidDataProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select *, (PeopleVaccinated/population)*100
from PopvsVac


-- Using a Temporary table to find PercentPeopleVaccinated

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

--insert into #PercentPopulationVaccinated
--select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
--sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location) as PeopleVaccinated
--from CovidDataProject..CovidDeaths dea
--join CovidDataProject..CovidVaccinations vac
--	on dea.location = vac.location
--	and dea.date = vac.date

--select *, (PeopleVaccinated/population)*100
--from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
From CovidDataProject..CovidDeaths dea
Join CovidDataProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

-- View has been created to be used for Visualization.