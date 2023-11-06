
## 1. How many customers has Foodie-Fi ever had?
select count(distinct(customer_id)) from subscriptions


## 2. What is the monthly distribution of trial plan start_date values for our dataset 
-- use the start of the month as the group by value

SELECT 
MONTHNAME(start_date) as month_name, month(start_date) as month_num ,count(plan_id) as trial_plan_count from subscriptions
where plan_id = 0
group by month(start_date) ,1
order by month(start_date) asc


## 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

select a.plan_id,b.plan_name , count(a.start_date)  from subscriptions a
join plans b 
on a.plan_id = b.plan_id
where year(a.start_date) > 2020
group by 1,2
order by 1,2


## 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

with cte as (select count(distinct(customer_id)) as churn from subscriptions
where plan_id = 4 
)
select  churn , round((churn / (select count(distinct (customer_id)) as total_customers from subscriptions)*100) , 1) as percentage  from cte

## 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

with cte as (
select  a.start_date, b.plan_name ,b.plan_id,b.price,
rank () over( partition by 
a.customer_id order by a.start_date ) as ranks ,a.customer_id
from subscriptions a 
join plans b
on a.plan_id = b.plan_id
order by a.customer_id 
)
select count(customer_id) as churn_count , round(((count(customer_id)  / (select count(distinct(customer_id )) from  subscriptions))*100)) as percentage
from cte
where plan_id = 4 and ranks = 2

## 6. What is the number and percentage of customer plans after their initial free trial?
--create number and percentage
select * from subscriptions
select * from plans

with cte as (
select  a.start_date, b.plan_name ,b.plan_id,b.price,
lead (b.plan_id,1,0) over( partition by 
a.customer_id order by b.plan_id ) as next_plan ,a.customer_id
from subscriptions a 
join plans b
on a.plan_id = b.plan_id
order by a.customer_id 
)
SELECT c.next_plan,
COUNT(DISTINCT customer_id) AS customer_count,
(100 * CAST(COUNT(DISTINCT customer_id) AS FLOAT) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions)) AS percentage
FROM cte c
LEFT JOIN plans p 
ON p.plan_id = c.next_plan
WHERE c.plan_id = 0 
AND c.next_plan != 0 
GROUP BY c.next_plan
	

## 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

with cte as (
select  a.start_date, b.plan_name ,b.plan_id,b.price,
lead (a.start_date,1) over( partition by 
a.customer_id order by a.start_date ) as next_date ,a.customer_id
from subscriptions a 
join plans b
on a.plan_id = b.plan_id
where a.start_date <= "2020-12-31"
order by b.plan_id
)
select plan_id , count(distinct customer_id) as customer_count , 
round(100 * count(distinct customer_id) / (select count(distinct customer_id) from  subscriptions) ,1) as percentage from cte
where start_date <= "2020-12-31" and next_date is NULL
group by plan_id
 



## 8. How many customers have upgraded to an annual plan in 2020?

select count(distinct(customer_id)) as customers_count from subscriptions where year(start_date) = 2020 and plan_id  = 3


## 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

with cte as (
select distinct customer_id , min(start_date) as purchase_date from subscriptions where plan_id = 3
group  by customer_id 
),
cte1 as(
select distinct customer_id , min(start_date) as first_date from subscriptions 
group by customer_id)

select  floor(avg(datediff(a.purchase_date , b.first_date))) as avg_upgrade_days from cte a 
join cte1 b 
on a.customer_id = b.customer_id


## 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
select * from customer_nodes
select * from plans
select * from subscriptions

WITH trial_plan AS (
    SELECT customer_id, 
       start_date AS trial_date
    FROM subscriptions
    WHERE plan_id = 0
),
annual_plan AS (
    SELECT customer_id,
       start_date as annual_date
    FROM subscriptions
    WHERE plan_id = 3
)

SELECT
    CONCAT(floor(DATEDIFF(annual_date, trial_date) / 30) * 30, '-',floor(DATEDIFF(annual_date, trial_date) / 30) * 30 + 30, ' days') AS period,
    COUNT(*) AS total_customers,
    ROUND(AVG(DATEDIFF(annual_date, trial_date)), 0) AS avg_days_to_upgrade
FROM trial_plan tp
JOIN annual_plan ap ON tp.customer_id = ap.customer_id
WHERE ap.annual_date IS NOT NULL
GROUP BY 1
order by 2



## 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

with cte as(
select customer_id , plan_id,
       start_date, lead(plan_id) over (partition by customer_id order by plan_id ) as  next_plan
       from subscriptions
       )
       select count(customer_id) as downgraded from cte 
       where plan_id > next_plan

