select * from subscriptions
select * from plans

select customer_id , start_date , price , rank () over( partion by customer_id order by start_date asc) as ranks

select  a.start_date, b.plan_name ,b.plan_id,b.price,
rank () over( partition by 
a.customer_id order by a.start_date ) as ranks ,a.customer_id
from subscriptions a 
join plans b
on a.plan_id = b.plan_id
where year(a.start_date) = 2020 and a.plan_id != 4
order by a.customer_id 
select * from subscriptions where customer_id 
 = 2
 select count(*) from subscriptions
 