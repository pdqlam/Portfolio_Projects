--Initial look at used Datasets

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 2,3

--Select *
--From PortfolioProject..CovidVaccinations
--Where continent is not null
--order by 3,4

-- Selecting Data that'll be used
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Comparing Total Cases vs Total Deaths in US
-- Looking at death rates in the US after contracting Covid

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Rate
From PortfolioProject..CovidDeaths
Where continent is not null
Where location like '%states%'
order by 1,2

-- Comparing Total Cases vs Population
-- Shows percentage of population that contracted Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as Infection_Rate
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
order by 1,2

-- Looking at Countries with highest Infection Rate compared to Population
Select Location, population, Max(total_cases) as Highest_Case_Count, Max((total_cases/population))*100 as Infection_Rate
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, population
order by Infection_Rate desc

-- Showing Countries with Highest Death Count per Population
Select Location, Max(cast(Total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by Total_Death_Count desc

-- Breakdown by Continent
Select location, Max(cast(Total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by Total_Death_Count desc



-- Global Numbers

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Death_Rate
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2


--Looking at Total Pop vs Vacc

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
, SUM(cast(cv.new_vaccinations as bigint)) 
OVER (Partition by cd.location Order by cd.location, cd.date) as Rolling_Vaccine_Count
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3

-- Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vaccine_Count)
as (
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
, SUM(cast(cv.new_vaccinations as bigint)) 
OVER (Partition by cd.location Order by cd.location, cd.date) as Rolling_Vaccine_Count
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
Select * , (Rolling_Vaccine_Count/Population)*100 as Rolling_Vacc_Rate 
From PopvsVac

-- TEMP TABLE
DROP Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Vaccine_Count numeric,
)

Insert into #Percent_Population_Vaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
, SUM(cast(cv.new_vaccinations as bigint)) 
OVER (Partition by cd.location Order by cd.location, cd.date) as Rolling_Vaccine_Count
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
--where cd.continent is not null
--order by 2,3

Select *, (Rolling_Vaccine_Count/Population)*100 as Rolling_Vacc_Rate
From #Percent_Population_Vaccinated

--Creating View to store data for later visualizations

Create View Percent_Pop_Vaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
, SUM(cast(cv.new_vaccinations as bigint)) 
OVER (Partition by cd.location Order by cd.location, cd.date) as Rolling_Vaccine_Count
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3

Select *
From Percent_Pop_Vaccinated