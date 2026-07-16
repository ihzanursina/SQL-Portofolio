use flight_data;
show tables;

select * from flight;

create table flight_st
like flight;

insert into flight_st
select * from flight;

select * from flight_st;

select flight_id, count(*)
from flight_st
group by flight_id
having count(*) > 1;


select *
from flight_st
where actual_departure is null;


select airline, round(avg(departure_delay),2) as delay_time
from flight_st
where cancelled = 0 and departure_delay > 0
group by airline
order by delay_time desc;


select 
case
	when extract(hour from scheduled_departure) between 5 and 11 then 'Morning'
    when extract(hour from scheduled_departure) between 12 and 17 then 'Afternoon'
    else 'Evening'
end	 as time_of_day,
round(avg(departure_delay),2) as delay_time
from flight_st
where cancelled = 0  and departure_delay > 0
group by time_of_day
order by delay_time desc;


select origin, round(avg(departure_delay),2) as delay_time
from flight_st
where cancelled = 0 and departure_delay > 0
group by origin
order by delay_time desc;


select * 
from flight_st
where cancelled = 0 and departure_delay > 0 and origin = 'BOS'
order by departure_delay desc;


select airline, round(avg(departure_delay),2) as delay_time, 
 sum(case when departure_delay > 0 then 1 else 0 end) as delay_count
from flight_st
where origin = 'BOS' and cancelled = 0 and departure_delay > 0
group by airline
order by delay_time desc;



with flight_times as (
select *,
case
	when extract(hour from scheduled_departure) between 5 and 11 then 'Morning'
	when extract(hour from scheduled_departure) between 12 and 17 then 'Afternoon'
	else 'Evening'
end as time_of_day
from flight_st
where origin = 'BOS' and cancelled = 0
)
select airline,  sum(case when departure_delay > 0 then 1 else 0 end) as delay_count, time_of_day
from flight_times
where time_of_day = 'Evening' 
group by airline, time_of_day
order by delay_count desc;


select airline, count(*) as total_flight, sum(cancelled) as total_cancel,
 round(sum(cancelled) * 100.0/ count(*),2) as cancel_percent
 from flight_st
 group by airline
 order by cancel_percent desc;
 
 
 select airline, count(*) as total_flight,
 sum(cancelled) as total_cancel, 
 sum(case when departure_delay > 0 then 1 else 0 end) as delay_count, 
 round(avg(departure_delay),2) as delay_time,
 round(sum(cancelled) * 100.0/ count(*),2) as cancel_percent, 
 round(sum(case when departure_delay > 0 then 1 else 0 end) * 100.0 / count(*),2) as delay_percent
 from flight_st
 group by airline
 order by delay_time desc;
 
 



    
