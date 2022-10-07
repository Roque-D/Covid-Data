Select * 
	From [Portfolio Project]..CovidDeaths
	order by 3,4

Select * 
	From [Portfolio Project]..CovidVaccinations$
	order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
	From [Portfolio Project]..CovidDeaths
	order by 1,2 

	--Looking at Total cases vs Total Deaths
	--Shows the likelihood of dying if you contracted Covid in the US

Select Location, date, total_cases, total_deaths, (Total_deaths / total_cases)*100 as Death_Percentage
	From [Portfolio Project]..CovidDeaths
	Where location like '%states%'
	order by 1,2 

Select Location, date, total_cases, total_deaths, (Total_deaths / total_cases)*100 as Death_Percentage
	From [Portfolio Project]..CovidDeaths
	Where location like '%states%'
	order by 1,2 
	
	--Looking at Total Casas vs Population

Select Location, date, total_cases, Population, (total_cases / population)*100 as Covid_Percentage
	From [Portfolio Project]..CovidDeaths
	Where location like '%states%'
	order by 1,2 


--What countries have the highest Infection rate compared to Population

Select Location, Population, MAX(total_cases) as Highest_Inection_Count, MAX((total_cases / population))*100 as Pop_Infected_Percent
	From [Portfolio Project]..CovidDeaths
	Group by Location, Population
	order by Pop_Infected_Percent desc


--What countries have the highest death count per population?

Select Location, MAX(cast(Total_deaths as int)) as Total_Death_Count
	From [Portfolio Project]..CovidDeaths
	Where continent is not null
	Group by Location
	order by Total_Death_Count desc

--Data broken down by Continent

Select continent, MAX(cast(Total_deaths as int)) as Total_Death_Count
	From [Portfolio Project]..CovidDeaths
	Where continent is not null
	Group by continent
	order by Total_Death_Count desc

--Global Numbers

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percent
	From [Portfolio Project]..CovidDeaths
	Where continent is not null
	Group by date 
	order by 1, 2

--Total Numbers

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percent
	From [Portfolio Project]..CovidDeaths
	Where continent is not null
	order by 1, 2

--Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as total_Pop_Vac
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 1,2,3

--USE CTE

With Pop_vs_Vac (Continent, Location, Date, Population,New_Vaccinantions, total_Pop_Vac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as total_Pop_Vac
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
)
Select *, (total_Pop_Vac/Population)*100
From Pop_vs_Vac


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_Pop_Vac numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as total_Pop_Vac
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null

Select *, (total_Pop_Vac/Population)*100
From #PercentPopulationVaccinated


--Create View to store data for later Visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as total_Pop_Vac
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

Select *
From PercentPopulationVaccinated

--Tableau Charts
--Chart 1

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as Death_Percentage
From [Portfolio Project]..CovidDeaths
where continent is not null 
order by 1,2

--Chart 2
Select location, SUM(cast(new_deaths as int)) as Total_Death_Count
From [Portfolio Project]..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by Total_Death_Count desc

-- 3.

Select Location, Population, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Percent_Pop_Infected
From [Portfolio Project]..CovidDeaths
Group by Location, Population
order by Percent_Pop_Infected desc

-- 4.

Select Location, Population,date, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Percent_Pop_Infected
From [Portfolio Project]..CovidDeaths
Group by Location, Population, date
order by Percent_Pop_Infected desc