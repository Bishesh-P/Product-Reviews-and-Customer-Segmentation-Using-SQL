-- Customer Report
/*
=====================================================================
Purpose: This report consolidates key customer merics and behaviours.
=====================================================================

Highlights:

1. Gather essential fields such as names, ages and transaction detail.
2. Segments customer into categories(VIP,Regular , New) and age groups
3. Aggregates customer level metrics:
		- total order
		- total sales
		-total quantity purchased
		- total products
		- lifespan(in months)

4. Calculate valuable KPIs
	- recency(months since last order)
	- average order value
	-average monthly spend

==============================================================================================================
*/
Create view gold_report_customer as
With base_query as(
Select s.sales_amount,
s.product_key,
s.order_date,
s.order_number,
s.quantity,
c.customer_key,
c.customer_number,
c.birthdate,
Concat(c.first_name,' ',c.last_name) as customer_name,
DATEDIFF(year,c.birthdate,getdate()) as age
from gold.fact_sales as s
left join gold.dim_customers as c
on s.customer_key = c.customer_key
where order_date is not null
)
,customer_aggregation as(
Select 
customer_key,
customer_number,
customer_name,
age,
Max(order_date) as last_order_date,
SUM(sales_amount) as total_sales,
Count(distinct product_key) as total_product,
Count(distinct order_number) as total_orders,
DATEDIFF(month, min(order_date),max(order_date)) as lifespan,
SUM(quantity) as total_quantity
from base_query
group by customer_key,
customer_number,
customer_name,
age)


Select age,
customer_number,
customer_key,
customer_name,
total_product,
total_orders,
total_sales,
DATEDIFF(month,last_order_date,getdate()) as recency_months,
total_quantity,
lifespan,
Case when age <20 then 'less than 20'
	when age between 20 and 29 then '20-29'
	when age between 30 and 39 then '30-39'
	when age between 40 and 49 then '40-49'
	else '50 and above'
end as age_group,
Case when lifespan >= 12 and total_sales > 5000 then 'VIP'
	when lifespan >=12 and total_sales <= 5000 then 'Regular'
	else 'New'
end as customer_details,
-- Average order value
Case when total_sales =0 then 0
     else total_sales/total_orders 
end as avg_order_value,

--Average Monthly Spend
Case when lifespan = 0 then total_sales
	else total_sales/lifespan
end as avg_monthly_spend
from customer_aggregation
