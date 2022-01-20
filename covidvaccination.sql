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


/* looking at total population vs vaccination*/

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.date)
from covidvaccination vac
join coviddeaths dea
on dea.location=vac.location and dea.date=vac.date;


/*use cte*/
with popuvsvac (continent, location, date, population, new_vaccinations, totalvac)
as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as totalvac from covidvaccination vac
join coviddeaths dea
on dea.location=vac.location and dea.date=vac.date
)
select * ,( totalvac/population ) *100 from popuvsvac ;