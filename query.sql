SELECT TIMEDIFF('2020-03-01 20:00:00', '2020-02-20 01:00:00');
USE pokemon;
SET GLOBAL log_bin_trust_function_creators = 1;

-- DELIMITER //
-- create function isStrong(attack int, defense int)
-- 	returns varchar(20)
-- begin
-- 	declare a int;
-- 	declare b int;
-- 	declare isstrong varchar(20);
-- 	set a = attack;
-- 	set b = defense;
-- 	
-- 	select case 
-- 			when a + b > 120 then 'very strong'
-- 			when a + b > 90 then 'strong'
-- 			else 'not strong'
-- 			end into isstrong;
-- 	return isstrong;
-- end
-- //
-- DELIMITER ;

USE test_schema;

show tables;

SELECT COUNT(*)
FROM tbl_customer;

SELECT COUNT(*)
FROM tbl_purchase;


SELECT COUNT(*)
FROM tbl_visit;


select sum(price)
from tbl_purchase
where purchased_at >= '2020-07-01'
	and purchased_at < '2020-08-01';


select count(distinct customer_id)
from tbl_visit
where visited_at >= '2020-07-01' 
	and visited_at < '2020-08-01'
limit 10;

select count(distinct customer_id)
from tbl_purchase
where purchased_at >= '2020-07-01' 
	and purchased_at < '2020-08-01';

select count(distinct customer_id)
from tbl_visit
where visited_at >= '2020-07-01' 
	and visited_at < '2020-08-01';


select 
	 CAST(ROUND((CAST(purchase_count AS FLOAT) / visit_count) * 100, 1) AS FLOAT) AS conversion_rate
from 
	(select count(distinct customer_id) as purchase_count
	from tbl_purchase
	where purchased_at >= '2020-07-01' 
	and purchased_at < '2020-08-01') AS purchases,
    (select count(distinct customer_id) as visit_count
	from tbl_visit
	where visited_at >= '2020-07-01' 
	and visited_at < '2020-08-01') AS visits;


select round(avg(revenue), 2) 
from 
	(select customer_id , sum(price) as revenue
	from tbl_purchase
	where purchased_at >= '2020-07-01'
	and purchased_at < '2020-08-01'
	group by 1) as foo;
    
    
select customer_id 
, sum(price) as revenue
from tbl_purchase
where purchased_at >= '2020-07-01'
and purchased_at < '2020-08-01'
group by 1
order by 2 DESC
limit 5 offset 10;


USE test_schema;

select avg(users)
FROM (
	SELECT date_format(visited_at - interval 9 hour, '%Y-%m-%d ') as date_at
	, count(distinct customer_id) as users
	FROM tbl_visit
	WHERE visited_at >= '2020-07-01'
	and visited_at < '2020-08-01'
    group by 1
    order by 1) as foo;
    
    
select avg(users)
from (
SELECT date_format(visited_at - interval 9 hour, '%Y-%m-%U') as date_at
, count(distinct customer_id) as users
FROM tbl_visit
WHERE visited_at >= '2020-07-05'
and visited_at < '2020-07-25'
group by 1
order by 1) as foo;


select round(avg(revenue), 1)
from (
select date_format(purchased_at - interval 9 hour, '%Y-%m-%d') as date_at
	, sum(price) as revenue
from tbl_purchase
where purchased_at >= '2020-07-01'
	and purchased_at < '2020-08-01'
group by 1
order by 1) as foo;


select FORMAT(avg(revenue), 3)
from (
select date_format(purchased_at - interval 9 hour, '%Y-%m-%U') as date_at
	, sum(price) as revenue
from tbl_purchase
where purchased_at >= '2020-07-05'
	and purchased_at < '2020-07-26'
group by 1
order by 1) as foo;


select date_format(date_at, "%w") as day_name 
	, date_format(date_at, "%W") as day_name
	, format((revenue), 0)as revenue
from (
select date_format(purchased_at - interval 9 hour, '%Y-%m-%d') as date_at
	,sum(price) as revenue
from tbl_purchase
where purchased_at >= '2020-07-01'
	and purchased_at < '2020-08-01'
group by 1) as foo
group by 1, 2
order by 1;


