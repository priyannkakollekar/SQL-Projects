-- 1. Total Revenue & Orders
SELECT COUNT(DISTINCT TransactionID) AS total_orders,
       ROUND(SUM(TransactionAmount),2) AS total_revenue
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown';

-- 2. Average Order Value (AOV)
SELECT ROUND(SUM(TransactionAmount) / COUNT(DISTINCT TransactionID),2) AS avg_order_value
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown';

-- 3. Monthly Sales Trends with EXTRACT FUNCTION
SELECT EXTRACT(year FROM TransactionDate)  AS sales_year,
	   EXTRACT(month FROM TransactionDate) AS sales_month,
       ROUND(SUM(TransactionAmount),2) AS monthly_revenue,
       COUNT(DISTINCT TransactionID) AS total_orders
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown'
GROUP BY sales_year,sales_month
HAVING sales_year <> 2000
ORDER BY sales_year,sales_month;

-- 3(a). Monthly Sales Trends with MONTH and YEAR FUNCTION
SELECT YEAR(TransactionDate)  AS sales_year,
	   MONTH(TransactionDate) AS sales_month,
       ROUND(SUM(TransactionAmount),2) AS monthly_revenue,
       COUNT(DISTINCT TransactionID) AS total_orders
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown'
GROUP BY sales_year,sales_month
HAVING sales_year <> 2000
ORDER BY sales_year,sales_month;

-- 4. Best 5 Selling Products
SELECT ProductName, 
       COUNT(*) AS total_sold,
       ROUND(SUM(TransactionAmount),2) AS revenue_generated
FROM test_assessment.assessment_dataset
GROUP BY ProductName
HAVING ProductName <> 'unknown'
ORDER BY total_sold DESC
LIMIT 5;

-- 5. Top 5 Cities by Sales Revenue
SELECT City,
       COUNT(DISTINCT TransactionID) AS total_orders,
	   ROUND(SUM(TransactionAmount),2) AS revenue_generated
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown'
GROUP BY City
ORDER BY revenue_generated DESC
LIMIT 5;

-- With Rank() Function Top 5 cities by Total Transactions
SELECT City, 
       COUNT(*) AS Total_Transactions,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS Rnk
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown'
GROUP BY City
LIMIT 5;

-- 6 Most Preferred Payment Methods
SELECT 
    PaymentMethod,
    ROUND(SUM(TransactionAmount),2) AS total_revenue,
    COUNT(DISTINCT TransactionID) AS total_orders
FROM test_assessment.assessment_dataset
GROUP BY PaymentMethod
HAVING PaymentMethod <> 'unknown'
ORDER BY total_orders DESC;

-- 7. Average loyalty points across all customers.
SELECT AVG(LoyaltyPoints) AS avg_loyalty_points
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown';

-- 8. Maximum loyalty points earned by a customer: 9,999
SELECT Max(LoyaltyPoints) AS max_loyalty_points
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown';

-- 9. Discount & Pricing Insights
SELECT ROUND(AVG(DiscountPercent),2) AS avg_discount,
	   ROUND(MAX(DiscountPercent),2) AS max_discount,
       ROUND(MIN(DiscountPercent),2) AS min_discount 
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown';

-- 10 Shipping & Delivery Performance
SELECT ROUND(AVG(ShippingCost),2) AS Avg_Shipping_Cost, 
       ROUND(AVG(DeliveryTimeDays),0) AS Avg_Delivery_Time, 
       MIN(DeliveryTimeDays) AS Fastest_Delivery, 
       MAX(DeliveryTimeDays) AS Slowest_Delivery 
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown';

-- 11. Product Sales Breakdown
SELECT ProductName,
       COUNT(*) AS Total_Sales,
       ROUND(SUM(TransactionAmount),2) AS Total_Revenue,
       ROUND(AVG(TransactionAmount), 2) AS Avg_Price,
       SUM(CASE WHEN IsPromotional = 'Yes' THEN 1 ELSE 0 END) AS Promo_Sales
FROM test_assessment.assessment_dataset
GROUP BY ProductName
HAVING ProductName <> 'unknown'
ORDER BY Total_Sales DESC
LIMIT 10;

