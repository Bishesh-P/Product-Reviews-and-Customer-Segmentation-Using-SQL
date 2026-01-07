With customer_spending as(
Select 
customer_key,
sum(sales_amount)as total_spending,
min(order_date)as first_date,
max(order_date)as last_date,
DATEDIFF(month, min(order_date), max(order_date)) as lifespan
from gold.fact_sales
group by customer_key)

Select 
customer_segment,
count(customer_key) as total_customers
from ( Select 
customer_key,
Case when lifespan >=12 and total_spending > 5000 then 'VIP'
	when lifespan>= 12 and total_spending <= 5000 then 'Regular'
	else 'New'
end as customer_segment
from customer_spending
)t
group by customer_segment





