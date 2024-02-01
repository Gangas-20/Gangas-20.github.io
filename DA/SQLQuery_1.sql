--SELECT *
--FROM CovidDeaths


-- select Data that we are going to be using 

SELECT location, date, total_cases , new_cases, total_deaths, population
FROM CovidDeaths 
Order by 1 ;

-- Looking at total cases vs total deaths 
-- shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases,total_deaths, (total_deaths/ total_cases) * 100 as deathpercentage
FROM CovidDeaths 
WHERE location like '%states%'
ORDER BY 2


-- Looking at the Total cases vs the population 
-- shows what percentage of population got covid 


SELECT Location, date, total_cases, population, (total_cases/population) * 100 as pctge_of_people_who_hv_covid
FROM CovidDeaths 
WHERE location like '%Nigeria%'
ORDER BY 2


-- looking at countries with highest infection rate compared to population 
SELECT Location, max(total_cases) as highestinfection_count  , max(population) as population, (max(total_cases)/max(population)) * 100 as infection_rate
FROM CovidDeaths 
Group by Location
ORDER BY infection_rate desc

-- showing countries with Highest death count per population.
SELECT Location, MAX(cast(total_deaths as int)) as total_deaths  , max(population) as population, (max(total_deaths)/max(population)) * 100 as death_rate_per_population
FROM CovidDeaths 
Group by Location
ORDER BY death_rate_per_population desc

-- LETS BREAK THINGS DOWN BY CONTINENT
SELECT Continent, MAX(cast(total_deaths as int)) as total_deaths  --, max(population) as population, (max(total_deaths)/max(population)) * 100 as death_rate_per_population
FROM CovidDeaths 
WHERE continent is not null
Group by continent 
ORDER BY total_deaths desc

-- HERE WE ALSO BREAK THINGS DOWN BY CONTINENT AGAIN BUT THE RESULTS HERE ARE SPECIFIC RESULTS IN THE DB ,


--SELECT Location, MAX(cast(Total_deaths as int)) as total_deaths 
--FROM CovidDeaths
--WHERE continent is null
--Group by location 
--ORDER BY Total_deaths desc

-- SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNTS PER POPULATION 

SELECT Location as Continent ,max(total_deaths) as total_death_count ,max(population) as population, (max(total_deaths)/ max(population)) as death_count_per_population  

   FROM CovidDeaths

    WHERE continent is null 

    GROUP BY Location 

    ORDER BY death_count_per_population desc

-- Global Numbers 


SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/ sum(new_cases)* 100 as death_percentage

FROM CovidDeaths

WHERE continent is not null
GROUP BY date 
Order by 1,2 


-- p


-- using a cte
WITH CTE (Continent, location, Date, population, New_vaccinations, sum_of_vac_by_ctry) as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
        SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,dea.date) as sum_of_vac_by_ctry
        
FROM CovidVaccinations as vac
INNER JOIN CovidDeaths as dea
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3
)

Select * , (sum_of_vac_by_ctry/ population) * 100
from CTE
Order by Location



-- TEMP TABLE 
Drop table if exists #percentpopulationVaccinated
create table #percentpopulationVaccinated(

 continent nvarchar (255),
 Location nvarchar(255),
 Date datetime,
 Population numeric, 
 New_vaccinations numeric, 
 sum_of_vac_by_ctry numeric )

insert into #percentpopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
        SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,dea.date) 
        as sum_of_vac_by_ctry
        
FROM CovidVaccinations as vac
INNER JOIN CovidDeaths as dea
    on dea.location = vac.location
    and dea.date = vac.date
--where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3

Select * ,(sum_of_vac_by_ctry/ population) * 100
from #percentpopulationVaccinated



--creating a view to store date for later visualizations 

CREATE VIEW PercentPopulationVaccinated as 
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS sum_of_vac_by_ctry
FROM 
    CovidVaccinations AS vac
INNER JOIN 
    CovidDeaths AS dea ON dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;


SELECT * 
from PercentPopulationVaccinated

