SELECT * FROM [Portfolio Project]..CovidDeaths$
where continent is not null
ORDER BY 3,4

--SELECT * FROM [Portfolio Project]..CovidVaccinations$
--ORDER BY 3,4

Select location,date,total_cases,new_cases,total_deaths,population 
from [Portfolio Project]..CovidDeaths$
order by 1,2

--Looking at total cases vs total deaths
-- shows likelihood of dying if you contract Covid

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths$
Where location like '%states%'
order by 1,2

--Looking at totalcases vs population
--shows what percentage of population got covid
Select location,date,population,total_cases,(total_cases/population)*100 as Percent_population_infected
from [Portfolio Project]..CovidDeaths$
Where location like '%states%'
order by 1,2


--countries with highest Infection rate compared to population

Select location,population,max(total_cases) as highest_infection_count,max((total_cases)/(population))*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths$
--Where location like '%india%'
Group by location,population
order by PercentPopulationInfected desc

--Countries with highest death count per population
 Select location, max(total_deaths) as totalDeathCount
 from [Portfolio Project]..CovidDeaths$
 group by location
 order by totalDeathCount desc

 --Countries with highest death count per population (by chnaging toproper data type of total_deaths & applying a filter for continent is not null)
  Select location, max(cast (total_deaths as int )) as totalDeathCount
 from [Portfolio Project]..CovidDeaths$
 where continent is not  null
 group by location
 order by totalDeathCount desc

 -- Grouping by continet


  Select continent, max(cast (total_deaths as int )) as totalDeathCount
 from [Portfolio Project]..CovidDeaths$
 where continent is not  null
 group by continent
 order by totalDeathCount desc


  Select location, max(cast (total_deaths as int )) as totalDeathCount
 from [Portfolio Project]..CovidDeaths$
 where continent is   null
 group by location
 order by totalDeathCount desc

 --showing continents with highest death count per population

  Select continent, max(cast (total_deaths as int )) as totalDeathCount
 from [Portfolio Project]..CovidDeaths$
 where continent is not  null
 group by continent
 order by totalDeathCount desc

 --global numbers 

 --total death percentage in a world

Select SUM(new_cases) as totalCases,sum(cast (new_deaths as int)) as TotalDeaths,sum(cast (new_deaths as int))/sum(new_cases)*100
from [Portfolio Project]..CovidDeaths$
--Where location like '%states%'
where continent is not null
order by 1,2

--vaccinatio table
select *from [Portfolio Project]..CovidVaccinations$

--total population vs vaccination

Select deaths.continent,deaths.location,deaths.date,deaths.population,vacc.new_vaccinations,
SUM(CAST (vacc.new_vaccinations as int)) OVER (Partition by deaths.location order by deaths.location,deaths.date) as RollingPeopleVaccinated
from  [Portfolio Project]..CovidDeaths$ deaths
join  [Portfolio Project]..CovidVaccinations$ vacc
	on deaths.location= vacc.location
	and deaths.date=vacc.date
where deaths.continent is not null
order by 2,3

--use CTE

With PopvsVac(Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated) 
as
(
Select deaths.continent,deaths.location,deaths.date,deaths.population,vacc.new_vaccinations,
SUM(CAST (vacc.new_vaccinations as int)) OVER (Partition by deaths.location order by deaths.location,deaths.date) as RollingPeopleVaccinated
from  [Portfolio Project]..CovidDeaths$ deaths
join  [Portfolio Project]..CovidVaccinations$ vacc
	on deaths.location= vacc.location
	and deaths.date=vacc.date
where deaths.continent is not null
) 
select  * ,(RollingPeopleVaccinated/Population)*100 from PopvsVac

--Temp Table

DROP TABLE IF EXISTS PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RolligPeopleVaccinated numeric)

Insert into PercentPopulationVaccinated
Select deaths.continent,deaths.location,deaths.date,deaths.population,vacc.new_vaccinations,
SUM(CAST (vacc.new_vaccinations as int)) OVER (Partition by deaths.location order by deaths.location,deaths.date) as RollingPeopleVaccinated
from  [Portfolio Project]..CovidDeaths$ deaths
join  [Portfolio Project]..CovidVaccinations$ vacc
	on deaths.location= vacc.location
	and deaths.date=vacc.date
where deaths.continent is not null

select  * ,(RolligPeopleVaccinated/Population)*100 from PercentPopulationVaccinated


--creating view to store data for later visualisations

Create view pPercentPopulationVaccinated as 
Select deaths.continent,deaths.location,deaths.date,deaths.population,vacc.new_vaccinations,
SUM(CAST (vacc.new_vaccinations as int)) OVER (Partition by deaths.location order by deaths.location,deaths.date) as RollingPeopleVaccinated
from  [Portfolio Project]..CovidDeaths$ deaths
join  [Portfolio Project]..CovidVaccinations$ vacc
	on deaths.location= vacc.location
	and deaths.date=vacc.date
where deaths.continent is not null

select * from pPercentPopulationVaccinated
