-- Dataset
-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

# Data Cleansing

use world_layoff;
show tables;


select *
from layoffs;


# 1. Remove Duplicate
# 2. Standardize Data
# 3. Find NUll or Blank
# 4. Remove any useless column


-- 1. Remove Duplicate


create table layoffs_staging
like layoffs;

select * 
from layoffs_staging;

insert layoffs_staging
select * from layoffs;

select *,
row_number() over(
partition by company,location, industry, total_laid_off, percentage_laid_off,
 `date`, stage, country, funds_raised_millions ) as rn
from layoffs_staging;

with duplicate_cte as
(
select *,
row_number() over(
partition by company,location, industry, total_laid_off, percentage_laid_off,
 `date`, stage, country, funds_raised_millions ) as rn
from layoffs_staging
)
select *
from duplicate_cte 
where rn > 1;

select * 
from layoffs_staging
where company = 'Cazoo';



with duplicate_cte as
(
select *,
row_number() over(
partition by company,location, industry, total_laid_off, percentage_laid_off,
 `date`, stage, country, funds_raised_millions ) as rn
from layoffs_staging
)
delete
from duplicate_cte 
where rn > 1;

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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * 
from layoffs_staging2;

insert into layoffs_staging2
select *,
row_number() over(
partition by company,location, industry, total_laid_off, percentage_laid_off,
 `date`, stage, country, funds_raised_millions ) as rn
from layoffs_staging;

SET SQL_SAFE_UPDATES = 0;

delete
from layoffs_staging2
where row_num > 1;

select * 
from layoffs_staging2;

-- 2. Standardize Data

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct industry
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where industry like 'crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like  'crypto%';

select distinct country
from layoffs_staging2
order by 1;

select * 
from layoffs_staging2
where country like 'United States%';

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

select * from layoffs_staging2;


select `date`,
str_to_date(`date`, '%m/%d/%Y' )
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y' );

select `date`
from layoffs_staging2;


alter table layoffs_staging2
modify column `date` date;

-- 3. Find Null or Blank

select * 
from layoffs_staging2;

select distinct stage
from layoffs_staging2;

select * 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;


select *
from layoffs_staging2
where industry is null
or industry = '';


select * 
from layoffs_staging2 as t1
join layoffs_staging2 as t2
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2
set industry = null
where industry = '';


update layoffs_staging2 as t1
join layoffs_staging2 as t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;

select distinct stage
from layoffs_staging2;

-- 4. Remove any useless column

select * 
from layoffs_staging2
where stage is null;


select * 
from layoffs_staging2 
where total_laid_off is null
and percentage_laid_off is null;


delete
from layoffs_staging2 
where total_laid_off is null
and percentage_laid_off is null;

alter table layoffs_staging2
drop column row_num;

select * from layoffs_staging2;

# Exploratory Data Analysis

select count(*)
from layoffs_staging2;

select avg(total_laid_off) as avg_laid_off, industry
from layoffs_staging2
where location = 'Jakarta'
group by industry
order by avg_laid_off desc;

select max(total_laid_off) as maximum_laid_off , max(percentage_laid_off) as maximum_percentage
from layoffs_staging2;

select * 
from layoffs_staging2
where percentage_laid_off = 1 
order by total_laid_off desc;

select * 
from layoffs_staging2
where percentage_laid_off = 1 
order by funds_raised_millions desc;

select company, sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by company
order by 2 desc;

select min(`date`) , max(`date`)
from layoffs_staging2;

select industry, sum(total_laid_off) total_laid_off
from layoffs_staging2
group by industry
order by 2 desc;

select country, sum(total_laid_off) total_laid_off
from layoffs_staging2
group by country
order by 2 desc;

select year(`date`), sum(total_laid_off)
from layoffs_staging2 
group by year(`date`)
order by 1 desc;

select stage, sum(total_laid_off)
from layoffs_staging2 
group by stage
order by 2 desc;


select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc;

with rolling_total as
(
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)
select `month`, total_off, sum(total_off) over (order by `month`) as sum_off
from rolling_total;


select company, year(`date`), sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by company,  year(`date`)
order by 3 desc;

with company_year(company,years,laid_off) as
(
select company, year(`date`), sum(total_laid_off) as total_off
from layoffs_staging2
group by company,  year(`date`)
),
company_year_rank as
(
select *, dense_rank() over (partition by years order by laid_off desc) as ranking
from company_year
where years is not null
)
select * 
from company_year_rank
where ranking <=5;


select * from layoffs_staging2;

select industry, year(`date`), sum(total_laid_off) as total_off
from layoffs_staging2
where `date` is not null and
total_laid_off is not null
group by industry, year(`date`)
order by year(`date`);

with industry_year (industry,years,laid_off) as 
(
select industry, year(`date`), sum(total_laid_off) as total_off
from layoffs_staging2
where `date` is not null and
total_laid_off is not null
group by industry, year(`date`)
order by year(`date`)
),
industry_year_rank as
(
select *, dense_rank() over ( partition by years order by laid_off desc) as ranking
from industry_year
)
select *
from industry_year_rank
where ranking <=5;



select count(*) 
from layoffs_staging2
where percentage_laid_off = 1;


select *
from layoffs_staging2
where percentage_laid_off = 1
order by industry;

select distinct industry, count(company) as total_off
from layoffs_staging2
where percentage_laid_off = 1
group by industry
order by total_off desc;

select distinct stage, count(company) as total_off, avg(year(`date`)) as avg_year
from layoffs_staging2
where percentage_laid_off = 1 and
stage != 'Unknown'
group by stage
order by total_off desc;

select distinct industry, count(company) as total_off, avg(year(`date`)) as avg_year
from layoffs_staging2
where percentage_laid_off = 1 and
stage != 'Uknown'
group by industry
order by total_off asc;




