-- 12. Customer Purchase Frequency
SELECT CustomerID,
       COUNT(DISTINCT TransactionID) AS order_count,
       ROUND(SUM(TransactionAmount),2) AS total_spent
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown'
GROUP BY CustomerID
HAVING CustomerID <> -1
ORDER BY total_spent DESC
LIMIT 10;

-- 13. Finding Repeat Customers
WITH CustomerOrders AS (
    SELECT CustomerID, COUNT(TransactionID) AS Order_Count
    FROM test_assessment.assessment_dataset
    WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown'
    GROUP BY CustomerID
    HAVING CustomerID <> -1
)
SELECT CustomerID
FROM CustomerOrders
WHERE Order_Count > 1;

-- 14. Customer Purchase Frequency With No Return
SELECT CustomerID,
       COUNT(DISTINCT TransactionID) AS order_count,
       ROUND(SUM(TransactionAmount),2) AS total_spent
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown' and Returned = "No"
GROUP BY CustomerID
HAVING CustomerID <> -1
ORDER BY total_spent DESC
LIMIT 10;

-- 15. StoreType Sales Breakdown
SELECT 
    StoreType,
    ROUND(SUM(TransactionAmount),2) AS total_revenue,
    COUNT(DISTINCT TransactionID) AS total_orders
FROM test_assessment.assessment_dataset
GROUP BY StoreType
HAVING StoreType <> 'unknown'
ORDER BY total_revenue DESC;

-- 16. Gender Sales Breakdown
SELECT 
    CustomerGender, 
    ROUND(SUM(TransactionAmount),2) AS total_revenue,
    COUNT(DISTINCT TransactionID) AS total_orders
FROM test_assessment.assessment_dataset
GROUP BY CustomerGender
HAVING CustomerGender IS NOT NULL
ORDER BY total_revenue DESC;

-- 17. Region Sales Breakdown
SELECT 
    Region, 
    ROUND(SUM(TransactionAmount),2) AS total_revenue,
    COUNT(DISTINCT TransactionID) AS total_orders
FROM test_assessment.assessment_dataset
GROUP BY Region
HAVING Region IS NOT NULL
ORDER BY total_revenue DESC;


-- 18. Customer Retention Analysis (New vs. Repeat Customers)
SELECT 
    CASE 
        WHEN CustomerID IN (SELECT DISTINCT CustomerID FROM test_assessment.assessment_dataset WHERE TransactionDate < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)) THEN 'Returning'
        ELSE 'New'
    END AS customer_type,
    COUNT(DISTINCT CustomerID) AS customer_count,
    ROUND(SUM(TransactionAmount),2) AS total_revenue
FROM test_assessment.assessment_dataset
WHERE CustomerID <> -1
GROUP BY customer_type;


-- 19. Day of the Week Sales Analysis (Peak Shopping Days)
SELECT 
    DAYNAME(TransactionDate) AS day_of_week,
    COUNT(DISTINCT TransactionID) AS total_orders,
    ROUND(SUM(TransactionAmount),2) AS total_revenue
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown'
GROUP BY day_of_week
ORDER BY total_revenue DESC;

-- 20. WeekEnd vs WeekDay Sales Analysis
SELECT 
    CASE 
		WHEN DAYNAME(TransactionDate) IN ('Saturday','Sunday') THEN 'Weekend'
        WHEN DAYNAME(TransactionDate) NOT IN ('Saturday','Sunday') THEN 'Weekday'
	End as Week_type,
    COUNT(DISTINCT TransactionID) AS total_orders,
    ROUND(SUM(TransactionAmount),2) AS total_revenue
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown'
GROUP BY Week_type
ORDER BY total_revenue DESC;

-- 21. Customer Behavior Analysis
SELECT 
    cs.CustomerID,
    cs.Total_Orders,
    cs.Total_Spent,
    cs.Avg_Order_Value,
    (SELECT MAX(sd.TransactionAmount) 
     FROM test_assessment.assessment_dataset sd 
     WHERE sd.CustomerID = cs.CustomerID) AS Max_Spent_Per_Order,
    (SELECT MIN(sd.TransactionAmount) 
     FROM test_assessment.assessment_dataset sd 
     WHERE sd.CustomerID = cs.CustomerID) AS Min_Spent_Per_Order
