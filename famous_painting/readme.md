# SQL Data Analysis Project: Famous Paintings Dataset
This project is a comprehensive SQL data analysis using the Famous Paintings dataset available on Kaggle. It explores various aspects of the dataset to answer interesting questions about paintings, artists, museums, and more. Additionally, I learned a new technique: importing data from Python to SQL, enhancing my data integration workflow.

## Table of Contents
- About the Dataset
- Learning Outcomes
- SQL Queries and Insights
- Challenges Faced
- Future Improvements

## About the Dataset
The dataset contains information about famous paintings, artists, museums, canvas sizes, prices, and more. Key tables include:
- work: Details about each painting.
- museum: Information about museums displaying the paintings.
- product_size: Pricing and size details for paintings.
- artist: Artist details including name and nationality.
- subject: Subjects of the paintings (e.g., portraits, landscapes).
- museum_hours: Museum operation hours.

## Learning Outcomes
- SQL Mastery: Gained deeper insights into SQL queries, CTEs, window functions, and joins.
- Data Cleaning: Learned to identify and remove duplicate and invalid data entries.
- Python to SQL Integration: Successfully imported data into SQL using Python scripts, streamlining data preprocessing.

## SQL Queries and Insights

### 1. Fetch Paintings Not Displayed in Any Museum

```sh
SELECT DISTINCT name FROM work WHERE museum_id IS NULL;
```
### 2. Identify Museums Without Paintings

```sh
SELECT * FROM museum m
WHERE NOT EXISTS (
    SELECT 1 FROM work w WHERE w.museum_id = m.museum_id
);
```

### 3. Count of Paintings Priced Above Their Regular Price
```sh
SELECT COUNT(*) AS cnt FROM product_size
WHERE sale_price > regular_price;
```

### 4. Paintings Priced Below 50% of Their Regular Price
```sh
WITH cte1 AS (
    SELECT work_id FROM product_size
    WHERE sale_price < (regular_price * 0.5)
)
SELECT DISTINCT w.name AS paintings 
FROM cte1 c JOIN work w ON c.work_id = w.work_id;
```

### 5. Most Expensive Canvas Size
```sh
SELECT cs.label AS canvas_size, ps.sale_price
FROM canvas_size cs 
LEFT JOIN product_size ps ON cs.size_id = ps.size_id
WHERE ps.sale_price = (SELECT MAX(sale_price) FROM product_size);
```

### 6. Remove Duplicate Records from Multiple Tables
```sh
WITH CTE1 AS (
    SELECT artist_id, work_id, 
           ROW_NUMBER() OVER (PARTITION BY artist_id, work_id) AS rn 
    FROM work
)
SELECT * FROM work WHERE work_id 
IN (SELECT work_id FROM CTE1 WHERE rn > 1);
```

### 7. Invalid City Information in Museums
```sh
SELECT DISTINCT(name) FROM museum
WHERE city REGEXP '^[0-9]';
```

### 8. Identify and Remove Invalid Entries from Museum Hours
```sh
SELECT * FROM museum_hours 
WHERE close LIKE '___:00:PM' OR open LIKE '___:00:PM';
```

### 9. Top 10 Most Popular Painting Subjects
```sh
SELECT t1.subject, COUNT(t2.work_id) AS count
FROM subject t1 
LEFT JOIN work t2 ON t1.work_id = t2.work_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

### 10. Museums Open on Both Sunday and Monday
```sh
WITH cte AS (
    SELECT museum_id 
    FROM museum_hours 
    WHERE day IN ('Sunday', 'Monday')
    GROUP BY museum_id
    HAVING COUNT(DISTINCT(day)) = 2
)
SELECT t2.name, t2.city 
FROM cte t1 
JOIN museum t2 ON t1.museum_id = t2.museum_id 
ORDER BY t2.city DESC;
```

### 11. Museums Open All Days of the Week
```sh
WITH cte AS (
    SELECT museum_id 
    FROM museum_hours 
    GROUP BY museum_id
    HAVING COUNT(DISTINCT(day)) = 7
)
SELECT t2.name, t2.city 
FROM cte t1 
JOIN museum t2 ON t1.museum_id = t2.museum_id;
```
View the full list of queries and explanations in the [SQL Script](https://github.com/priyannkakollekar/SQL-Projects/blob/main/famous_painting/famous_painting.sql).

## Challenges Faced
- Data Cleaning: Handling duplicate records in multiple tables required careful use of window functions and CTEs.
- Invalid Data: Identifying and fixing inconsistencies in museum hours and city names.
-Integration: Importing large datasets from Python to SQL required optimizing the script for performance.

## Future Improvements
- Visualization: Use Python libraries (e.g., Matplotlib, Seaborn) to visualize key insights.
- Advanced Analysis: Explore clustering and classification algorithms for painting styles or artists.
- Dashboard: Create an interactive dashboard using Power BI.
