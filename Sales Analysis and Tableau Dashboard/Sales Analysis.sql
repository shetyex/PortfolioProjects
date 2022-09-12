-- Sales and profit analysis on fictional company dataset
-- Skills used: Joins, CTE's, Temp Tables, Date Functions, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

-- -- -- -- -- -- -- -- 

-- Data cleaning STEP 1:
-- In transactions table, there are some transactions in currency "USD"
-- Making new column as "normalised_sales" having all the values in "INR"
-- Filtering out Sales Quantities less than 1 and Sales Amount less than 1
-- Creating a View as "transactions2" with these changes

create view transactions2
as SELECT * ,
(case
when currency = "USD" then sales_amount*80
when currency = "INR" then sales_amount
end) as normalised_sales
from sales.transactions
where sales_amount > 0 and sales_qty > 0;

select * from transactions2;     -- took 0.860s

-- Another approach is creating new column in existing table itself
-- using alter table command

alter table transactions
add normalised_sales INT 
as (case
when currency = "USD" then sales_amount*80
when currency = "INR" then sales_amount
end) stored;

select * from transactions;     -- took 0.797s

-- view is more preferable since it takes almost same time
-- and filters are preapplied
-- using view "transactions2" henceforth
-- dropping column from original table

alter table transactions
drop column normalised_sales;

-- Data cleaning STEP 2:
-- In Markets table, filtering out "New York" and "Paris"
-- since they are redundant for this analysis
-- Creating a view as "markets 2" with these changes

create view markets2
as select *
from markets
where markets_name not In ("New York", "Paris");

select * from markets2;

-- -- -- -- -- -- -- -- 

-- Starting with Sales Analysis

-- Display all markets by descending revenue

select markets_name as "Market", sum(normalised_sales) as "Total Revenue"
from transactions2 join markets2
on transactions2.market_code = markets2.markets_code
group by markets_name
order by 2 desc;

-- Display all markets by descending sales quantity

select markets_name as "Market", sum(sales_qty) as "Total Sales Quantity"
from transactions2 join markets2
on transactions2.market_code = markets2.markets_code
group by markets_name
order by sum(sales_qty) desc;

-- Display top 5 customers by revenue

select custmer_name as "Customer Name", sum(normalised_sales) as "Total Revenue"
from transactions2 join customers
on transactions2.customer_code = customers.customer_code
group by custmer_name
order by 2 desc
limit 5;

-- Display top 5 products by revenue

select product_code as "Product Code", sum(normalised_sales) as "Total revenue"
from transactions2 join products
using (product_code)
group by product_code
order by 2 desc
limit 5;

-- Display top 5 markets by profitability

select markets_name as "Market", concat(round(sum(profit_margin)*100/sum(normalised_sales), 2) , "%") as "Profit Margin"
from transactions2 join markets2
on transactions2.market_code = markets2.markets_code
group by markets_name
order by 2 desc
limit 5;

-- Display top 5 products by profitability
select product_code as "Product", concat(round(sum(profit_margin)*100/sum(normalised_sales), 2) , "%") as "Profit Margin"
from transactions2 join products
using (product_code)
group by product_code
order by 2 desc
limit 5;

-- Display profitablity and revenue by date

select concat("Q", quarter(date)) as "Quarter", year(date) as "Year",
sum(normalised_sales) as "Total Revenue", concat(round(sum(profit_margin)*100/sum(normalised_sales), 2) , "%") as "Profit Margin"
from transactions2 join sales.date
on transactions2.order_date = date.date
group by 1, 2
order by 2, 1;





