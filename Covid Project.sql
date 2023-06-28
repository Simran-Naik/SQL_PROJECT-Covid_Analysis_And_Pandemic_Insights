Select * 
From Covid_Deaths
where continent is not null
order by 3,4

--Select * 
--From [Covid_vaccinations]
--order by 3,4

-- Select the data we are going to use

Select location,date,total_cases,new_cases,total_deaths,population
From [Covid_Deaths] where continent is not null order by 1,2 

-- looking at total case vs total deaths

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as "Death percentage"
From [Covid_Deaths] where continent is not null order by 1,2

-- deaths in india vs usa
-- shows likelihood of dying if you get covid

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as "Death percentage"
From [Covid_Deaths] where location like '__dia' and continent is not null order by 1,2

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as "Death percentage"
From [Covid_Deaths] where location like '%states%'and continent is not null order by 1,2

-- total cases vs population
-- shows what percentage of popultaion has got covid

Select location,date,population,total_cases,(total_cases/population)*100 as "percent of population infected"
From [Covid_Deaths] where location like '%states%'and continent is not null  order by 1,2

Select location,date,population,total_cases,(total_cases/population)*100 as "percent of population infected"
From [Covid_Deaths] where location like '__dia'and continent is not null   order by 1,2

-- countries with highest infection rate comapred to population

Select location,population,MAX(total_cases) as "Highest Infection Rate",MAX((total_cases/population))*100 as "percent population infected"
From [Covid_Deaths] where continent is not null group by population ,location order by "percent population infected" desc

--countries with highest death count per population

Select location,max(cast (total_deaths as bigint)) as  "Total Death Count"
From [Covid_Deaths] where continent is not null group by location order by "Total Death Count" desc

-- lets find the data continent wise
Select continent,max(cast (total_deaths as bigint)) as  "Total Death Count"
From [Covid_Deaths] where continent is not null group by continent order by "Total Death Count" desc

Select location,max(cast (total_deaths as bigint)) as  "Total Death Count"
From [Covid_Deaths] where continent is null group by location order by "Total Death Count" desc

--showing the continents with high death count per population

-- GLOBAL NUMBERS DATA

-- here we use cast to convert a datatype we can use cast or convert converting nvarchar into int
select date,sum(new_cases) as "Total cases",sum( cast (new_deaths as int)) as "Total deaths",sum(cast (new_deaths as int))/sum(new_cases) *100 as "Death percentage"
from Covid_Deaths where  continent is not null group by date order by 1,2

select sum(new_cases) as "Total cases",sum( cast (new_deaths as int)) as "Total deaths",sum(cast (new_deaths as int))/sum(new_cases) *100 as "Death percentage"
from Covid_Deaths where  continent is not null order by 1,2

Select * 
From [Covid_vaccinations]
order by 3,4

-- Total Population vs Total Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations from Covid_deaths dea join Covid_vaccinations vac on dea.location=vac.location and 
dea.date=vac.date where dea.continent is not null order by 2,3

--using rolling sum of new vaccinationseach day vacinnations are added to next one 

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum (convert (int,vac.new_vaccinations)) over 
(partition by dea.location order by dea.location,dea.date ) as "Rolling people  Vaccinations"  from Covid_deaths dea
-- CANNOT WRITEMULTIPLY HERE *100 (Rolling people  Vaccinations/POPULATION)*100 as we made this colum in this sentence and given an alias so we use cte with clause
join Covid_vaccinations vac on dea.location=vac.location and dea.date=vac.date where dea.continent is not null order by 2,3

-- USE CTE AS WE CANNOT MULTIPLY THE ROOLING PEOPLE VACCINATIONS INTO 100 TO GET THE POPULATION PERCENTAGE AS IT DOES NOT ALLOW BEACUSE WE HAVE MADE THE COLUM NAME IN 
--THE SAME LINE if no of columns in the cte is different from the columns specified in select it gives error and putting order by with cte gives error,always run the cte 
--below select commands

with populationvsvaccination (continent,location,date,population,new_vaccinations,"Rolling people  Vaccinations") as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum (convert (int,vac.new_vaccinations)) over 
(partition by dea.location order by dea.location,dea.date ) as "Rolling people  Vaccinations"  from Covid_deaths dea 
join Covid_vaccinations vac on dea.location=vac.location and dea.date=vac.date where dea.continent is not null 
)
select *,("Rolling people  Vaccinations"/population)*100 as "Rolling people vaccinations per populations" from populationvsvaccination 


-- TEMP TABLE

-- we have a made change in the table by commenting out where dea.continent is not null so we have made changes so to execute that we have to drop the previous table 
-- using drop table if exists then execute the below code again
drop table if  exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(225),location nvarchar(225),date datetime,population numeric,new_vaccinations numeric,"Rolling people  Vaccinations" numeric)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum (convert (int,vac.new_vaccinations)) over 
(partition by dea.location order by dea.location,dea.date ) as "Rolling people  Vaccinations"  from Covid_deaths dea 
join Covid_vaccinations vac on dea.location=vac.location and dea.date=vac.date ---where dea.continent is not null 

select *,("Rolling people  Vaccinations"/population)*100 as "Rolling people vaccinations per populations" from #PercentPopulationVaccinated

-- creating a view to store data for tableau and power bi

create view "percent population vaccinated" as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum (convert (int,vac.new_vaccinations)) over 
(partition by dea.location order by dea.location,dea.date ) as "Rolling people  Vaccinations"  from Covid_deaths dea 
join Covid_vaccinations vac on dea.location=vac.location and dea.date=vac.date where dea.continent is not null  --order by 2,3
-- go and check the view right click on percent population vaccinated and select top 1000 rows ctrl shift r to remove red lines

select * from "percent population vaccinated"

create view