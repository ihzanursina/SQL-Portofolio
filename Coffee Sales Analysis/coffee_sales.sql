#Dataset: https://www.kaggle.com/datasets/ihelon/coffee-sales

# Data Cleansing
# 1. Remove Duplicate
# 2. Standardize Data
# 3. Find NUll or Blank


use coffee;
show tables;

-- 1. Remove Duplicate

create table sale_st
like sale;

select * from sale_st;

insert into sale_st
select * from sale;

select card, date,count(*) 
from sale_st
group by card,date
having count(*)>1;

select * from sale_st
where card like '%002';

select card, date, datetime, count(*) 
from sale_st
group by card, date, datetime
having count(*)>1;


-- 2.  Standardize Data

select distinct cash_type, length(cash_type) as length
from sale_st;

select distinct card, length(card) as length
from sale_st;

select distinct coffee_name, length(coffee_name) as length, length(trim(coffee_name)) as clength
from sale_st;

select date, str_to_date(date,'%Y-%m-%d')
from sale_st;

update sale_st
set date = str_to_date(date,'%Y-%m-%d');

alter table sale_st
modify column date DATE;


select datetime, str_to_date(datetime,'%Y-%m-%d %H:%i:%s.%f') as time
from sale_st;

update sale_st
set datetime = str_to_date(datetime,'%Y-%m-%d %H:%i:%s.%f');

alter table sale_st
modify column datetime DATETIME;

alter table sale_st
modify column money decimal(10,2);


-- 3. Find NUll or Blank

select * from sale_st
where date is null
or datetime is null
or cash_type is null or cash_type = ''
or card is null or card = ''
or money is null
or coffee_name is null or coffee_name = '';


select * from sale_st
where cash_type = 'cash';

update sale_st
set card = 'none'
where card is null or card = '';


select * from sale_st;