FROM (
    SELECT 
        CustomerID,
        COUNT(TransactionID) AS Total_Orders,
        ROUND(SUM(TransactionAmount),2) AS Total_Spent,
        ROUND(AVG(TransactionAmount),2) AS Avg_Order_Value
    FROM test_assessment.assessment_dataset
    WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown'
    GROUP BY CustomerID
    HAVING CustomerID <> -1
) AS cs
ORDER BY cs.Total_Spent DESC
LIMIT 10;


-- 22. Returned Rate Product Wise
With CTE As
(SELECT 
    ProductName, 
    COUNT(CASE WHEN Returned = 'Yes' THEN 1 END) AS total_returns,
    COUNT(*) AS total_orders
FROM test_assessment.assessment_dataset
GROUP BY ProductName
HAVING ProductName <> 'unknown')
SELECT ProductName, 
    total_returns, 
    total_orders, 
	ROUND((total_returns / total_orders) * 100, 2) AS return_rate_percentage 
FROM CTE
ORDER BY return_rate_percentage DESC;

-- 23. Customer Segmentation Based on Loyalty Points
SELECT 
    CASE 
        WHEN LoyaltyPoints < 100 THEN 'Low Loyalty'
        WHEN LoyaltyPoints BETWEEN 100 AND 500 THEN 'Medium Loyalty'
        ELSE 'High Loyalty'
    END AS loyalty_tier,
    COUNT(DISTINCT customerId) AS customer_count,
    ROUND(SUM(TransactionAmount),2) AS total_sales
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown'
GROUP BY loyalty_tier;

-- 24. Customer Segmentation (RFM Analysis)
WITH customer_rfm AS (
    SELECT CustomerID,
           COUNT(DISTINCT TransactionID) AS frequency,
           ROUND(SUM(TransactionAmount),2) AS monetary,
           MAX(TransactionDate) AS last_purchase,
           DATEDIFF(CURRENT_DATE, MAX(TransactionDate)) AS recency
    FROM test_assessment.assessment_dataset
    WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown'
    GROUP BY CustomerID
    HAVING CustomerID <> -1
)
SELECT CustomerID,
       recency,
       frequency,
       monetary,
       NTILE(4) OVER (ORDER BY recency DESC) AS recency_quartile,
       NTILE(4) OVER (ORDER BY frequency DESC) AS frequency_quartile,
       NTILE(4) OVER (ORDER BY monetary DESC) AS monetary_quartile
FROM customer_rfm; 

