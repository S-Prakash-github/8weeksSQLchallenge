## PIZZA METRICS🍕

## Q1  How many pizzas were ordered?

```
SELECT COUNT(pizza_id) as Pizza_count FROM customer_orders;
```
##### OUTPUT
| pizza_count |
|-------------|
|    14       |

##### EXPLANATION

- SELECT COUNT(pizza_id) AS Pizza_count: This part of the query calculates the count of non-null pizza_id values from the customer_orders table and aliases the result as Pizza_count.

- FROM customer_orders: This specifies the source table, indicating that the count is to be calculated from the customer_orders table.
- 
## Q2 How many unique customer orders were made?

```
SELECT 
    COUNT(DISTINCT order_id) AS unique_order
FROM 
    customer_orders;

```
##### OUTPUT 
| unique_order|
|-------------|
|    10       |


##### EXPLANATION
- SELECT COUNT(DISTINCT order_id) AS unique_order: This part of the query calculates the count of distinct order_id values from the customer_orders table and aliases the result as unique_order.

- FROM customer_orders: This specifies the source table, indicating that the count is to be calculated from the customer_orders table.

## Q3 How many successful orders were delivered by each runner?
```
WITH table1 AS (
    SELECT
        CASE
            WHEN cancellation IS NULL OR cancellation LIKE 'null' THEN 0
            WHEN cancellation = '' THEN 0
            ELSE 1
        END AS cancellation,
        runner_id
    FROM
        runner_orders
)
SELECT
    runner_id,
    COUNT(runner_id) AS order_delivered
FROM
    table1
WHERE
    cancellation = 0
GROUP BY
    runner_id;

```
##### OUTPUT
| Runner_ID | Order_Delivered |
|-----------|-----------------|
|     1     |        4        |
|     2     |        3        |
|     3     |        1        |

## Q4 How many of each type of pizza was delivered?
```
WITH table1 AS (
    SELECT
        order_id,
        CASE
            WHEN cancellation IS NULL OR cancellation LIKE 'null' THEN 0
            WHEN cancellation = '' THEN 0
            ELSE 1
        END AS cancellation,
        runner_id
    FROM
        runner_orders
)

SELECT
    COUNT(table1.cancellation) AS order_count,
    pizza_names.pizza_name
FROM
    table1
JOIN
    customer_orders ON table1.order_id = customer_orders.order_id
JOIN
    pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id
WHERE
    table1.cancellation = 0
GROUP BY
    pizza_names.pizza_name;
```
##### OUTPUT
| Order_Count | Pizza_Name  |
|-------------|-------------|
|      9      | Meatlovers  |
|      3      | Vegetarian  |

## Q5 How many Vegetarian and Meatlovers were ordered by each customer?
```
SELECT
    customer_orders.customer_id,
    pizza_names.pizza_name,
    COUNT(pizza_names.pizza_name) AS pizza_count
FROM
    customer_orders
JOIN
    pizza_names ON customer_orders.pizza_id = pizza_names.pizza_id
GROUP BY
    customer_orders.customer_id,
    pizza_names.pizza_name
ORDER BY
    customer_orders.customer_id;
```
##### OUTPUT
| Customer_ID | Pizza_Name  | Pizza_Count |
|-------------|-------------|-------------|
|     101     | Meatlovers  |      2      |
|     101     | Vegetarian  |      1      |
|     102     | Meatlovers  |      2      |
|     102     | Vegetarian  |      1      |
|     103     | Meatlovers  |      3      |
|     103     | Vegetarian  |      1      |
|     104     | Meatlovers  |      3      |
|     105     | Vegetarian  |      1      |

## Q6 What was the maximum number of pizzas delivered in a single order?
```
WITH table1 AS (
    SELECT
        order_id,
        CASE
            WHEN cancellation IS NULL OR cancellation LIKE 'null' THEN 0
            WHEN cancellation = '' THEN 0
            ELSE 1
        END AS cancellation,
        runner_id
    FROM
        runner_orders
),
table2 AS (
    SELECT
        order_id,
        COUNT(order_id) AS pizza_count
    FROM
        customer_orders
    GROUP BY
        order_id
)

SELECT
    MAX(table2.pizza_count) AS max_pizza_deli
FROM
    table2
JOIN
    table1 ON table2.order_id = table1.order_id;
```
##### OUTPUT
| max_pizza_deli |
|-----------------------|
|           3           |

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
##### Query
```
SELECT
    a.customer_id,
    COUNT(CASE WHEN a.exclusions IS NOT NULL OR a.extras IS NOT NULL THEN 1 END) AS atleast_one,
    COUNT(CASE WHEN a.exclusions IS NULL AND a.extras IS NULL THEN 1 END) AS no_change
FROM
    customer_orders AS a
JOIN
    runner_orders AS b ON a.order_id = b.order_id
WHERE
    b.cancellation IS NULL
GROUP BY
    a.customer_id;

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
##### Query
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
