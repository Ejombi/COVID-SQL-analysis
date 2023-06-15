SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [portfolio project].dbo.CovidDeaths$
order by 1,2


---looking at total cases vs population
---shows what percentage of population got covid

SELECT location,date,population,total_cases,(total_cases/population)*100  AS Percentagecontaminated
FROM [portfolio project].dbo.CovidDeaths$
WHERE location like '%came%'
 
order by 1,2

---countries with highest infected rate compared to population

SELECT location,population,MAX(total_cases) AS Highestinfectioncount,MAX((total_cases/population)*100)  AS Percentagecontaminated
FROM [portfolio project].dbo.CovidDeaths$
GROUP BY location,population
order by Percentagecontaminated desc


---showing countries with highest death count per population

SELECT location,MAX(Cast(total_deaths as int)) AS Totaldeathcount  
FROM [portfolio project].dbo.CovidDeaths$
where continent is not null
GROUP BY location
order by Totaldeathcount desc

--- breaking down by  continents
---continents with highest death count
SELECT continent,MAX(Cast(total_deaths as int)) AS Totaldeathcount  
FROM [portfolio project].dbo.CovidDeaths$
where continent is not  null
GROUP BY continent
order by Totaldeathcount desc

--- GLOBAL NUMBERS

	SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
	FROM [portfolio project]..CovidDeaths$
	WHERE continent is not null and total_cases is not null and total_deaths is not null
	GROUP BY date
	ORDER BY 1,2

---SUMM  GLOBAL OF CASES

SELECT  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
	FROM [portfolio project]..CovidDeaths$
	WHERE continent is not null
	ORDER BY 1,2
	
	
	SELECT *
	FROM [portfolio project]..CovidDeaths$ dea
	JOIN [portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	 
---looking at total population vs vaccination

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(CONVERT(INT,vac.new_vaccinations)) over (PARTITION BY dea.location ORDER BY dea.location,dea.date )AS  Rollingpeoplevacinated
	FROM [portfolio project]..CovidDeaths$ dea
	JOIN [portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	order by 2,3

	---using CTE

	with PopvsVac (Continent,Location,Date,Population,new_vaccinations,Rollingpeoplevacinated)
	as
	(
	SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(CONVERT(INT,vac.new_vaccinations)) over (PARTITION BY dea.location ORDER BY dea.location,dea.date ) AS  Rollingpeoplevacinated
	FROM [portfolio project]..CovidDeaths$ dea
	JOIN [portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
) 
select *, (Rollingpeoplevacinated/Population)*100
from PopvsVac


---using temp table
drop table if exists #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar (255),
location  nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
Rollingpeoplevacinated numeric
)

insert into  #percentpopulationvaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(CONVERT(INT,vac.new_vaccinations)) over (PARTITION BY dea.location ORDER BY dea.location,dea.date ) AS  Rollingpeoplevacinated
	FROM [portfolio project]..CovidDeaths$ dea
	JOIN [portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	--WHERE dea.continent is not null

	select *, (Rollingpeoplevacinated/Population)*100
from #percentpopulationvaccinated

---creating view to store data for later visualisations

Create View Percentpopulationvaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(CONVERT(INT,vac.new_vaccinations)) over (PARTITION BY dea.location ORDER BY dea.location,dea.date )AS  Rollingpeoplevacinated
	FROM [portfolio project]..CovidDeaths$ dea
	JOIN [portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--order by 2,3

SELECT *
FROM Percentpopulationvaccinated 

CREATE VIEW DeathPercentage as
SELECT  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
	FROM [portfolio project]..CovidDeaths$
	WHERE continent is not null
	---ORDER BY 1,2

