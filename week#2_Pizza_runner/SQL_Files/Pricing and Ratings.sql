## 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes -
-- how much money has Pizza Runner made so far if there are no delivery fees?

alter table pizza_names
add  column cost    int
UPDATE pizza_names
SET cost = CASE
    WHEN pizza_name = 'meatlovers' THEN 12
    WHEN pizza_name = 'vegetarian' THEN 10
    ELSE cost
END;

with cte as (
select a.order_id  , sum(b.cost) as total_cost from customer_orders a join pizza_names b
on a.pizza_id = b.pizza_id
group by a.order_id 
)
select sum(total_cost) as Amount from cte
where order_id in (select order_id from runner_orders where cancellation is null)

## 2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra

with extras_cte as (
select order_id, pizza_id , substring_index(extras ,',',1) as extras
from customer_orders
union all
select order_id, pizza_id , substring_index(extras,', ',-1) as extras
from customer_orders
where length(extras) > 1 
), cte3 as (
select order_id , sum(b.cost) as cost , sum(case when extras = 4  then 1 else 0 end ) as extra_cost
from extras_cte a join pizza_names b
on a.pizza_id = b.pizza_id
where a.order_id in (select order_id from runner_orders where cancellation is null)
group by order_id
)
select sum(cost) + sum(extra_cost) from cte3
where order_id in (select order_id from runner_orders where cancellation is null)


#3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional 
#table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (
order_id int,
rating int);

INSERT INTO ratings (order_id, rating)
SELECT order_id, 
    CASE
        WHEN efficiency * 100 BETWEEN 70 AND 80 THEN 4
        WHEN efficiency * 100 BETWEEN 50 AND 70 THEN 3
        WHEN efficiency * 100 > 90 THEN 5
        WHEN efficiency * 100 BETWEEN 35 AND 50 THEN 2
        ELSE 1
    END AS rating
FROM
    (
        SELECT order_id, ROUND((SUM(distance) / SUM(duration)), 2) AS efficiency
        FROM runner_orders
        WHERE order_id IN (SELECT order_id FROM runner_orders WHERE cancellation IS NULL)
        GROUP BY order_id
    ) AS inner_cte;

select * from ratings
    
#4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
#customer_id, order_id ,runner_id, rating ,order_time ,pickup_time, Time between order and pickup ,Delivery duration ,Average speed ,Total number of pizzas

select * from customer_orders
select * from runner_orders
select * from pizza_names
select * from pizza_toppings

with  pizza_count as(
select a.order_id, count(a.order_id) as pizza_count
from customer_orders a 
join runner_orders b
on a.order_id = b.order_id
group by a.order_id
)
select a.customer_id ,  b.order_id , b.runner_id,a.order_time , b.pickup_time ,c.rating,b.duration, avg(round(b.distance / b.duration,2)) as 'speed(km/m)',
d.pizza_count
from customer_orders a 
join runner_orders b
on a.order_id = b.order_id
join ratings c
on a.order_id = c.order_id
join pizza_count d
on a.order_id = d.order_id
group by a.customer_id ,  b.order_id , b.runner_id,a.order_time , b.pickup_time ,c.rating,b.duration,'speed(km/m)',
d.pizza_count


##5 . If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each
# runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

 select (sum(b.cost) - 
 (select sum(distance)*0.30 from runner_orders where order_id in (select order_id from runner_orders where cancellation is null) )) 
 as remaining from customer_orders a
 join pizza_names b
 on a.pizza_id= b.pizza_id
where a.order_id in (select order_id from runner_orders where cancellation is null)
