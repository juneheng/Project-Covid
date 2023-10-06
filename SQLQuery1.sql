 --This is the portfolia of Covid-19 Data Exploration
 


 -- to take a look of the whole tables
 Select *
 From PorfolioProject..CovidDeaths
 --Continent is set to null when the location is the continent name not the country name
 Where continent is NOT NULL
 Order by 3, 4

 Select *
 From PorfolioProject..CovidVaccinations
 Where continent is not null
 Order by 3, 4

 -- select certain volumns for data exploration
 Select location, date, total_cases, new_cases, total_deaths, population
 From PorfolioProject..CovidDeaths
 Where continent is not null
 order by 1, 2
 

 -- check total cases vs total Deaths to show the chance of dying if get covid in Australia

 Select location, date, total_deaths, total_cases, (total_deaths / total_cases) *100 as DeathPercentage
 From PorfolioProject..CovidDeaths
 Where continent is not null 
 and location = 'Australia'
 order by 1, 2

 --check total cases vs population to show the ratio of infection

 Select location, date, total_cases, population, (total_cases / population) *100 as infectedPercentage
 From PorfolioProject..CovidDeaths
 Where continent is not null 
 and location = 'Australia'
 order by 1, 2

 -- Now let's check the countries with highest infected rate compared to population

Select location, population, max(total_cases) as HighestInfected_Country, max(total_cases / population) *100 as HighestInfected_Country_ratio
 From PorfolioProject..CovidDeaths
 Where continent is not null 
 Group by location, population
 order by HighestInfected_Country_ratio desc

 -- Check the countries with highest death 

Select location, max(cast(total_deaths as int)) as TotalDeath
 From PorfolioProject..CovidDeaths
 Where continent is not null 
 Group by location
 order by TotalDeath desc


--check the continent deaths situation
Select continent, max(cast(total_deaths as int)) as TotalDeathContinent
 From PorfolioProject..CovidDeaths
 Where continent is not null 
 Group by continent
 order by TotalDeathContinent desc

-- check the situation all over the grobal

Select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int)) / sum(new_cases) *100 as DeathPercentage
 From PorfolioProject..CovidDeaths
 Where continent is not null 
 Group by date
 Order by 1,2


 --Join deaths table and vaccination table to show :
 --1) Total Population vs Vaccinations
 --2)Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths as dea
Join PorfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	   and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--use the CTE
With popvsvac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths as dea
Join PorfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	   and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select *, RollingPeopleVaccinated/population *100 as vac_percentage
From popvsvac


--use temp table to insert data
DROP table if exists #vacpercentage
Create table #vacpercentage
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vac numeric,
	rollingPeopleVaccinated numeric
)

Insert into #vacpercentage
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths as dea
Join PorfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	   and dea.date = vac.date
--Where dea.continent is not null

Select *, rollingPeopleVaccinated/population * 100
From #vacpercentage


--create view for following data visualization
Create view #vacpercentage as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths as dea
Join PorfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	   and dea.date = vac.date
Where dea.continent is not null
