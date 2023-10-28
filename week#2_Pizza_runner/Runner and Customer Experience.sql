## Runner and Customer Experience

##1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

select  week(registration_date , "2021-01-01") + 1  as weeks, count(runner_id) as runner_count 
from runners
group by weeks

## 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

with cte as (
select distinct a.order_id  , b.runner_id,	cast(timestampdiff(MINUTE,a.order_time,cast(b.pickup_time as datetime)) as float) as min  from customer_orders as a
join runner_orders as b on a.order_id = b.order_id 
where b.cancellation IS NULL )

select  runner_id , ceil(avg(min)) as average_time from cte 
group by runner_id

## 3 .Is there any relationship between the number of pizzas and how long the order takes to prepare?

with cte as (
select distinct a.order_id  , b.runner_id,	cast(timestampdiff(MINUTE,a.order_time,cast(b.pickup_time as datetime)) as float) as min  from customer_orders as a
join runner_orders as b on a.order_id = b.order_id 
where b.cancellation IS NULL )
,CTE1 AS(

SELECT 	ORDER_ID , COUNT(ORDER_ID ) AS PIZZA_COUNT
FROM CUSTOMER_ORDERS
GROUP BY ORDER_ID
)
SELECT A.ORDER_ID , A.MIN , B.PIZZA_COUNT
FROM CTE AS A 
JOIN CTE1 AS B
ON A.ORDER_ID= B.ORDER_ID

## 4.What was the average distance travelled for each customer?

update runner_orders
set distance = substring_index(distance , 'km' , 1)

select a.customer_id , avg(cast(
b.distance as float)) from customer_orders as a
join runner_orders as b
on a.order_id = b.order_id
where b.cancellation is null
group by a.customer_id

## 5. What was the difference between the longest and shortest delivery times for all orders?
# cleaning
update runner_orders
set cancellation = NULL
where cancellation = "" and cancellation = "null"
update runner_orders
set  duration = substring_index(duration , "m" , 1)

# Query
select max(duration),min(duration), max(duration) - min(duration) from runner_orders
where cancellation is null

## 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

update runner_orders
set duration = NULL
where duration = "null"
update runner_orders
set distance = NULL
where distance = "null"

select  order_id , distance , duration , runner_id ,round(avg(distance / duration),2) as speed 
from runner_orders
group by order_id, distance, duration,runner_id

## 7. What is the successful delivery percentage for each runner?

select * from runner_orders
select 
round((count( case when cancellation is null then 1 end) /
(count(case when cancellation  is not null then 1 end)+ count( case when cancellation is null then 1 end))*100 )) as percentage
from runner_orders 
group by runner_id