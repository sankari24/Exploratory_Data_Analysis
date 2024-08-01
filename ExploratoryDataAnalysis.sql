-- EXPLORATORY DATA ANALYSIS PROJECT IN SQL
use project;

SELECT * 
FROM layoffs_staging2;  -- This table contain cleaned data

-- MAXIMUM PEOPLE LAID OFF
SELECT max(total_laid_off) 
from layoffs_staging2; 

SELECT * 
from layoffs_staging2 
where total_laid_off=12000;

-- maximum %laid off 
SELECT max(percentage_laid_off) 
from layoffs_staging2;  -- here 1 represents 100% which means all the employee in that company is left

SELECT * 
from layoffs_staging2 
where percentage_laid_off=1;

-- Count of the companies closed down
SELECT count(*) 
from layoffs_staging2 
where percentage_laid_off=1;

-- Count of the companies closed down starting from  big level company
SELECT * 
from layoffs_staging2 
where percentage_laid_off=1 
order by funds_raised_millions desc;

-- total laid off by each company
select company,sum(total_laid_off) 
from layoffs_staging2 
group by company 
order by 2 desc; -- 2 represents the second column

-- in which industries
select industry,sum(total_laid_off) 
from layoffs_staging2 
group by industry 
order by 2 desc;

-- in which countries
select country,sum(total_laid_off) 
from layoffs_staging2 
group by country 
order by 2 desc;

-- during which period
select min(date),max(date) 
from layoffs_staging2;

-- laid off in each year
select year(date) as year,sum(total_laid_off) 
from layoffs_staging2 
group by year 
order by 1;

select year(date) as year,sum(total_laid_off) 
from layoffs_staging2 
group by year 
order by 2 desc;

-- stages
select stage,sum(total_laid_off) 
from layoffs_staging2 
group by stage 
order by 1;

select stage,sum(total_laid_off) 
from layoffs_staging2 
group by stage 
order by 2 desc;

-- in every month
select substr(date,1,7) month,sum(total_laid_off) 
from layoffs_staging2 
where substr(date,1,7) is not null 
group by month 
order by month;

-- highest laid off month 
select substr(date,1,7) month,sum(total_laid_off) 
from layoffs_staging2 
where substr(date,1,7) is not null 
group by month 
order by 2 desc;

-- rolling total
with rolling_total_cte as
(select substr(date,1,7) month, sum(total_laid_off) as total_off
from layoffs_staging2 
where substr(date,1,7) is not null 
group by month 
order by 2 desc
)
select month, total_off,sum(total_off) over(order by month) as rolling_total 
from rolling_total_cte;


-- giving rank to companies based on laid off
with company_year as
(select company,year(date) as year,sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by company,year(date)
)
select *,dense_rank() over(partition by year order by total_laid_off desc) as Ranking 
from company_year
where year is not null
order by ranking asc;

-- top 5 companies in laid off in each year
with company_year as
(select company,year(date) as years,sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by company,years
),
company_ranking as
(select *,dense_rank() over(partition by years order by total_laid_off desc) as Ranking 
from company_year
where years is not null)
select * from company_ranking
where ranking<=5;

-- top 5 industries laid off in each year
with industry_year as
(select industry,year(date) as years,sum(total_laid_off) as laid_off 
from layoffs_staging2 
group by industry,years ),
industry_ranking as
(select *, dense_rank() over(partition by  years order by laid_off desc) as Ranking
from industry_year
where years is not null
)
select * from industry_ranking where ranking <=5;

-- top 5 countries laid off in each year
with country_year as
(select country,year(date) as years,sum(total_laid_off) as total_laid_off 
from layoffs_staging2 
group by country,years),
country_ranking as
(select *, dense_rank() 
over(partition by years order by total_laid_off desc) as Ranking 
from country_year where years is not null)
select * from country_ranking where ranking<=5;


-- top 5 stage laid off in each year
with stage_year as
(select stage,year(date) as years,sum(total_laid_off) as total_laid_off 
from layoffs_staging2 
group by stage,years),
stage_ranking as
(select *, dense_rank() 
over(partition by years order by total_laid_off desc) as Ranking 
from stage_year where years is not null)
select * from stage_ranking where ranking<=5;



