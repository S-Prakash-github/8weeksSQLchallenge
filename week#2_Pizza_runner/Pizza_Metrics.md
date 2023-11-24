## PIZZA METRICS🍕

## Q1  How many pizzas were ordered?
```
SELECT COUNT(pizza_id) as Pizza_count FROM customer_orders;
```
> Output

## Q2 How many unique customer orders were made?
```
select count(distinct order_id ) as unique_order  from customer_orders ;
```
## Q3 How many successful orders were delivered by each runner?
```
with table1  as (
select   case when cancellation is null or cancellation like  'null' then 0 
		   when cancellation = '' then 0 else 1  end as cancellation , 
runner_id from runner_orders )
select runner_id ,count(runner_id) as order_delivered from table1 where cancellation = 0
group by runner_id;
```

## Q4 How many of each type of pizza was delivered?
```
with table1  as (
select   order_id , case when cancellation is null or cancellation like  'null' then 0 
		   when cancellation = '' then 0 else 1  end as cancellation , 
runner_id from runner_orders )

select count(table1.cancellation) as order_count , pizza_names.pizza_name from table1 
join customer_orders on table1.order_id = customer_orders.order_id
join pizza_names on  pizza_names.pizza_id = customer_orders.pizza_id 
where table1.cancellation = 0
group by pizza_names.pizza_name;
```
## Q5 How many Vegetarian and Meatlovers were ordered by each customer?
```
select  customer_orders.customer_id, pizza_names.pizza_name ,count(pizza_names.pizza_name)  from customer_orders
join pizza_names on customer_orders.pizza_id = pizza_names.pizza_id
group by  customer_orders.customer_id ,pizza_names.pizza_name 
order by customer_orders.customer_id;
```
## Q6 What was the maximum number of pizzas delivered in a single order?
```
with table1  as (
select   order_id , case when cancellation is null or cancellation like  'null' then 0 
		   when cancellation = '' then 0 else 1  end as cancellation , 
runner_id from runner_orders ),
table2 as (
select order_id,count(order_id) as pizza_count from customer_orders
group by order_id)
select max(table2.pizza_count) as max_pizza_deli from table2 
join table1 on table2.order_id = table1.order_id;
```
## Q7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
##### DATA CLEANING
```
update customer_orders
set exclusions = NULL
where exclusions = "" or exclusions = "null"
update customer_orders
set extras = NULL
where extras = "" or extras = "null"
select * from customer_orders
select * from runner_orders
```
###### Query
```
select a.customer_id, count(case when a.exclusions is not null or a.extras is not null then 1 end) as atleast_one,
count(case when a.exclusions is null and a.extras is null then 1 end ) as no_change 
from customer_orders as a join runner_orders as b
on a.order_id = b.order_id
where b.cancellation is null
group by a.customer_id

```
## Q8. How many pizzas were delivered that had both exclusions and extras?
##### DATA CLEANING
```
drop view  if exists runners_orders2;
create view  runners_orders2 as 
select order_id,runner_id,
case when pickup_time is null or pickup_time like 'null' then ''else pickup_time end as pickup_time,
case when distance is null or distance like 'null' then '' else distance end as distance,
case when duration like 'null' then '' else duration end as duration,
case when cancellation like 'null' or cancellation is null then 0 else 1 end as cancellation
from runner_orders;

drop view  if exists customer_orders2;
create view  customer_orders2 as 
select order_id , customer_id , pizza_id, 
case when exclusions like '' or exclusions is null or exclusions like 'null'  then 0 else 1 end as exclusions,
case when extras like 'null' or extras is null  or extras like '' then 0  else 1 end as extras 
from customer_orders;
```
###### Query
```
with order_delivered as 
(
select order_id , cancellation , runner_id from runners_orders2 where cancellation = 0  
),exclusion_extras as 
(
select order_id , pizza_id, customer_id from customer_orders2
where exclusions = 1  and extras = 1 
)

select count(customer_id) as exclusion_extra_p from exclusion_extras as e
join order_delivered as o  on
e.order_id = o.order_id;
```
## Q9. What was the total volume of pizzas ordered for each hour of the day?
```
select hour(order_time) as hours , count(order_id) as order_count from customer_orders
group by hour(order_time)
order by order_count desc;
```

## Q10. What was the volume of orders for each day of the week?
```
select dayname(order_time) as day_name , count(order_id) as volume  from customer_orders 
group by day_name
```
