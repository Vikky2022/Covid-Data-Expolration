select * from covidvaccination vac
join coviddeaths dea
on dea.location=vac.location and dea.date=vac.date;

Update covidvaccination
set new_vaccinations= case new_vaccinations when '' then Null else new_vaccinations
end;

update covidvaccination
set date=STR_TO_DATE(date, '%d-%m-%Y');

update coviddeaths
set date=STR_TO_DATE(date, '%d-%m-%Y');

update coviddeaths
set total_deaths= case total_deaths when '' then Null else total_deaths
end;

alter table coviddeaths
modify total_deaths bigint;

/*showing continent with the highest death count per population*/
select continent, max(total_deaths) as totaldeathcount
from coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc;

/*Global Numbers*/
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as deathpercentage from coviddeaths
where continent is not null
order by 1,2 ;


/* looking at total population vs vaccination*/

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.date)
from covidvaccination vac
join coviddeaths dea
on dea.location=vac.location and dea.date=vac.date;


/*use cte*/
with popuvsvac (continent, location, date, population, new_vaccinations, totalvaccination)
as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as totalvac from covidvaccination vac
join coviddeaths dea
on dea.location=vac.location and dea.date=vac.date
)
select * , format(( totalvaccination/population ) *100 , 5) as percentage_population_vaccinated  from popuvsvac order by location,date;



/* temp table*/
drop temporary table if exists percentpopulationvaccinated;
create temporary table percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population varchar(255),
new_vaccinations bigint,
rollingpeoplevaccinated bigint
);
insert into percentpopulationvaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as totalvac from covidvaccination vac
join coviddeaths dea
on dea.location=vac.location and dea.date=vac.date;

select * from percentpopulationvaccinated ;


/* creating view to store data for later visualization*/
create view percent_population_vaccinated as
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as totalvac from covidvaccination vac
join coviddeaths dea
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null;percent_population_vaccinated



