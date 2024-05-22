select top 100 * from CovidDeaths order by 3,4;
select top 100 * from CovidVacinations;

-- select the data that i will be using 
select 
     location,
     date, 
     total_cases,
     new_cases,
     total_deaths,
     population_density
from CovidDeaths
where location like 'Canada%'
order by 1,2

-- Finding the Total Deaths percentage
-- Methode: total_deaths over total_cases * 100 
-- This shows the likelihood of dying if you contract covid in your country

select 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 as DearthPercentage
from CovidDeaths 
where location like 'Canada%'
order by 1,2;

-- Looking at the Total case vs the Population

select 
    location,
    date,
    population,
    total_cases,
    (total_cases / population)*100  PercentPopulationInfected
from CovidDeaths 
where location like '%state%'
order by 1,2;

-- Looking at Countries with Highest Infectious Rate Compared to the population

select 
    location,
    population,
    max(total_cases) highestInfectionCount,
    max((total_cases / population)*100)  MaxPercentPopulationInfected
from CovidDeaths 
group by location, population
order by MaxPercentPopulationInfected desc;

--Countries with the Highest Death Count per population

select 
    location,
    max(total_deaths) TotalDeathCount
from CovidDeaths 
where continent is not null
group by location
order by TotalDeathCount desc;

-- Looking at Continets with Highest Infectious Rate Compared to the population

select 
    location,
    max(total_deaths) TotalDeathCount
from CovidDeaths 
where continent is null
group by location
order by TotalDeathCount desc;

select 
    continent,
    max(total_deaths) TotalDeathCount
from CovidDeaths 
where continent is not null
group by continent
order by TotalDeathCount desc;

-- Global Numbers 

select   
    sum(new_cases) TotalCases,
    sum(new_deaths) TotalDeaths,
    sum(new_deaths) / sum(new_cases) * 100 DeathPercentage
from CovidDeaths 
where continent is not null
order by 1,2;

-- looking at the total populations Vs vacinations 

select 
   dea.continent,
   dea.location,
   dea.date, 
   dea.population,
   vac.new_vaccinations,
   sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from CovidDeaths dea
join covidVacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopVsVac(Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
AS
(
select 
   dea.continent,
   dea.location,
   dea.date, 
   dea.population,
   vac.new_vaccinations,
   sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from CovidDeaths dea
join covidVacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select * , (cast(RollingPeopleVaccinated as float)/ Population)*100
from PopVsVac
where Location = 'Albania'


select * ,
    Continent, 
    Location, 
    Date, 
    Population,
    New_Vaccinations, 
    (cast(RollingPeopleVaccinated as float) / Population) * 100
from (
    select 
    dea.continent,
    dea.location,
    dea.date, 
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from CovidDeaths dea
join covidVacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
) as PopVsVac


-- TEMP TABLE
drop table if exists #PercentagePopulationVacinated
create table #PercentagePopulationVacinated(
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME,
    Population BIGINT NULL,
    New_vaccinations INT NULL,
    RollingPeopleVaccinated FLOAT NULL
);


insert into #PercentagePopulationVacinated
select 
   dea.continent,
   dea.location,
   dea.date, 
   dea.population,
   vac.new_vaccinations,
   sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from CovidDeaths dea
join covidVacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;

select * , (cast(RollingPeopleVaccinated as float)/ Population)*100
from #PercentagePopulationVacinated
where Location = 'Albania';

-- creating view to store data for latter

create view PercentagePopulationVacinated as
select 
   dea.continent,
   dea.location,
   dea.date, 
   dea.population,
   vac.new_vaccinations,
   sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from CovidDeaths dea
join covidVacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;

select * from PercentagePopulationVacinated


