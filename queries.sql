--считает общее количество клиентов

select count(*) as customers_count
from customers

--Топ 10 продавцов с наибольшей выручкой

SELECT concat(e.first_name, ' ', e.last_name) as name, count(s.sales_id) as operations, 
round(sum(p.price * s.quantity), 0) as income
FROM employees e
inner join sales s on e.employee_id = s.sales_person_id
inner join products p on p.product_id = s.product_id 
group by concat(e.first_name, ' ', e.last_name)
order by round(sum(p.price * s.quantity), 0) desc
limit 10

--Продавцы, чья выручка ниже средней выручки всех продавцов


with cte1 as (
SELECT concat(e.first_name, ' ', e.last_name) as name, round( avg(p.price * s.quantity), 0) as average_income
FROM employees e
inner join sales s on e.employee_id = s.sales_person_id
inner join products p on p.product_id = s.product_id 
group by concat(e.first_name, ' ', e.last_name)
order by round(avg(p.price * s.quantity), 0) asc ),

cte2 as (
select avg(average_income) as avg_all
from cte1
)

select name, average_income
from cte1
cross join cte2
where average_income < avg_all

-- Выручка по дням. Каждая запись содержит имя и фамилию продавца, день недели и суммарную выручку

with cte3 as ( 
SELECT concat(e.first_name, ' ', e.last_name) as name, extract(isodow from s.sale_date), 
lower(to_char(s.sale_date, 'Day')) as weekday, 
round(sum(p.price * s.quantity), 0) as income
FROM employees e
inner join sales s on e.employee_id = s.sales_person_id
inner join products p on p.product_id = s.product_id 
group by concat(e.first_name, ' ', e.last_name), extract(isodow from s.sale_date), lower(to_char(s.sale_date, 'Day'))
order by extract(isodow from s.sale_date), concat(e.first_name, ' ', e.last_name) )

select name, weekday, income
from cte3

--подсчет покупателей в разрезе возраста


select (case when age between 16 and 25 then '16-25'
             when age between 26 and 40 then '26-40'
             when age >= 40 then '40+' end) as age_category, count(*)
from customers
group by (case when age between 16 and 25 then '16-25'
             when age between 26 and 40 then '26-40'
             when age >= 40 then '40+' end)
order by (case when age between 16 and 25 then '16-25'
             when age between 26 and 40 then '26-40'
             when age >= 40 then '40+' end)
             
             
--данные по количеству уникальных покупателей и выручке, которую они принесли
             
select to_char(s.sale_date , 'YYYY-MM') as date, 
count(distinct s.customer_id) as total_customers,
round(sum(s.quantity * p.price), 0) as income
from sales s
inner join products p on s.product_id = p.product_id
group by to_char(s.sale_date , 'YYYY-MM')


--отчет о покупателях, первая покупка которых была 
--в ходе проведения акций (акционные товары отпускали со стоимостью равной 0)


with cte_first_buy as ( 
SELECT concat(c.first_name, ' ', c.last_name) as customer,
s.sale_date as sale_date,
concat(e.first_name, ' ', e.last_name) as seller, p.price as price,
row_number() over(partition by concat(c.first_name, ' ', c.last_name) order by s.sale_date) as numb,
c.customer_id as customer_id
from customers c
inner join sales s on c.customer_id = s.customer_id
inner join products p on p.product_id = s.product_id
inner join employees e on e.employee_id = s.sales_person_id 
)

select customer, sale_date, seller 
from cte_first_buy
where numb = 1 and price = 0
order by customer_id
