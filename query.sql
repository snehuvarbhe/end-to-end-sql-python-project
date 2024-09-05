create table df_orders(
	order_id int primary key,
	order_date date,
	ship_mode varchar(20),
	segment varchar(20),
	country varchar(20),
	city varchar(20),
	state varchar(20),
	postal_code varchar(20),
	region varchar(20),
	category varchar(20),
	sub_category varchar(20),
	product_id varchar(50),
	quantity int,
	discount decimal(7,2),
	sale_price decimal(7,2),
	profit decimal(7,2)
)
select * from df_orders;

/*Questions:*/
/*Find top 10 highest revenue generating products*/
select product_id,sum(sale_price) as sale_amount from df_orders
group by product_id
order by sale_amount desc
limit 10;

/*Find the top 5 highest selling products in each region*/
with cte as
(
select region,product_id,sum(sale_price) as sales
from df_orders
group by region,product_id
)
select * from 
(
select *,
rank() over(partition by region order by sales desc) as rnk 
from cte
) as a
where rnk<=5
 
/*Find month over month growth comparison for 2022 and 2023 sales*/
with cte as(
select extract(year from order_date) as order_year,extract(month from order_date) as order_month,
sum(sale_price) as sales from df_orders
group by order_year,order_month
)
select order_month,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month

/* For each category which month had highest sales*/
with cte as 
(
	select category,
	to_char(order_date,'yyyymm') month_each_year,
	sum(sale_price) as sales
from df_orders
group by category,month_each_year
order by category,month_each_year
)
select * from (
	select *,rank() over (partition by category order by sales desc) as rnk
	from cte
)
where rnk=1

/* Which subcategory had highest growth by profit in 2023 as compatred to 2022*/
with cte as (
	select sub_category,extract(year from order_date) as dt,sum(profit) as sales from df_orders
	group by sub_category,dt
	order by sub_category,dt
	),
	cte2 as(
		select sub_category,
		sum(case when dt=2022 then sales else 0 end) as sales_2022,
		sum(case when dt=2023 then sales else 0 end) as sales_2023
		from cte
		group by sub_category
		order by sub_category
		)
		select * ,(((sales_2023-sales_2022)*100)/sales_2022) as s
		from cte2
		order by s desc
		limit 1;


