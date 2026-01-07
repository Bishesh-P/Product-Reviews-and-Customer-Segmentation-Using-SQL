With sales_category as(
Select 
category,
Sum(sales_amount) as total_sales
from gold.fact_sales as s
left join gold.dim_products as p
on s.product_key = p.product_key
Group by category)

Select 
category,
total_sales,
Sum(total_sales)over() as overall_sales,
Concat(Round((cast(total_sales as float)/Sum(total_sales)over())*100,2),'%') as percentage_sales_category
from sales_category
