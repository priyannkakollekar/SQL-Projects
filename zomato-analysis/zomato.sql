DROP TABLE if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,STR_TO_DATE('09-22-2017','%m-%d-%Y')),
(3,STR_TO_DATE('04-21-2017','%m-%d-%Y'));

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,STR_TO_DATE('04-19-2017','%m-%d-%Y'),2),
(3,STR_TO_DATE('12-18-2019','%m-%d-%Y'),1),
(2,STR_TO_DATE('07-20-2020','%m-%d-%Y'),3),
(1,STR_TO_DATE('10-23-2019','%m-%d-%Y'),2),
(1,STR_TO_DATE('03-19-2018','%m-%d-%Y'),3),
(3,STR_TO_DATE('12-20-2016','%m-%d-%Y'),2),
(1,STR_TO_DATE('11-09-2016','%m-%d-%Y'),1),
(1,STR_TO_DATE('05-20-2016','%m-%d-%Y'),3),
(2,STR_TO_DATE('09-24-2017','%m-%d-%Y'),1),
(1,STR_TO_DATE('03-11-2017','%m-%d-%Y'),2),
(1,STR_TO_DATE('03-11-2016','%m-%d-%Y'),1),
(3,STR_TO_DATE('11-10-2016','%m-%d-%Y'),1),
(3,STR_TO_DATE('12-07-2017','%m-%d-%Y'),2),
(3,STR_TO_DATE('12-15-2016','%m-%d-%Y'),2),
(2,STR_TO_DATE('11-08-2017','%m-%d-%Y'),2),
(2,STR_TO_DATE('09-10-2018','%m-%d-%Y'),3);

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 
INSERT INTO users(userid,signup_date) 
 VALUES (1,STR_TO_DATE('09-02-2014','%m-%d-%Y')),
(2,STR_TO_DATE('01-15-2015','%m-%d-%Y')),
(3,STR_TO_DATE('04-11-2014','%m-%d-%Y'));

drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

-- what is total amount each customer spent on zomato?

select a.userid, sum(b.price) as total_amt_spent from sales a inner join product b on a.product_id=b.product_id
group by(a.userid);

-- How many days has each customer visited zomato?

select userid, count(distinct created_date) as No_of_days 
from sales 
group by userid;

-- what was the first product purchased by each customer?

select * from 
(select *,rank() over(partition by userid order by created_date) rnk from sales) a where rnk=1;

-- what is the most purchased item on the menu and how many times was it purchased by all customer?

select userid, count(product_id) as cnt from sales where product_id =
(select product_id from sales group by product_id order by count(product_id) desc limit 1)
group by userid
order by userid;

-- which item was the most popular for each customer?

select * from
(select *,rank() over(partition by userid order by cnt desc) rnk from
(select userid,product_id,count(product_id) cnt from sales group by userid,product_id)a)b
where rnk = 1;

-- which item was purchased first by the customer after they become a member?

select * from
(select c.*, rank() over(partition by userid order by created_date) rnk from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a inner join goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date) c)d where rnk = 1;

-- what is the total orders and amount spent on each member before they become a member?

select userid,count(created_date) as order_purchased,sum(price) as total_amount_spent from
(select c.*,d.price from 
(select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid=b.userid and created_date<=gold_signup_date)c inner join product d on c.product_id=d.product_id)e
group by userid;

-- if buying each product generates points for eg 5rs = 2 zomato points and each product has different purchasing points
-- for eg p1 5rs= 1zomato point, for p2 10rs= 5zomato and p3 5rs=1 zomato point
-- calculated points collected by each customers and for which product most points have been given till now.

select userid,sum(total_points)*2.5 total_points_earned from
(select e.*, round(amt/points,2) as total_points from
(select d.*, 
case when product_id = 1 then 5
when product_id = 2 then 2
when product_id=3 then 5
else 0 end as points from 
(select c.userid,c.product_id,sum(price) amt from
(select a.*, b.price from sales a inner join product b on a.product_id=b.product_id) c
group by userid,product_id)d)e)f group by userid;

select * from
(select *, rank() over(order by total_product_points_earned desc) rnk from
(select product_id,sum(total_points) total_product_points_earned from
(select e.*, round(amt/points,2) as total_points from
(select d.*, 
case when product_id = 1 then 5
when product_id = 2 then 2
when product_id=3 then 5
else 0 end as points from 
(select c.userid,c.product_id,sum(price) amt from
(select a.*, b.price from sales a inner join product b on a.product_id=b.product_id) c
group by userid,product_id)d)e)f group by product_id)f)g where rnk=1;

-- In the first one year after a customer joins the gold program (including their join date) irrespective of what the customer has purchased they earn 5 zomato points for every 10rs spent who earned more 1 or 3 and what was their points earnings in their first year?

SELECT c.*, d.price*0.5 total_point_earned FROM
(SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date 
FROM sales a 
INNER JOIN goldusers_signup b 
ON a.userid = b.userid 
AND a.created_date >= b.gold_signup_date 
AND a.created_date <= DATE_ADD(b.gold_signup_date, INTERVAL 1 YEAR))c
INNER JOIN product d
ON c.product_id = d.product_id;


-- Rank all transactions of the customers

SELECT *,RANK() over(partition by userid order by created_date desc) rnk 
FROM sales;

-- Rank all the transactions for each memeber whenever they are a zomato gold member for every non gold member transaction mark as "NA"

SELECT c.*, 
CASE WHEN gold_signup_date is null THEN "NA" 
ELSE RANK() over(partition by userid order by created_date desc) END as rnk
FROM
(SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date 
FROM sales a 
LEFT JOIN goldusers_signup b 
ON a.userid=b.userid and created_date>=gold_signup_date)c;














