--Select columns in data to use 
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by location, date

-- Provides cumulative view of total cases and total deaths, and likelihood of dying from covid in Singapore
select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where location = 'Singapore'
order by date desc

-- Shows percentage of Singapore's population infected with covid
select date, population, total_cases, (total_cases/population)*100 as infection_rate
from coviddeaths
where location = 'Singapore'
order by date desc

-- Countries with highest infection rate compared to population 
select location, population, max(total_cases) as highest_infection_count, max(total_cases/population)*100 as infection_rate
from coviddeaths
where population is not null
group by location, population
order by infection_rate desc

-- Death count by country
select location, max(total_deaths) as total_death_count
from coviddeaths
where continent is not null
group by location
order by total_death_count desc

-- Death count by continent
select location, max(total_deaths) as total_death_count
from coviddeaths
where continent is null and location in ('Asia', 'Europe', 'Africa', 'North America', 'South America', 'Oceania', 'World')
group by location
order by total_death_count desc

-- Death count by continent and country
select continent, location, max(total_deaths) as total_death_count
from coviddeaths
where continent is not null
group by continent, location
order by total_death_count desc

-- Daily cases, deaths and death percentage
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from coviddeaths
where continent is not null
group by date 
order by date desc

-- Worldwide cases, death and death percentage as of today
select max(date) as latest_date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from coviddeaths
where continent is not null
--group by date 
--order by date desc

-- Rolling count of vaccinations in Singapore and Malaysia
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location order by d.location,d.date) as rolling_vaccinations
from CovidDeaths as d
join CovidVaccinations as v
	on d.location = v.location
	and d.date = v.date
where d.continent = 'Asia' and d.location in ('singapore', 'malaysia')
order by 2,3

-- Method 1: use CTE to calculate percentage of population being vaccinated
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccinations) 
as 
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location order by d.location,d.date) as rolling_vaccinations
from CovidDeaths as d
join CovidVaccinations as v
	on d.location = v.location
	and d.date = v.date
where d.continent = 'Asia' and d.location in ('singapore', 'malaysia')
--order by 2,3
)
select *, (rolling_vaccinations/population)*100
from PopvsVac

-- Method 2: use TempTable to calculate percentage of population being vaccinated
drop table if exists percent_population_vaccinated
create table percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric
)

insert into percent_population_vaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location order by d.location,d.date) as rolling_vaccinations
from CovidDeaths as d
join CovidVaccinations as v
	on d.location = v.location
	and d.date = v.date
where d.continent = 'Asia' and d.location in ('singapore', 'malaysia')
--order by 2,3

select *, (rolling_vaccinations/population)*100
from percent_population_vaccinated

-- Create view to store data for later visualization
create view view_percent_population_vaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location order by d.location,d.date) as rolling_vaccinations
from CovidDeaths as d
join CovidVaccinations as v
	on d.location = v.location
	and d.date = v.date
where d.continent = 'Asia' and d.location in ('singapore', 'malaysia')
--order by 2,3
