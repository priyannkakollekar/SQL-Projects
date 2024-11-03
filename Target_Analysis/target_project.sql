-- 1. What is the different type of data available here in different tables?

-- customers table

SELECT column_name,
       data_type
FROM   information_schema.columns
WHERE  table_schema = "target"
AND    table_name = "customers";

-- geolocations table

SELECT column_name,
       data_type
FROM   information_schema.columns
WHERE  table_schema = "target"
AND    table_name = "geolocations";

-- order items table

SELECT column_name,
       data_type
FROM   information_schema.columns
WHERE  table_schema = "target"
AND    table_name = "order_items";

-- order reviews table

SELECT column_name,
       data_type
FROM   information_schema.columns
WHERE  table_schema = "target"
AND    table_name = "order_reviews";

-- orders table

SELECT column_name,
       data_type
FROM   information_schema.columns
WHERE  table_schema = "target"
AND    table_name = "orders";

-- payments table

SELECT column_name,
       data_type
FROM   information_schema.columns
WHERE  table_schema = "target"
AND    table_name = "payments";

-- products table

SELECT column_name,
       data_type
FROM   information_schema.columns
WHERE  table_schema = "target"
AND    table_name = "products";

-- sellers table

SELECT column_name,
       data_type
FROM   information_schema.columns
WHERE  table_schema = "target"
AND    table_name = "sellers";

-- Get the time period for which the data is given

SELECT Min(order_purchase_timestamp) AS first_order,
       Max(order_purchase_timestamp) AS last_order
FROM   orders;SELECT     c.customer_state,
           c.customer_city
FROM       customers c
INNER JOIN orders o
ON         c.customer_id = o.customer_id
GROUP BY   c.customer_state,
           c.customer_city
ORDER BY   c.customer_state,
           c.customer_city;

-- Is there a growing trend in the no. of orders placed over the past years?

WITH sub AS
(
       SELECT *,
              Extract(year FROM order_purchase_timestamp)  AS YEAR,
              Extract(month FROM order_purchase_timestamp) AS MONTH
       FROM   orders )
SELECT   year,
         month,
         Count(order_id) AS VOLUME
FROM     sub
GROUP BY year,
         month
ORDER BY year,
         month;

-- Can we see some kind of monthly seasonality in terms of the no. of orders being placed?
-- we see that sales peak in the mid-year period during the months of May, July and August.

WITH sub AS
(
       SELECT *,
              Extract(month FROM order_purchase_timestamp) AS MONTH
       FROM   orders )
SELECT   month,
         Count(order_id) AS VOLUME
FROM     sub
GROUP BY month
ORDER BY month;

-- During what time of the day, do the Brazilian customers mostly place their orders? (Dawn, Morning, Afternoon or Night)
-- 0-6 hrs : Dawn
-- 7-12 hrs : Mornings
-- 13-18 hrs : Afternoon
-- 19-23 hrs : Night

WITH sub AS
(
       SELECT *,
              Hour(order_purchase_timestamp) AS time_in_hours
       FROM   orders ), sub1 AS
(
       SELECT *,
              CASE
                     WHEN time_in_hours BETWEEN 0 AND    6 THEN "dawn"
                     WHEN time_in_hours BETWEEN 7 AND    12 THEN "mornings"
                     WHEN time_in_hours BETWEEN 13 AND    18 THEN "afternoon"
                     WHEN time_in_hours BETWEEN 19 AND    23 THEN "night"
              END AS times_of_day
       FROM   sub )
SELECT   times_of_day,
         Count(order_id) AS Sales
FROM     sub1
GROUP BY times_of_day
ORDER BY sales DESC;

-- Get the month on month no. of orders placed in each state.

WITH sub AS
(
       SELECT *,
              Year(order_purchase_timestamp)  AS YEAR,
              Month(order_purchase_timestamp) AS MONTH
       FROM   orders )
SELECT    c.customer_state AS state,
          year,
          month,
          Count(sub.order_id) AS sales
FROM      sub
LEFT JOIN customers c
ON        c.customer_id = sub.customer_id
GROUP BY  state,
          year,
          month
ORDER BY  state,
          year,
          month;

-- How are the customers distributed across all the states?

SELECT   customer_state,
         Count(customer_id) AS no_of_customers
FROM     customers
GROUP BY customer_state
ORDER BY no_of_customers DESC;

-- Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only).

WITH sub AS
(
       SELECT *,
              Year(order_purchase_timestamp)  AS YEAR,
              Month(order_purchase_timestamp) AS MONTH
       FROM   orders ), temp_ AS
