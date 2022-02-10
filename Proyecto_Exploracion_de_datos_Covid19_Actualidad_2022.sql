/* Como se en cuentra el mundo en los primeros meses del 2022*/

/* Se Obtiene la data actualizada desde la pagina de la universidad de OXFORD en un solo
  Dataset  el cual se manipula para poder dividirlo en 2: A) Muertes_Covid. B)Vacunados_Covid.*/


  --visualizacion de las tablas

  select * from Covid_muertes
  select * from Covid_Vacunados


-- Exploracion de la tabla de muertes 

select * 
from [dbo].[Covid_muertes]
where continent is not null 
order by 3,4


-- estructurar los datos con los que se realizaran las consultas.

--Consultas a nivel global de la data.

select [location], [date], [population], total_cases, new_cases, total_deaths
from [dbo].[Covid_muertes]
where continent is not null 
order by 1,2


-- Total de casos Vs el Total de muertes.

-- Total de muertes desde el 2020 hasta los que llevamos del 2022.

SELECT continent, MAX(CAST(total_deaths as int)) as Total_Muertes
FROM [dbo].[Covid_muertes]
Where continent is not null 
Group By continent
Order BY Total_Muertes desc


-- Porcentaje de muertes a nivel mundial  en relacion a los nuevos casos 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
	   SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Porcent_Muerte
From [dbo].[Covid_muertes]
where continent is not null 
order by 1,2


-- La probabilidad de morir si contrae covid en al guno de estos continentes.

Select continent, Sum(total_cases ) as Total_Casos,
				  Sum(total_deaths) as Total_muertes,
				  (sum(total_deaths)/sum(total_cases))*100 as Porcentaje_muerte
from [dbo].[Covid_muertes]
where continent is not null
Group By continent
Order By Porcentaje_muerte desc


-- Top 10 de los paises con mayores coasos de contegio y muerte.

Select Top 5 [location], MAX(total_cases) as Total_Casos, Max(total_deaths) as Total_muertes
from [dbo].[Covid_muertes]
Group By [location]
order by Total_muertes desc

-- Top 10 de los paises con menores casos de contagios y muerte.

Select Top 10 [location], MIN(total_cases) as Total_Casos, MIN(total_deaths) as Total_muertes
from [dbo].[Covid_muertes]
Where [location] IS NOT NULL
Group By [location] 
order by Total_muertes desc



-- Total de Casos Versus la Poblacion mundial.
-- Porcentaje de la poblacion infectada con covid19

Select  [location], date,[population],total_cases as Total_Casos,
		(total_cases/[population])* 100 as Porc_Pob_Infect
from [dbo].[Covid_muertes]
Order By 1,2



--Paises con la tasa de infeccion más alta en comparacion con su poblacion. 

Select [location],[population], MAX(total_cases) as Recuento_Contagio,
								Max((total_cases/[population]))*100 as Porcentaje_Poblacioninfectada
From [dbo].[Covid_muertes]
Group By [location], [population]
Order By Porcentaje_Poblacioninfectada desc



-- Paises con mayor recuento de poblacion fallecida

Select [location],[population], MAX(total_deaths) as Recuento_Muertes,
								MAX((total_deaths/[population]))*100 as Porcentaje_PoblacionFallecida
From [dbo].[Covid_muertes]
Group By [location],[population]
Order By [Porcentaje_PoblacionFallecida] desc


--- Analisis situacional de Colombia.

--visualizacion del historico de colombia desde el 2020 al 2022.

Select [Location], date, total_cases as Total_Casos,total_deaths as Total_muertes,
				(total_deaths/total_cases)*100 as Percent_Muerte
From [dbo].[Covid_muertes]
Where [location] like '%Col%'
and continent is not null 
order by 1,2

--Porcentaje de la poblacion infectada en colombia.

Select  [location], [date], [population],total_cases as Total_Casos,
		(total_cases/[population])* 100 as Porc_Pob_Infect
from [dbo].[Covid_muertes]
Where [location]='Colombia'
Order By 1,2

--Porcentaje historico de poblacion fallecida en colombia.

Select location,date, population, total_deaths as Recuento_Muertes,
			(total_deaths/population)*100 as P_poblacionFallecida
from [dbo].[Covid_muertes]
Where location='Colombia'
Order by P_poblacionFallecida asc

---- Analisis con el dataset Covid_Vacunados

SELECT SUM(new_tests) FROM [dbo].[Covid_Vacunados]

--Porcentaje de población que ha recibido al menos una vacuna Covid.

Select m.continent, m.location, m.date, m.population, v.new_vaccinations,
 Sum(v.new_vaccinations) OVER  (Partition by m.location Order by m.location,m.date) as Personas_Vacunadas
From [dbo].[Covid_muertes] as m
join [dbo].[Covid_Vacunados] as  v
ON m.location = v.location
  and m.date = v.date
wHERE m.continent is not null
Order By 1,2 

--Uso de CTE para realizar el cálculo en la partición por en la consulta anterior

with PoblacionVsVacunas (continent,location,date,population,new_vaccinations,Personas_Vacunadas)
as
(
Select m.continent, m.location, m.date, m.population, v.new_vaccinations,
 Sum(v.new_vaccinations) OVER  (Partition by m.location Order by m.location,m.date) as Personas_Vacunadas
From [dbo].[Covid_muertes] as m
join [dbo].[Covid_Vacunados] as  v
ON m.location = v.location
  and m.date = v.date
wHERE m.continent is not null
)
Select *,(Personas_Vacunadas/population)*100  as Promedio_vac_mund from PoblacionVsVacunas

-- Creacion de una tabla temporal para calculos de la particion anterior

Drop table if  exists #Porcentaje_Poblacion_Vacunada
Create table #Porcentaje_Poblacion_Vacunada
(
Continent nvarchar (255),
[location] nvarchar(255),
[Date]  Datetime,
[Population] numeric,
new_vaccinations numeric,
Personas_Vacunadas numeric
)
Insert into #Porcentaje_Poblacion_Vacunada
Select m.continent, m.location, m.date, m.population, v.new_vaccinations,
 Sum(v.new_vaccinations) OVER  (Partition by m.location Order by m.location,m.date) as Personas_Vacunadas
From [dbo].[Covid_muertes] as m
join [dbo].[Covid_Vacunados] as  v
ON m.location = v.location
  and m.date = v.date
Where m.continent is not null
Select *,(Personas_Vacunadas/population)*100  as Promedio_vac_mund from #Porcentaje_Poblacion_Vacunada


-- Creacion de vistas para almacenar datos a futuro.

Create view Porcentaje_Personas_Vacunada
as
Select m.continent, m.location, m.date, m.population, v.new_vaccinations,
 Sum(v.new_vaccinations) OVER  (Partition by m.location Order by m.location,m.date) as Personas_Vacunadas
From [dbo].[Covid_muertes] as m
join [dbo].[Covid_Vacunados] as  v
ON m.location = v.location
  and m.date = v.date
Where m.continent is not null


/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [continent]
      ,[location]
      ,[date]
      ,[population]
      ,[new_vaccinations]
      ,[Personas_Vacunadas]
  FROM [PortafolioProyectoCovid19-2022].[dbo].[Porcentaje_Personas_Vacunada]