select hour_at
	, avg(revenue)
from (
select date_format(purchased_at - interval 9 hour, '%Y-%m-%d') as date_at
	, date_format(purchased_at - interval 9 hour, '%H') as hour_at
	, sum(price) as revenue
from tbl_purchase
where purchased_at >= '2020-07-01'
	and purchased_at < '2020-08-01'
group by 1, 2) foo
group by 1
order by 2 DESC;


select day_of_week
	, hour_at
    , avg(revenue)
from (
select date_format(purchased_at - interval 9 hour, '%Y-%m-%d') as date_at
	, date_format(purchased_at - interval 9 hour, '%W') as day_of_week
	, date_format(purchased_at - interval 9 hour, '%H') as hour_at
	, sum(price) as revenue
from tbl_purchase
where purchased_at >= '2020-07-01'
	and purchased_at < '2020-08-01'
group by 1, 2, 3) foo
group by 1, 2
order by 3 desc;


select day_of_week
	, hour_at
    , avg(users)
from(
SELECT date_format(visited_at - interval 9 hour, '%Y-%m-%d') as date_at
	, date_format(visited_at - interval 9 hour, '%W') as day_of_week
	, date_format(visited_at - interval 9 hour, '%H') as hour_at
	, count(distinct customer_id) as users
FROM tbl_visit
WHERE visited_at >= '2020-07-05'
and visited_at < '2020-08-01'
group by 1, 2, 3) foo
group by 1,2
order by 3 DESC;




select concat(case when length(gender) < 1 then '기타'
			when gender = 'Others' then '기타'
            when gender = 'M' then '남성'
            when gender = 'F' then '여성'
			end 
	, "("
	, case when age <= 15 then '15세 이하'
		   when age <= 20 then '16~20세 이하'
           when age <= 25 then '21~25세 이하'
           when age <= 30 then '26~30세 이하'
           when age <= 35 then '31~35세 이하'
           when age <= 40 then '36~40세 이하'
           when age <= 45 then '41~45세 이하'
           when age >= 46 then '46세 이상' 
           end,")" ) as segement
	, round(count(*) /(select count(*) from tbl_customer) * 100, 2) as per
from tbl_customer
group by 1
order by 2 DESC;


select case when B.gender = 'M' then '남성'
			when B.gender = 'F' then '여성'
            when B.gender = 'Others' then '기타'
            when length(B.gender) < 1 then '기타'
            end as gender
	, case when age <= 15 then '15세 이하'
		   when age <= 20 then '16~20세 이하'
           when age <= 25 then '21~25세 이하'
           when age <= 30 then '26~30세 이하'
           when age <= 35 then '31~35세 이하'
           when age <= 40 then '36~40세 이하'
           when age <= 45 then '41~45세 이하'
           when age >= 46 then '46세 이상' 
           end as age_group
	, count(*) as cnt
    , sum(A.price) as revenue
from tbl_purchase A
left join tbl_customer B 
on A.customer_id = B.customer_id
where A.purchased_at >= '2020-07-01'
and A.purchased_at < '2020-08-01'
group by 1, 2
order by 4 desc;


with tbl_revenue as (
	select date_format(purchased_at - interval 9 hour, '%Y-%m-%d') as d_date
		, sum(price) as revenue
	from tbl_purchase
	where purchased_at >= '2020-07-01'
	and purchased_at < '2020-08-01'
	group by 1
)

select * 
	, revenue - lag(revenue) over(order by d_date asc) as diff_revenue
    , round((revenue - lag(revenue) over(order by d_date asc)) / lag(revenue) over(order by d_date asc) * 100, 2) as cng_revenue
from tbl_revenue;


select *
from (
select date_format(purchased_at - interval 9 hour, '%Y-%m-%d')
	, customer_id
	, sum(price)
    , dense_rank() over (partition by date_format(purchased_at - interval 9 hour, '%Y-%m-%d') order by sum(price) desc) as rank_rev
from tbl_purchase
where purchased_at >= '2020-07-01'
and purchased_at < '2020-08-01'
group by 1, 2) foo
where rank_rev < 4;