select *
from PortfolioProject.dbo.CovidDeaths
order by 3,4

--select *
--from PortfolioProject.dbo.CovidVaccination
--order by 3,4

--Select data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
--Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2

--Looking at total cases vs population

--Show what percentage of population as got covid
Select location, date, population, total_cases, (total_cases/population)*100 as GotCovidPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as MaxGotCovidPercentage
from PortfolioProject.dbo.CovidDeaths
Group By location, population
order by  MaxGotCovidPercentage desc

--Showing countries with Highest death count per population
Select location, MAX(cast(total_deaths as INT)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
Group By location
order by  TotalDeathCount desc

--When you need to remove continents from the location category and then you can add it to query you have done
select *
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--Showing countries with Highest death count per population
Select location, MAX(cast(total_deaths as INT)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group By location
order by  TotalDeathCount desc

--Lets break things down by continent, Continent with the highest death count

Select location, MAX(cast(total_deaths as INT)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
Where continent is null
Group By location
order by  TotalDeathCount desc

--Global numbers (Looking at new cases according to date in the whole world)


Select date, SUM(new_cases) as TotalCases, Sum(cast(new_deaths as int)) As TotalDeath, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group By date
order by  1,2

--Global numbers (Looking at total death in the whole world)
Select SUM(new_cases) as TotalCases, Sum(cast(new_deaths as int)) As TotalDeath, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by  1,2

--Joining both data
Select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
   on dea.location= vac.location
   and dea.date= vac.date

--Looking at total population vs vaccination
Select dea.continent,  dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
   on dea.location= vac.location
   and dea.date= vac.date
 where dea.continent is not null
 order by 2,3



 --Use CTE
 With PopvsVac (continent, location, date,population ,new_vaccinations, RollingPeopleVaccinated)
 as
 (
 Select dea.continent,  dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
   on dea.location= vac.location
   and dea.date= vac.date
 where dea.continent is not null
 --order by 2,3
 )
 Select * , (RollingPeopleVaccinated/population)*100 as PercentPeopleVac
 from PopvsVac


 --TEMP TABLE

 DROP table if exists #PercentPopulationVaccinated
 CREATE table  #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccination numeric,
RollingPeopleVaccinated numeric,
)


 Insert into #PercentPopulationVaccinated
 Select dea.continent,  dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
   on dea.location= vac.location
   and dea.date= vac.date
 --where dea.continent is not null
 --order by 2,3

 Select * , (RollingPeopleVaccinated/population)*100 as PercentPeopleVac
 from #PercentPopulationVaccinated


 --Creating view to store data for later visualizations

 Create view PercentPopulationVaccinated as
  Select dea.continent,  dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
   on dea.location= vac.location
   and dea.date= vac.date
 where dea.continent is not null
 --order by 2,3

 Select *
 From PercentPopulationVaccinated