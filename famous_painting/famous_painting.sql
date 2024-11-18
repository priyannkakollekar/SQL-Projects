-- 1. Fetch all the paintings which are not displayed on any museums?
select distinct name from work where museum_id is null;

-- 2. Are there museums without any paintings?
select * from museum m
	where not exists (select 1 from work w
					 where w.museum_id=m.museum_id);
                     
-- 3. How many paintings have an asking price of more than their regular price?
select count(*) as cnt from product_size
where sale_price > regular_price;

-- 4. Identify the paintings whose asking price is less than 50% of its regular price
WITH cte1 as
(select work_id
from product_size
where sale_price < (regular_price*0.5))
select distinct w.name as paintings 
from cte1 c join work w
on c.work_id = w.work_id;
    
-- 5. Which canva size costs the most?
-- with join,subquery
select cs.label as canvas_size, ps.sale_price
From canvas_size cs left join product_size ps 
On cs.size_id = ps.size_id
where ps.sale_price = (select max(sale_price) from product_size);

-- with rank() function
select cs.label as canva, ps.sale_price
	from (select *
		  , rank() over(order by sale_price desc) as rnk 
		  from product_size) ps
	join canvas_size cs on cs.size_id=ps.size_id
	where ps.rnk=1;	

-- 6. Delete duplicate records from work, product_size, subject and image_link tables
-- work
WITH CTE1 as
(select artist_id, work_id, 
row_number() over(partition by artist_id, work_id) as rn 
from work)
select * from work where work_id 
in (select work_id from CTE1 where rn>1);
 
-- product_size
With CTE2 as
(select work_id, size_id, 
row_number() over(partition by work_id, size_id) as rn 
from product_size)
select * from product_size where work_id
in (select work_id from CTE2 where rn>1);

-- image_link
WITH CTE3 as
(select work_id, row_number() over(partition by work_id) as rn
from image_link)
select * from image_link where work_id
in (select work_id from CTE3 where rn > 1);

-- subject
with CTE4 as 
(select work_id, subject, row_number() over(partition by work_id, subject) as rn
from subject)
select * from subject where work_id
in (select work_id from CTE4 where rn > 1);


-- 7. Identify the museums with invalid city information in the given dataset
SELECT distinct(name)
FROM museum
WHERE city REGEXP '^[0-9]';

-- 8. Museum_Hours table has 1 invalid entry. Identify it and remove it.
select * from museum_hours where close like '___:00:PM' or open like '___:00:PM';

-- 9. Fetch the top 10 most famous painting subject
select t1.subject, count(t2.work_id) as count
from subject t1 left join work t2 on t1.work_id = t2.work_id
group by 1
order by 2 desc
limit 10;

-- 10. Identify the museums which are open on both Sunday and Monday. Display museum name, city.
With cte as 
(select museum_id from museum_hours where day in ('Sunday', 'Monday')
group by museum_id
having count(distinct(day)) = 2)
select t2.name, t2.city 
from cte t1 join museum t2 
on t1.museum_id= t2.museum_id 
order by t2.city desc;

-- 11. How many museums are open every single day?
with cte as (
select museum_id from museum_hours 
group by museum_id
having count(distinct(day)) = 7)
select t2.name, t2.city from cte t1 join museum t2 on t1.museum_id = t2.museum_id;

-- 12. Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
select t1.name, count(t2.work_id) as count
from museum t1 left join work t2 on t1.museum_id = t2.museum_id and t2.museum_id is not null
group by 1
order by 2 desc
limit 5;

-- 13. Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
select t1.full_name,
count(t2.artist_id) as count
from artist t1 left join work t2 on t1.artist_id = t2.artist_id and t2.artist_id is not null
group by 1
order by 2 desc
limit 5;

-- 14. Display the 3 least popular canva sizes
select t3.label, count(t3.label) as count
from product_size t1 left join work t2 on t1.work_id= t2.work_id 
    left join canvas_size t3 on t1.size_id = t3.size_id
where t3.label is not null
group by 1
order by 2 asc
limit 3;


--  15. Which museum is open for the longest during a day. Display museum name, state and hours open and which day?
WITH cte AS (
    SELECT 
        mh.*, 
        TIMESTAMPDIFF(SECOND, 
            STR_TO_DATE(SUBSTRING(open, 1, 5), '%H:%i'), 
            STR_TO_DATE(SUBSTRING(close, 1, 5), '%H:%i')) / 3600 AS diff
    FROM museum_hours mh
)
SELECT 
    t2.name, 
    t2.state, 
    cte.open, 
    cte.close, 
    cte.day
FROM cte
JOIN museum t2 ON cte.museum_id = t2.museum_id
ORDER BY cte.diff DESC
LIMIT 1;


 -- 16. Which museum has the most no of most popular painting style?
with cte as (
select museum_id, style, count(style) as count from work where museum_id is not null and style is not null
group by 1,2)

select t1.name, t2.style, count from museum t1 left join cte t2 on t1.museum_id = t2.museum_id
where count in (select max(count) from cte);

-- 17. Identify the artists whose paintings are displayed in multiple countries
with cte as (select t2.artist_id, count(t1.country) as Count 
                from museum t1 join work t2 on t1.museum_id = t2.museum_id
            group by 1
            having count(t1.country) > 1)

select t2.full_name, t1.count 
from cte t1 join artist t2 on t1.artist_id = t2.artist_id 
order by 2 desc;

-- 18. Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.
with cte as (select country, city,
            count(city) as count 
            from museum
            group by country,city
            order by count desc)

select * from cte 
where count in 
        (select max(count) 
        from cte);
        
-- 19. Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist name, sale_price, painting name, museum name, museum city and canvas label.
with artist_max as (
select t4.full_name, max(t1.sale_price) as price from product_size t1 left join work t2 on t1.work_id = t2.work_id
left join museum t3 on t2.museum_id = t3.museum_id
left join artist t4 on t2.artist_id = t4.artist_id
group by 1
order by 2 desc
limit 1),

artist_min as (
select t4.full_name, min(t1.sale_price) as price from product_size t1 left join work t2 on t1.work_id = t2.work_id
left join museum t3 on t2.museum_id = t3.museum_id
left join artist t4 on t2.artist_id = t4.artist_id
group by 1
order by 2 asc
limit 1)

select * from artist_max
union all
select * from artist_min;

-- 20. Which country has the 5th highest no of paintings?
with cte as (select t2.country, 
                    count(t2.country) as count 
                    from work t1 join museum t2 on t1.museum_id = t2.museum_id
            group by 1
            order by 2 desc),

interim as (select *, row_number() over(order by count desc) as rn from cte)

select country, count from interim where rn = 5;

-- 21. Which are the 3 most popular and 3 least popular painting styles?
with max_style as (select style, 
                count(style) as count from work
                group by 1
                order by 2 desc
                limit 3),

min_style as (select style, 
                    count(style) as count 
            from work where style is not null
group by 1
order by 2 asc
limit 3)

select * from max_style
union all
select * from min_style;

--  22. Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality
with cte as (select t2.artist_id, 
                    count(t3.country) as count 
            from subject t1 join work t2 on t1.work_id = t2.work_id
            join museum t3 on t2.museum_id = t3.museum_id
            where t1.subject = 'Portraits' and 
                t2.museum_id is not null and 
                t3.country !='USA'
            group by 1 
            order by 2 desc
            limit 1
            )

select t5.full_name, t4.count, 
        t5.nationality 
from cte t4 join artist t5 on t4.artist_id = t5.artist_id