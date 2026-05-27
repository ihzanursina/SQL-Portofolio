#Data set: https://www.kaggle.com/datasets/missionjee/car-sales-report?resource=download

# Data Cleansing
# 1. Remove Duplicate
# 2. Standardize Data
# 3. Find NUll or Blank
# 4. Remove any useless column

use car_sales;
select * from car;

-- 1. Remove Duplicate

create table car_st
like car;

select * from car_st;

insert car_st
select * from car;

ALTER TABLE car_st 
RENAME COLUMN `Customer Name` TO customer_name,
RENAME COLUMN `Annual Income` TO annual_income,
RENAME COLUMN `Price ($)` TO price,         
RENAME COLUMN `Body Style` TO body_style;       


select car_id, count(*) 
from car
group by car_id
having count(*)>1;

select date, customer_name, company, model, price, count(*)
from car_st
group by date, customer_name, company, model, price
having count(*)>1;

select *
from car_st
where customer_name = 'Amir' and company= 'oldsmobile' and model= 'intrigue';


-- 2.  Standardize Data

select distinct gender
from car_st;

select distinct Transmission
from car_st;

select distinct dealer_name
from car_st
order by 1;

select distinct Company
from car_st
order by 1;

select distinct model
from car_st
order by 1;

select distinct engine
from car_st;

select *
from car_st
where engine like 'double%';

update car_st
set engine = 'Double Overhead Camshaft'
where engine like 'double%';

select distinct body_style
from car_st;

select distinct color
from car_st;


select distinct dealer_region
from car_st
order by 1;

select *
from car_st
where Dealer_Region like 'midd%';

select distinct dealer_region, length(dealer_region) as len
from car_st
order by 1;

UPDATE car_st 
SET 
    customer_name = TRIM(customer_name),
    gender = TRIM(gender),
    company = TRIM(company),
    model = TRIM(model),
    body_style = TRIM(body_style),
    transmission = TRIM(transmission),
    color = TRIM(color),
    dealer_name = TRIM(dealer_name),    
    dealer_region = TRIM(dealer_region);
    
SELECT dealer_region, LENGTH(dealer_region), COUNT(*)
FROM car_st
WHERE dealer_region LIKE '%Middletown%'
GROUP BY dealer_region;

update car_st
set dealer_region= 'Middletown'
where dealer_region like '%Middletown%';

select `date`, str_to_date(`date`,'%m/%d/%Y')
from car_st;

update car_st
set `date`= str_to_date(`date`,'%m/%d/%Y');

select `date` from car_st;

alter table car_st
modify column `date` date;

select * from car_st;


-- 3. Find NUll or Blank

select * from car_st
where car_id is null or car_id = ''
or date is null
or customer_name is null or customer_name = ''
or annual_income is null
or price is null;

-- 4. Remove useless column

alter table car_st
drop column phone;

select * from car_st;



