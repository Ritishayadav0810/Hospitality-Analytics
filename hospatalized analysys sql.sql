# TOTAL BOOKINGS
SELECT  SUM(successful_bookings) AS TOTAL_BOOKINGS
FROM fact_aggregated_bookings;

#total revenue
select sum(revenue_realized) as total_revenue
from fact_bookings;

#occupancy 
select concat(round((sum(successful_bookings)/sum(capacity))*100,2),'%') as occupancy_rate
from fact_aggregated_bookings;

#cancelation rate
select (count(case when booking_status="cancelled" then 1 end)/count(booking_status)*100) as cancallation_rate
from fact_bookings;

alter table dim_date rename column date to check_in_date;
set sql_safe_updates=0;
update dim_date set check_in_date = str_to_date(check_in_date,'%d-%b-%y');
alter table dim_date modify column check_in_date date;


#trend analysis
select monthname(dim_date.check_in_date) as month_name,concat(round(sum(revenue_realized)/1000000,2),'M')revenue
from fact_bookings join dim_date
on dim_date.check_in_date=fact_bookings.check_in_date
group by month_name
order by revenue desc;

#weekday & weekend revenue 
select dim_date.day_type as Daytype,concat(round(sum(revenue_realized)/1000000,2),'M')revenue
from fact_bookings join dim_date
on dim_date.check_in_date=fact_bookings.check_in_date
group by dim_date.day_type
order by revenue ;

#weekday&weekend bookings
select dim_date.day_type as Daytype, count(fact_bookings.booking_id) Booking
from fact_bookings join dim_date
on dim_date.check_in_date=fact_bookings.check_in_date
group by dim_date.day_type
order by Booking desc;

#BOOKINGS BY CITY 
SELECT dim_hotels.city as Cityname, concat(round(count(fact_bookings.booking_id)/1000,2),'K') Booking
from fact_bookings join dim_date 
on fact_bookings.property_id= dim_hotels.property_id
group by cityname
order by Booking desc; 

#revenue by city
select dim_hotels.city as cityname , concat(round(count(fact_bookings.revenue_realized)/1000000,2),'M') revenue
from fact_bookings join dim_date 
on fact_bookings.property_id= dim_hotels.property_id
group by cityname
order by revenue desc;


# bookings by property name
select dim_hotels.property_name as hotel, concat(round(count(fact_bookings.booking_id)/1000,2),'K') Booking
from fact_bookings join dim_hotels 
on fact_bookings.property_id= dim_hotels.property_id
group by hotel
order by Booking desc;



#revenue by property name
select dim_hotels.property_name as hotel , concat(round(count(fact_bookings.revenue_realized)/1000000,2),'M') revenue
from fact_bookings join dim_hotels 
on fact_bookings.property_id= dim_hotels.property_id
group by hotel
order by revenue desc;

#class wise revenue
select dim_rooms.room_class as roomclass ,concat(round(count(fact_bookings.revenue_realized)/1000000,2),'M') revenue
from fact_bookings join dim_rooms on fact_bookings.room_category=dim_rooms.room_id
group by roomclass
order by revenue desc;

#checked out cancel no show
select booking_status ,concat(round(count(fact_bookings.revenue_realized)/1000000,2),'M') revenue
from fact_bookings
group by booking_status;