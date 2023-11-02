# Bonus Questions
# Join All The Things
-- The following questions are related creating basic data tables that Danny and his team can use to quickly derive
--  insights without needing to join the underlying tables using SQL.

create view join_all as (
select b.customer_id , b.order_date , c.product_name , c.price , 
(case 
when b.customer_id in (select customer_id from members) and  b.order_date  >= (select join_date from members  where customer_id = "A") then "Y"
when b.customer_id = "A" and b.order_date  < (select join_date from members where customer_id = "A") then "N"
when b.customer_id = "B" and b.order_date  >= (select join_date from members  where customer_id = "B") then "Y"
when b.customer_id = "B" and b.order_date  < (select join_date from members  where customer_id = "B") then "N"
else NULL end) as members
from sales as b
join menu as  c 
on
b.product_id = c.product_id
)
select * from join_all


# Rank All The Things
# Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases 
# so he expects null ranking values for the records when customers are not yet part of the loyalty program.

create view ranking_all as(
with cte as(
select b.customer_id , b.order_date , c.product_name , c.price , 
(case 
when b.customer_id = "A" and b.order_date  >= (select join_date from members  where customer_id = "A") then "Y"
when b.customer_id = "A" and b.order_date  < (select join_date from members where customer_id = "A") then "N"
when b.customer_id = "B" and b.order_date  >= (select join_date from members  where customer_id = "B") then "Y"
when b.customer_id = "B" and b.order_date  < (select join_date from members  where customer_id = "B") then "N"
else NULL end) as members 
from members a left join
sales as b
on a.customer_id = b.customer_id
from sales as b
join menu as  c 
on
b.product_id = c.product_id
)
select customer_id, order_date,product_name,price ,members,
(case when members != "N" then rank() over(partition by customer_id,members order by order_date ) else 0 end) as rankings
from cte
)
select * from ranking_all