(
           SELECT     year,
                      Sum(payment_value) AS cost_to_order
           FROM       payments p
           RIGHT JOIN sub
           ON         sub.order_id = p.order_id
           WHERE      month BETWEEN 1 AND        8
           AND        year BETWEEN 2017 AND        2018
           GROUP BY   year
           ORDER BY   year ), temp AS
(
         SELECT   *,
                  Lag(temp_.cost_to_order) OVER(ORDER BY year) AS prev1
         FROM     temp_)
SELECT(cost_to_order-prev1)*100/prev1 AS increase
FROM   temp
WHERE  year=2018;

-- Calculate the Total & Average value of order price for each state.
-- Calculate the Total & Average value of order freight for each state.

SELECT   customer_state,
         Round(Sum(price),2)         AS sum_price,
         Round(Avg(price),2)         AS avg_price,
         Round(Sum(freight_value),2) AS sum_freight_value,
         Round(Avg(freight_value),2) AS avg_freight_value
FROM     orders o
JOIN     order_items oi
ON       o.order_id = oi.order_id
JOIN     customers c
ON       o.customer_id = c.customer_id
GROUP BY customer_state;

/* Find the no. of days taken to deliver each order from the order’s purchase date as delivery time.
Also, calculate the difference (in days) between the estimated & actual delivery date of an order.
Do this in a single query.
You can calculate the delivery time and the difference between the estimated & actual delivery date using the given formula:
time_to_deliver = order_delivered_customer_date - order_purchase_timestamp
diff_estimated_delivery = order_delivered_customer_date - order_estimated_delivery_date */

WITH sub AS
(
       SELECT c.customer_state,
              oi.freight_value,
              Datediff(order_delivered_carrier_date, order_purchase_timestamp)      AS time_to_deliver,
              Datediff(order_estimated_delivery_date, order_delivered_carrier_date) AS diff_estimate_delivery
       FROM   orders o
       JOIN   customers c
       ON     c.customer_id = o.customer_id
       JOIN   order_items oi
       ON     o.order_id = oi.order_id ), temp_ AS
(
         SELECT   customer_state,
                  Round(Avg(freight_value), 2)          AS avg_freight_value,
                  Round(Avg(time_to_deliver), 2)        AS avg_time_to_deliver,
                  Round(Avg(diff_estimate_delivery), 2) AS avg_diff_estimate_delivery
         FROM     sub
         GROUP BY customer_state )
-- States with the highest average freight cost.
SELECT   customer_state,
         temp_.avg_freight_value
FROM     temp_
ORDER BY temp_.avg_freight_value DESC limit 5;

-- States with the lowest average freight cost.

SELECT   customer_state,
         temp_.avg_freight_value
FROM     temp_
ORDER BY temp_.avg_freight_value ASC limit 5;

-- States with the highest average time to delivery.

SELECT   customer_state,
         temp_.avg_time_to_deliver
FROM     temp_
ORDER BY temp_.time_to_deliver DESC limit 5;

-- States with the lowest average time to delivery.

SELECT   customer_state,
         temp_.avg_time_to_deliver
FROM     temp_
ORDER BY temp_.time_to_deliver ASC limit 5;

-- States where delivery time is faster than estimated.

SELECT   customer_state,
         temp_.avg_diff_estimate_delivery
FROM     temp_
ORDER BY temp_.diff_estimate_delivery DESC limit 5;

-- States where delivery time is slower than estimated.

SELECT   customer_state,
         temp_.avg_diff_estimate_delivery
FROM     temp_
ORDER BY temp_.diff_estimate_delivery ASC limit 5;

-- Payment type analysis – Month over month count of different payment types

WITH sub AS
(
       SELECT *,
              Date_format(order_purchase_timestamp, "%m") AS mon,
              Month(order_purchase_timestamp) AS mon_no
       FROM   orders )
SELECT   p.payment_type,
         sub.mon,
         Count(DISTINCT sub.order_id) AS count_of_orders
FROM     sub
JOIN     payments p
ON       sub.order_id = p.order_id
GROUP BY p.payment_type,
         sub.mon,
         sub.mon_no
ORDER BY p.payment_type DESC,
         sub.mon_no;

-- Payment type analysis – Count of orders based on no. of installments

SELECT   payment_installments,
         Count(DISTINCT order_id) AS no_of_orders
FROM     payments
GROUP BY payment_installments
ORDER BY payment_installments