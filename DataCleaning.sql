--             DATA CLEANING PROJECT IN MYSQL

-- contains 4 main steps
   -- 1) removing duplicates
   -- 2) standardize the data
   -- 3) remove or populate null and blank values
   -- 4) removing unwanted columns

-- creating databases
create database project;
use project;

-- FOR TABLE CREATION
    -- for creating the table i am gonna import csv file
    -- for that in the schemas section under project db, right click on table and select table data import wizard and 
    -- select browse and choose our csv file and then next....next and then click finish


-- viewing the data
SELECT * from layoffs;

-- CREATING THE COPY OF THE TABLE
   -- its always best practice to work with copy of table rather than real one
   
create table layoffs_staging as select * from layoffs;
select * from layoffs_staging;

-- 1) REMOVING THE DUPLICATES

-- going to craete cte to spot the duplicates
with duplicate_cte as
(
select *, 
row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,date,
stage,country,funds_raised_millions) 
as row_numb 
from layoffs_staging
)
select * from duplicate_cte where row_numb>1;

-- viewing into each duplicates
select * from layoffs_staging where company='Elemy';

-- deleting with cte is not possible so we gonna create another table and 
-- add row_num column with it ,then deleting the row_num where id>1

-- TO CREATE ANOTHER TABLE
   -- right click on layoffs_staging table select copy to clipboard select create statement and paste it 
   -- and change the table nmae to 2 and add one more column row_num
   
   CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
   row_numb int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TO INSERT TABLE
   -- we gonna insert our all rows along with row number 
  
  
insert into layoffs_staging2
select *, row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,date,
stage,country,funds_raised_millions) 
as row_numb from layoffs_staging;

select * from layoffs_staging2;

select * from layoffs_staging2 where row_numb>1;

-- deleting the duplicates
delete from layoffs_staging2 where row_numb>1;

-- duplicates are deleted now

select * from layoffs_staging2 where row_numb>1;

select * from layoffs_staging2;

-- 2 )STADARDIZING THE DATA 

      -- findding the faults in the data and fixing it
select * from layoffs_staging2; 

-- COMPANY FIELD      
select distinct(company) from layoffs_staging2 order by company; -- company names are having spaces
select company,trim(company) from layoffs_staging2; -- triming that spaces
 
 -- updating it to our table     
 update layoffs_staging2
 set country=trim(country);
 -- after updating
select company,trim(company) from layoffs_staging2;

-- INDUSTRY FIELD
select distinct(industry) from layoffs_staging2; -- found some issues
select distinct(industry) from layoffs_staging2 order by industry; 

-- crypto , crypto currency,cryptocurrency means same
select * from layoffs_staging2 where industry like'crypto%'; -- upto 98 % specified the industry as crypto so let us update crypto currency, cryptocurrency as crypo
update layoffs_staging2 
set industry='Crypto'
where industry like "Crypto%";

select distinct(industry) from layoffs_staging2 order by industry;

-- LOCATION 
select distinct(location) from layoffs_staging2 order by location; -- pretty good

-- COUNTRY
 select distinct(country) from layoffs_staging2 order by country; -- one united states end with .
 -- update
 update layoffs_staging2 
 set country='United States'
 where country like "United States_";
 -- or another method for update
 -- update layoffs_staging2 
-- set country=trim(trailing '.' from country)
 -- where country like "United States%";
 
 -- updated value
select distinct(country) from layoffs_staging2 order by country;

-- DATE PORTION -- as we already seen date is in text format now it is time to convert
-- formatting the datatype
select date, str_to_date(date,'%m/%d/%Y') -- date represets our column name, %m/%d/%Y represents the format our data exists
from layoffs_staging2;

update layoffs_staging2
set date=str_to_date(date,'%m/%d/%Y');

-- but still datatype is not changed
-- converting the datatype
alter table layoffs_staging2
modify column date date;
select * from layoffs_staging2;

-- 3) REMOVING NULL OR BLANK VALUES

select * from layoffs_staging2 
where industry is null or industry=''; -- these values can be populated

select * from layoffs_staging2 
where company like 'Airbnb';  -- it seems like it is a travel 

select * from layoffs_staging2 
where company like 'Carvana'; -- it is a Transportation

-- rather than finding one by one and updating it we can update it by joins
-- updating blank values to null
select * from layoffs_staging2 
where industry is null or industry='';

update layoffs_staging2
set industry=null
where industry ='';

select t1.industry,t2.industry from layoffs_staging2 as t1
join  layoffs_staging2 as t2
on t1.company=t2.company
and t1.location=t2.location
where t1.industry is null  and t2.industry is not null;

-- updating it
update layoffs_staging2 t1
join  layoffs_staging2 as t2
on t1.company=t2.company
and t1.location=t2.location
set t1.industry=t2.industry
where t1.industry is null  and t2.industry is not null;

-- checking again for null values
select * from layoffs_staging2 
where industry is null or industry='';

-- still we are getting one maybe because it was the only one entry there is no other entries
-- so we can delete it
delete from layoffs_staging2 
where company like 'Bally\'s Interactive';

select * from layoffs_staging2 
where total_laid_off is null and percentage_laid_off is null; -- here both are null,so we dont have a choice except deleting it

delete from layoffs_staging2 
where total_laid_off is null and percentage_laid_off is null;

-- 4) REMOVING UNWANTED COLUMNS OR ROWS

alter table layoffs_staging2 
drop column row_numb;

-- Final Result
select * from layoffs_staging2;