## 1. What are the standard ingredients for each pizza?
with cte as (
select 
a.pizza_id  ,c.topping_name , b.toppings from customer_orders as a 
join pizza_recipes as b
on a.pizza_id = b.pizza_id
join pizza_toppings c on b.toppings = c.topping_id
)
SELECT pizza_id, group_concat(distinct topping_name) as Standard_toppings
FROM CTE
GROUP BY pizza_id


## 2. What was the most commonly added extra?

with extras_cte as (
select order_id, pizza_id , substring_index(extras ,',',1) as extras
from customer_orders
union all
select order_id, pizza_id , substring_index(extras,', ',-1) as extras
from customer_orders
where length(extras) > 1 
)
select b.topping_name , count(a.extras) as count from extras_cte a 
join pizza_toppings b
on a.extras = b.topping_id
group by b.topping_name


## 3. What was the most common exclusion?

with exclusions_cte as (
select  order_id , pizza_id , substring_index(exclusions ,',',1) as exclusions
from customer_orders
union all
select order_id , pizza_id , substring_index(exclusions,', ',-1) as exclusions
from customer_orders
where length(exclusions) > 1 
)
select b.topping_name , count(a.exclusions) as count from exclusions_cte a 
join pizza_toppings b
on a.exclusions = b.topping_id
group by b.topping_name



## 4. Generate an order item for each record in the customers_orders table in the format of one of the following: of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

SELECT a.pizza_id , a.order_id,a.exclusions,a.extras,b.pizza_name,
CASE 
WHEN a.pizza_id = 1 AND a.exclusions is NULL AND a.extras is NULL THEN 'Meat Lovers'
WHEN a.pizza_id = 2 AND a.exclusions is NULL AND a.extras is NULL THEN 'Vegetarian'
WHEN a.pizza_id = 1 AND a.exclusions = '4' AND a.extras is NULL THEN 'Meat Lovers - Exclude Cheese'
WHEN a.pizza_id = 2 AND a.exclusions = '4' AND a.extras is NULL THEN 'Vegetarian - Exclude Cheese'
WHEN a.pizza_id = 1 AND a.exclusions is NULL AND a.extras = '1' THEN 'Meat Lovers - Extra Bacon'
WHEN a.pizza_id = 2 AND a.exclusions is NULL AND a.extras = '1' THEN 'Vegetarian - Extra Bacon'
WHEN a.pizza_id = 1 AND a.exclusions = '4' AND a.extras = '1, 5' THEN 'Meat Lovers - Exclude Cheese - Extra Bacon and Chicken'
WHEN a.pizza_id = 1 AND a.exclusions = '2, 6' AND a.extras = '1, 4' THEN 'Meat Lovers - Exclude BBQ Sauce and Mushroom - Extra Bacon and Cheese'
END AS order_item
FROM customer_orders a
join pizza_names b
on a.pizza_id = b.pizza_id

## 5. Generate an alphabetically ordered comma separated ingredient
-- list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
 

with cte as (
select 
a.pizza_id,a.extras,a.exclusions,a.customer_id,a.order_id  ,c.topping_name ,a.order_time, b.toppings,d.pizza_name from customer_orders as a 
join pizza_recipes as b
on a.pizza_id = b.pizza_id
join pizza_toppings c on b.toppings = c.topping_id
join pizza_names d on b.pizza_id = d.pizza_id
order by c.topping_name asc
),cte2 as (
SELECT pizza_id , group_concat(distinct topping_name order by topping_name asc ) as Standard_toppings
FROM CTE 
group by pizza_id
order by group_concat(distinct topping_name order by topping_name asc )
)
select a.order_id ,a.customer_id, a.pizza_id,a.exclusions,a.extras,a.order_time,
concat(a.pizza_name ,":"," 2x", b.Standard_toppings) as ingredient_list
from cte as a
join cte2 as b
on a.pizza_id = b.pizza_id
 
 
 ## 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
 
SELECT
	tpr.toppings,
    pt.topping_name,
	COUNT(tpr.toppings) AS qty_ingredient,
    pn.pizza_name
FROM temp_pizza_recipes tpr
JOIN temp_customer_orders tco ON tpr.pizza_id = tco.pizza_id
LEFT JOIN temp_runner_orders tro ON tro.order_id = tco.order_id
JOIN pizza_toppings pt ON pt.topping_id = tpr.toppings
JOIN pizza_names pn ON pn.pizza_id = tco.pizza_id
WHERE tro.cancellation != " "
GROUP BY tpr.toppings
ORDER BY qty_ingredient desc;