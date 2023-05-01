-- total covid deathRate by location
select location, max(total_deaths) as totalDeaths, max(total_cases) as totalCases, sum(new_deaths)/sum(new_cases)*100 as deathRate
from portfolio1..coviddeath
where total_deaths is not null
group by location
order by totalDeaths desc


--covid deathrate India day-wsie
select date, location, total_deaths as totalDeaths, total_cases as totalCases, sum(new_deaths)/sum(new_cases)*100 as deathRate
from portfolio1..coviddeath
where location like '%India%' and total_deaths is not null
group by date,location,total_deaths,total_cases


--deaths vs country's avg life expectancy
select life_expectancy, location, max(total_deaths)as totalDeaths
from portfolio1..coviddeath
where life_expectancy is not null and total_deaths is not null
group by location, life_expectancy
order by life_expectancy desc


--total cases and deaths by continent
select continent, sum(new_deaths) as totalDeaths, sum(new_cases) as totalCases
from portfolio1..coviddeath
where continent is not null 
group by continent
order by totalDeaths desc


--total vaxxed vs total population
select dea.location, dea.population, sum(cast(vac.new_vaccinations as bigint)) as totalVaxed
from portfolio1..coviddeath dea
join portfolio1..covidvac vac
on dea.location=vac.location and dea.date=vac.date
where vac.new_vaccinations is not null
group by dea.location , dea.population
order by dea.population desc



--using CTE (to use rollingVac column)

with PoV  (continent, location, population, date, new_vaccinations, rollingVac )
as
(
select dea.continent , dea.location, dea.population, dea.date, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by vac.location, dea.date rows UNBOUNDED PRECEDING) as rollingVac
--(rollingVac/population)*100 (we cannot use rollingVac without including it in CTE or Temp table because it is not presentin the database)
from portfolio1..coviddeath dea
join portfolio1..covidvac vac
on dea.location=vac.location and dea.date=vac.date
)
select * , (rollingVac/population)*100 as lola
from PoV