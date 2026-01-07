-- Segment products into cost ranges and count 
-- how many products fall into each segment
With product_cost_range as(
Select 
product_key,
product_name,
cost,
Case when cost < 100 then 'Below 100'
	 when cost between 100 and 500 then '100-500'
	 when cost between 500 and 1000 then '500-1000'
	 else 'above 1000'

end as cost_range
from gold.dim_products)

Select 
cost_range,
Count(product_key) as quantity
from product_cost_range
group by cost_range
order by quantity DESC