-- 25. 7 days moving Avg Revenue Growth Analysis using Window Functions
WITH Moving_Avg AS
(SELECT DATE(TransactionDate) as TransactionDate,
       ROUND(SUM(TransactionAmount),2) AS daily_revenue
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown'
GROUP BY TransactionDate
HAVING TransactionDate <> '2000-01-01'
ORDER BY TransactionDate)
SELECT *,ROUND(SUM(daily_revenue) OVER (ORDER BY TransactionDate ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS 7_day_moving_avg 
FROM Moving_Avg;

-- 26. Market Basket Analysis (Frequently Bought Together)
WITH product_pairs AS (
    SELECT LEAST(a.ProductName, b.ProductName) AS product_1,
           GREATEST(a.ProductName, b.ProductName) AS product_2,
           COUNT(*) AS frequency
    FROM test_assessment.assessment_dataset a
    JOIN test_assessment.assessment_dataset b ON a.TransactionID = b.TransactionID AND a.ProductName <> b.ProductName
    GROUP BY product_1, product_2
)
SELECT product_1, product_2, frequency
FROM product_pairs
ORDER BY frequency DESC
LIMIT 10;

-- 27. Promotion Effectiveness (Pre vs. Post Discount Sales)
WITH sales_comparison AS (
    SELECT 
        CASE WHEN IsPromotional = 'Yes' THEN 'Post-Discount' ELSE 'Pre-Discount' END AS discount_status,
        ROUND(SUM(TransactionAmount),2) AS total_revenue,
        COUNT(DISTINCT TransactionID) AS order_count,
        ROUND(AVG(TransactionAmount),2) AS avg_order_value
    FROM test_assessment.assessment_dataset
    WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown'
    GROUP BY discount_status
)
SELECT * FROM sales_comparison;


-- 28. Customer Retention Rate
WITH customer_orders AS (
    SELECT CustomerID, MIN(TransactionDate) AS first_order, MAX(TransactionDate) AS last_order
    FROM test_assessment.assessment_dataset
    WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown'
    GROUP BY CustomerID
    HAVING CustomerID <> -1
)
SELECT COUNT(CustomerID) AS total_customers,
       COUNT(CASE WHEN DATEDIFF(last_order, first_order) > 90 THEN 1 END) AS retained_customers,
       (COUNT(CASE WHEN DATEDIFF(last_order, first_order) > 90 THEN 1 END) / COUNT(CustomerID)) * 100 AS retention_rate
FROM customer_orders;

-- 29. Churned Customers (Inactive Users)
SELECT CustomerID, MAX(TransactionDate) AS last_purchase_date,
       DATEDIFF(CURRENT_DATE, MAX(TransactionDate)) AS days_since_last_purchase
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown'
GROUP BY CustomerID
HAVING days_since_last_purchase > 180 and CustomerID <> -1
ORDER BY days_since_last_purchase DESC;

-- 30. Average Time Between Purchases (Customer Lifetime Value Insight)
WITH purchase_intervals AS (
    SELECT CustomerID,
           TransactionDate,
           LAG(TransactionDate) OVER (PARTITION BY CustomerID ORDER BY TransactionDate) AS previous_purchase
    FROM test_assessment.assessment_dataset
    WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown'
)
SELECT CustomerID,
       AVG(DATEDIFF(TransactionDate, previous_purchase)) AS avg_days_between_purchases
FROM purchase_intervals
WHERE previous_purchase IS NOT NULL
GROUP BY CustomerID
HAVING CustomerID <> -1
ORDER BY avg_days_between_purchases ASC;

-- 31. Year-over-Year (YoY) Sales Growth (%)
WITH YearlySales AS (
    SELECT 
        YEAR(TransactionDate) AS sales_year,
        ROUND(SUM(TransactionAmount), 2) AS yearly_revenue
    FROM test_assessment.assessment_dataset
    WHERE PaymentMethod <> 'unknown' AND StoreType <> 'Unknown' AND ProductName <> 'unknown'
    GROUP BY sales_year
)
SELECT 
    sales_year,
    yearly_revenue,
    LAG(yearly_revenue) OVER (ORDER BY sales_year) AS prev_year_revenue,
    ROUND(((yearly_revenue - LAG(yearly_revenue) OVER (ORDER BY sales_year)) / LAG(yearly_revenue) OVER (ORDER BY sales_year)) * 100, 2) AS yoy_growth_percentage
FROM YearlySales
WHERE sales_year <> 2000;

-- 32. Month-over-Month (MoM) Sales Growth (%)
WITH MonthlySalesGrowth AS
(SELECT YEAR(TransactionDate) AS year,
       MONTH(TransactionDate) AS month,
       ROUND(SUM(TransactionAmount),2) AS total_revenue
FROM test_assessment.assessment_dataset
WHERE PaymentMethod <> 'unknown' and StoreType <> 'Unknown' and ProductName <> 'unknown'
GROUP BY year, month
ORDER BY year, month)
SELECT year,month,total_revenue,
	   LAG(total_revenue) OVER (PARTITION BY year ORDER BY month) AS prev_month_revenue,
       ROUND(((total_revenue - LAG(total_revenue) OVER (PARTITION BY year ORDER BY month)) / LAG(total_revenue) OVER (PARTITION BY year ORDER BY month)) * 100, 2) AS MoM_Growth_Percentage
FROM MonthlySalesGrowth
Where year <> 2000;