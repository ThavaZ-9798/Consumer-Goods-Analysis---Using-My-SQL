#Provide the list of markets in which customer "Atliq Exclusive" operates its
#business in the APAC region.

select distinct(market) from dim_customer
where customer = "Atliq Exclusive"
and region = "APAC";

# What is the percentage of unique product increase in 2021 vs. 2020?

with  unique_product_20 as (
select count(distinct(product_code)) as unique_product_2020
from fact_sales_monthly
where fiscal_year = 2020),

unique_product_21 as(
select count(distinct(product_code)) as unique_product_2021
from fact_sales_monthly
where fiscal_year = 2021)

select   unique_product_2020,
         unique_product_2021,
(unique_product_2021-unique_product_2020)*100/unique_product_2020 as percentage_chg
from unique_product_20 
cross join unique_product_21 ;
 
-- Provide a report with all the unique product counts for each segment and
-- sort them in descending order of product counts. The final output contains
-- 2 fields

select segment , count(distinct(product)) as product_count
from dim_product
group by segment
order by product_count desc;

#Which segment had the most increase in unique products in
#2021 vs 2020

with product_20 as 
(select segment, count(distinct(s.product_code)) as unique_product_2020
from dim_product p 
join fact_sales_monthly s 
on p.product_code = s.product_code
where fiscal_year = 2020
group by segment),
product_21 as (
select segment, count(distinct(s.product_code)) as unique_product_2021
from dim_product p 
join fact_sales_monthly s 
on p.product_code = s.product_code
where fiscal_year = 2021
group by segment)
select p20.segment , unique_product_2021 , 
       unique_product_2020,
       unique_product_2021-unique_product_2020 as Difference
       from product_20 p20
       cross join product_21 p21;
       
#Get the products that have the highest and lowest manufacturing costs.
(select p.product_code , p.product , m.manufacturing_cost
from dim_product p
join fact_manufacturing_cost m 
on p.product_code = m.product_code 
order by manufacturing_cost desc 
limit 1)
union
(select p.product_code , p.product , m.manufacturing_cost
from dim_product p
join fact_manufacturing_cost m 
on p.product_code = m.product_code 
order by manufacturing_cost asc
limit 1);

# Generate a report which contains the top 5 customers who received an
# average high pre_invoice_discount_pct for the fiscal year 2021 and in the
# Indian market. The final output contains these fields,

select c.customer , c.customer_code , concat(round(avg(p.pre_invoice_discount_pct),2),"%") as avg_discount
from dim_customer c
join fact_pre_invoice_deductions p
on c.customer_code = p.customer_code
where fiscal_year = 2021 and 
c.market = "India"
group by customer , customer_code
order by avg_discount desc
limit 5;

# Get the complete report of the Gross sales amount for the customer “Atliq
# Exclusive” for each month. This analysis helps to get an idea of low and
# high-performing months and take strategic decisions.

select monthname(s.date) as Month_name ,
s.fiscal_year as Years , 
round(sum(g.gross_price * s.sold_quantity)/1000000,2) as Gross_sales_amount_mln
from fact_sales_monthly s 
join dim_customer c 
on s.customer_code = s.customer_code
join fact_gross_price g 
on s.product_code = g.product_code
where c.customer = "Atliq Exclusive"
group by month_name , years
order by gross_sales_amount_mln asc;

#In which quarter of 2020, got the maximum total_sold_quantity? The final
# output contains these fields sorted by the total_sold_quantity

select 
case 
   when month(date) in (9,10,11) then "Q1"
   when month(date) in  (12,1,2) then "Q2"
   when month(date) in  (3,4,5)  then "Q3"
   when month(date) in  (6,7,8)  then "Q4"
end as Quater , sum(sold_quantity) as sold_qty
from fact_sales_monthly 
where fiscal_year = 2020
group by Quater
order by sold_qty desc ;

 # Which channel helped to bring more gross sales in the fiscal year 2021
# and the percentage of contribution

with sales_mln as 
(select c.channel , round(sum(s.sold_quantity * g.gross_price)/1000000,2) as gross_sales_mln
from fact_sales_monthly s 
join fact_gross_price g 
on s.product_code = g.product_code
join dim_customer c 
on s.customer_code = c.customer_code
where s.fiscal_year = 2021
group by c.channel
order by gross_sales_mln desc)
select  channel , gross_sales_mln , concat(round(gross_sales_mln*100/sum(gross_sales_mln) over(),2),"%") as pct_contribution
from sales_mln 
order by pct_contribution desc;

# Get the Top 3 products in each division that have a high
# total_sold_quantity in the fiscal_year 2021

with rank_order as 
(select p.division , s.product_code ,
p.product ,
sum(s.sold_quantity) as total_sold_qty,
dense_rank () over(partition by p.division order by sum(s.sold_quantity) desc) as rank_order  
from 
fact_sales_monthly s
join dim_product p 
on s.product_code = p.product_code
where s.fiscal_year = 2021
group by p.division,s.product_code,p.product)
select * from rank_order 
where rank_order in (1,2,3)
order by division , rank_order asc






































