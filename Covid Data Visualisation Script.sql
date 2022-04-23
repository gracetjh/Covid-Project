-- Visualisation 1: Singapore's cases, death and death percentage as of today
select min(date) as startdate, max(date) as enddate, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from coviddeaths
where location = 'Singapore'



-- Visualisation 2: Death count in Asia by country
select location, max(total_deaths) as total_death_count,
case
	when max(total_deaths) >= 500000 then 'At least 0.5 million death'
	when max(total_deaths) between 100000 and 250000 then '100k - 250k death'
	when max(total_deaths) between 50000 and 100000 then '50k - 100k death'
	when max(total_deaths) between 25000 and 50000 then '25k - 50k death'
	when max(total_deaths) between 10000 and 25000 then '10k - 25k death'
	when max(total_deaths) between 5000 and 10000 then '5k - 10k death'
	else 'Less 5k death'
end as death_category
from coviddeaths
where continent = 'Asia'
group by location
having max(total_deaths)>1
order by total_death_count desc


-- Visualisation 3: Highest infection rate in Asia by country
select location, population, max(total_cases) as highest_infection_count, max(total_cases/population)*100 as infection_rate
from coviddeaths
where population is not null and continent ='Asia'
group by location, population
order by infection_rate desc



---- Visualisation 4:Date when Asia country has highest infection
--select location, population, date, max(total_cases) as highest_infection_count, max(total_cases/population)*100 as infection_rate
--from coviddeaths
--where population is not null and continent ='Asia'
--group by location, population, date
--order by location, date desc, infection_rate desc


-- Visualisation 4:Daily infection rate in Singapore
select location, population, date, new_cases, (new_cases/population)*100 as daily_infection_rate
from coviddeaths
where location='Singapore'
group by location, population, new_cases, date
order by location, date desc, daily_infection_rate desc
