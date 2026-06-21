drop table if exists zepto;

create table zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discount_percent NUMERIC(5,2),
available_qty INTEGER,
disc_selling_price NUMERIC(8,2),
weight_in_grams INTEGER,
out_of_stock BOOLEAN,
quantity INTEGER
);

-- data exploration

--count of rows
select count(*) from zepto;

--Sample Data
SELECT * FROM ZEPTO
LIMIT 10;

--null values
select * from zepto where 
name is null
or
category is null
or
mrp is null
or
discount_percent is null
or
disc_selling_price is null
or
weight_in_grams is null
or
out_of_stock is null
or 
quantity is null;

-- Different Product Categories
select distinct category from zepto;

--Products in stock vs out of stock
select out_of_stock, count(*)
from zepto
group by out_of_stock;

--product names present multiple times
select name, count(*) as "Number of SKUs"
from zepto
group by name having
count(*)>1
order by count(*) desc;

--Data cleaning

--Product with price 0
select * from zepto 
where mrp = 0
or
disc_selling_price = 0;

delete from zepto
where mrp = 0;

--converting paise to rupees
update zepto
set mrp = mrp/100,
disc_selling_price = disc_selling_price/100;

select * from zepto limit 10;

-- 1. Finding the top 10 best-value products based on the discount percentage
select distinct * from zepto 
order by discount_percent desc limit 10;

--What are the products with high MRP but out of stock
select distinct name, mrp from zepto 
where out_of_stock = true 
and
mrp > 300
order by mrp desc;

--Calculate the estimated revenue for each category
select category, sum(disc_selling_price*available_qty) as revenue 
from zepto
group by category
order by sum(disc_selling_price*available_qty) desc;

--Find all the products where MRP is greater than Rs 500 and discount is less than 10%
select distinct name, mrp, discount_percent from zepto
where mrp > 500 and discount_percent < 10
order by mrp desc, discount_percent desc;

--Identify the top 5 categories offering the highest average discount percentage
select category, round(avg(discount_percent), 2) as avg_discount from zepto
group by category 
order by avg(discount_percent) desc
limit 5;

--Find the price per gram for products above 100g and sort by best value
select distinct 
name, 
disc_selling_price,
weight_in_grams,
round((disc_selling_price/weight_in_grams), 2) as price_per_gram
from zepto
where weight_in_grams > 100
order by price_per_gram;

--Group the products into categories like Low, Medium, Bulk based on available_qty
select distinct name, mrp, disc_selling_price, available_qty,
case ntile(3) over(order by available_qty)
	when 1 then 'low'
	when 2 then 'medium'
	when 3 then 'bulk'
end as qty_tag
from zepto;

--What is the total inventory weight per category
select distinct category, sum(available_qty * weight_in_grams) as inventory_weight
from zepto
group by category
order by inventory_weight desc;