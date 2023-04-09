select * from menu;
select * from sales;
select * from members;

## Q1 Total amount spend by each customer
Select S.customer_id, Sum(M.price)
From Menu m
join Sales s
On m.product_id = s.product_id
group by S.customer_id;

## Q2 How many days customer visited the restauraunt
Select customer_id, count(distinct(order_date))
From Sales
Group by customer_id;

## Q3. What was the first item from the menu purchased by each customer?
with ranked_dates as (
select sales.customer_id , menu.product_name , sales.order_date,
dense_rank () over(partition by sales.customer_id order by sales.order_date ) as ranking
from sales
join menu 
on sales.product_id = menu.product_id
)
select customer_id , product_name from ranked_dates 
where ranking =1
group by product_name, customer_id;

## Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select  menu.product_name ,count(sales.product_id) as purchase_count from sales
join menu
on sales.product_id = menu.product_id
group by menu.product_name
order by purchase_count desc
limit  1;


## Q5. Which item was the most popular for each customer?

with count_items as (
select sales.customer_id ,menu.product_name , 
count(sales.product_id) as item_purchased ,
DENSE_RANK() over (Partition by sales.customer_id  order by count(sales.product_id) desc) as ranks
from sales
join menu on sales.product_id = menu.product_id
group by  sales.customer_id ,menu.product_name )

select customer_id ,
product_name, item_purchased
from count_items
where ranks = 1 ;


## Q6. Which item was purchased first by the customer after they became a member?
with first_product as(
select sales.customer_id,menu.product_name, members.join_date ,sales.order_date,
dense_rank() over (partition by sales.customer_id order by sales.order_date) as ranking
from sales
join menu
on sales.product_id = menu.product_id
join members on sales.customer_id = members.customer_id
where sales.order_date >= members.join_date
group by 1,2,3,4)
select customer_id ,  product_name from first_product
where ranking = 1
;
## Q7. Which item was purchased just before the customer became a member?

with first_product as(
select sales.customer_id,menu.product_name, members.join_date ,sales.order_date,
dense_rank() over (partition by sales.customer_id order by sales.order_date) as ranking
from sales
join menu
on sales.product_id = menu.product_id
join members on sales.customer_id = members.customer_id
where sales.order_date < members.join_date
group by 1,2,3,4)
select customer_id ,  product_name from first_product
where ranking = 1
;
## Q8. What is the total items and amount spent for each member before they became a member?

with items as (select sales.customer_id,sales.product_id, menu.product_name , members.join_date , sales.order_date , menu.price
from sales join menu
on sales.product_id = menu.product_id
join members on sales.customer_id = members.customer_id
)

select customer_id , count(product_id) as item_count , sum(price) as total_spent from items
where order_date < join_date
group by customer_id
order by total_spent desc;

## 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
with product_points as(
select product_name , price, sales.customer_id,
case when product_name = 'sushi' then  20*price
when product_name <> 'sushi' then 10*price end as points from menu
join sales on sales.product_id = menu.product_id 
)
select customer_id ,sum(points) from product_points 
group by customer_id; 


##10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
# not just sushi — how many points do customer A and B have at the end of January?


SELECT sales.customer_id, sales.order_date, menu.product_name, menu.price,
CASE
 WHEN members.join_date > sales.order_date THEN 'N'
 WHEN members.join_date <= sales.order_date THEN 'Y'
 ELSE 'N'
 END AS member
FROM sales 
LEFT JOIN menu 
 ON sales.product_id = menu.product_id
LEFT JOIN members 
 ON sales.customer_id = members.customer_id;