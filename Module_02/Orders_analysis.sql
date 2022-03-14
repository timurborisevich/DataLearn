--Data with filter by region "South" for 2018

--Total sales and profit
select
	region,
	round(sum(sales),2) as sales,
	round(sum(profit),2) as profit,
	round(sum(sales)/count(distinct order_id),2) as average_check,
	round(sum(profit)/count(distinct order_id),2) as order_average_profit
from 
	orders
where
	to_char(order_date, 'YYYY') = '2018' and
	region = 'South'
group by
	region
	
-- Sales and profit in dynamics by months
select 
	to_char(order_date, 'MM') as month,
	round(sum(sales),2) as sales,
	round(sum(profit),2) as profit
from 
	orders
where
	to_char(order_date, 'YYYY') = '2018' and
	region = 'South'
group by
	month

--Count orders and returns in dynamics by months
select 
	to_char(o.order_date, 'MM') as month,
	count(distinct o.order_id) as order_count,
	count(distinct r.order_id) as order_count_returns
from 
	orders as o
left join
	returns as r on o.order_id = r.order_id
where
	to_char(o.order_date, 'YYYY') = '2018' and
	o.region = 'South'
group by
	month

--Sales and profit by states
select
	state,
	round(sum(sales),2) as sales,
	round(sum(profit),2) as profit
from 
	orders
where
	to_char(order_date, 'YYYY') = '2018' and
	region = 'South'
group by
	state
order by sales desc

--Sales by cities
with sales_total as (	
	select 
		sum(sales) as sales_total 
	from 
		orders 
	where
		to_char(order_date, 'YYYY') = '2018' and
		region = 'South')		
select
	o.city,
	round(sum(o.sales),2) as sales,
	round(sum(o.sales)/st.sales_total*100 ,2) as sales_ratio
from 
	orders as o, sales_total as st
where
	to_char(order_date, 'YYYY') = '2018' and
	region = 'South'
group by
	city, st.sales_total
order by sales desc

--Sales and profit by categories
select
	category,
	round(sum(sales),2),
	round(sum(profit),2)
from
	orders
where
	to_char(order_date, 'YYYY') = '2018' and
	region = 'South'
group by
	category
	