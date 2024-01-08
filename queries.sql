--считает общее количество клиентов

select count(*) as customers_count
from customers

--Топ 10 продавцов с наибольшей выручкой

SELECT concat(e.first_name, ' ', e.last_name) as name, count(s.sales_id) as operations, 
sum(p.price * s.quantity) as income
FROM employees e
inner join sales s on e.employee_id = s.sales_person_id
inner join products p on p.product_id = s.product_id 
group by concat(e.first_name, ' ', e.last_name)
order by sum(p.price * s.quantity) desc
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
to_char(s.sale_date, 'Day') as weekday, 
round(sum(p.price * s.quantity), 0) as income
FROM employees e
inner join sales s on e.employee_id = s.sales_person_id
inner join products p on p.product_id = s.product_id 
group by concat(e.first_name, ' ', e.last_name), extract(isodow from s.sale_date), to_char(s.sale_date, 'Day')
order by concat(e.first_name, ' ', e.last_name), extract(isodow from s.sale_date) )

select name, weekday, income
from cte3
