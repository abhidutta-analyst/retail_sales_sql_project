-- SQL Retail Sales Analysis - Project 1
CREATE DATABASE sql_project_1;

CREATE TABLE retail_sales(
     transactions_id INT PRIMARY KEY, 
     sale_date DATE,
     sale_time TIME,
     customer_id INT,
     gender VARCHAR(15),
     age INT,
     category VARCHAR(15),
     quantity INT,
     price_per_unit FLOAT,
     cogs FLOAT,
     total_sale FLOAT
);

-- Data Cleaning
DELETE FROM retail_sales
WHERE 
    transactions_id IS NULL OR
    sale_date IS NULL OR
    sale_time IS NULL OR
    customer_id IS NULL OR
    gender IS NULL OR
    category IS NULL OR
    quantity IS NULL OR
    cogs IS NULL OR
    total_sale IS NULL;

-- Data Exploration
SELECT COUNT(*) as total_sale FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) as unique_customers FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

-- ===========================
-- Core Business Questions (Q1–Q10)
-- ===========================

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'.
SELECT * FROM retail_sales WHERE sale_date = '2022-11-05';


-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is atleast 3 in the month of Nov-2022.
SELECT * 
FROM retail_sales
WHERE category = 'Clothing'
  AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
  AND quantity >= 3;


-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT category,
       SUM(total_sale) AS net_sale,
       COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category
ORDER BY net_sale DESC;


-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';


-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT * FROM retail_sales WHERE total_sale > 1000;


-- Q.6 Write a SQL query to find the total number of transactions made by each gender in each category.
SELECT category, gender, COUNT(*) AS total_trans
FROM retail_sales
GROUP BY category, gender
ORDER BY category;


-- Q.7 Write a SQL query to calculate the average sale for each month and find the highest average-sale month each year.
SELECT year, month, avg_sale
FROM (
    SELECT
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        FLOOR(AVG(total_sale)) AS avg_sale,
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM sale_date)
            ORDER BY AVG(total_sale) DESC
        ) AS rnk
    FROM retail_sales
    GROUP BY 1, 2
)
WHERE rnk = 1;


-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales.
SELECT customer_id, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;


-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT category, COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;


-- Q.10 Write a SQL query to create each shift (Morning <12, Afternoon Between 12 & 17, Evening >17) and count the number of orders in each shift.
WITH hourly_sale AS (
    SELECT *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT shift, COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift;


-- ===========================
-- Going Further – My Own Questions (Q11–Q20)
-- ===========================

-- Q.11 Write a SQL query to calculate the gross profit margin (total_sale - cogs) for each category.
SELECT category,
       SUM(total_sale - cogs) AS gross_profit,
       ROUND( (SUM(total_sale - cogs) * 100.0 / SUM(total_sale))::numeric, 2) AS margin_pct
FROM retail_sales
GROUP BY category
ORDER BY margin_pct DESC;


-- Q.12 Write a SQL query to find the busiest weekday by number of transactions.
SELECT TO_CHAR(sale_date, 'Day') AS weekday,
       COUNT(*) AS orders,
       SUM(total_sale) AS revenue
FROM retail_sales
GROUP BY weekday
ORDER BY orders DESC;



-- Q.13 Write a SQL query to find the average quantity sold per transaction in each category.
SELECT category, ROUND(AVG(quantity), 2) AS avg_units_per_order
FROM retail_sales
GROUP BY category;


-- Q.14 Write a SQL query to find how many customers are repeat customers versus one-time customers, and how much revenue does each group generate?
WITH customer_orders AS (
    SELECT customer_id, COUNT(*) AS n_orders, SUM(total_sale) AS spend
    FROM retail_sales
    GROUP BY customer_id
)
SELECT
    CASE WHEN n_orders = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_type,
    COUNT(*) AS num_customers,
    ROUND(SUM(spend)::numeric, 2) AS total_revenue
FROM customer_orders
GROUP BY customer_type;


-- Q.15 Write a SQL query to find the minimum, maximum, and average price per unit for each category.
SELECT category,
       MIN(price_per_unit) AS min_price,
       MAX(price_per_unit) AS max_price,
       ROUND(AVG(price_per_unit)::numeric, 2) AS avg_price
FROM retail_sales
GROUP BY category;


-- Q.16 Write a SQL query to find the top 5 peak hours of the day (by number of orders).
SELECT EXTRACT(HOUR FROM sale_time) AS hour, COUNT(*) AS orders
FROM retail_sales
GROUP BY hour
ORDER BY orders DESC
LIMIT 5;


-- Q.17 Write a SQL query to calculate revenue grouped by age bands (Under 25, 25-40, 41-60, 60+).
SELECT
    CASE
        WHEN age < 25 THEN 'Under 25'
        WHEN age BETWEEN 25 AND 40 THEN '25-40'
        WHEN age BETWEEN 41 AND 60 THEN '41-60'
        ELSE '60+'
    END AS age_band,
    COUNT(*) AS orders,
    ROUND(SUM(total_sale)::numeric, 2) AS revenue
FROM retail_sales
GROUP BY age_band
ORDER BY revenue DESC;


-- Q.18 Write a SQL query to compute the month-over-month revenue growth percentage.
SELECT
    EXTRACT(YEAR FROM sale_date) AS yr,
    EXTRACT(MONTH FROM sale_date) AS mo,
    SUM(total_sale) AS revenue,
    ROUND(
        ( (SUM(total_sale) - LAG(SUM(total_sale)) OVER (ORDER BY EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)))
          * 100.0 / NULLIF(LAG(SUM(total_sale)) OVER (ORDER BY EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)), 0)
        )::numeric, 2
    ) AS mom_growth_pct
FROM retail_sales
GROUP BY yr, mo
ORDER BY yr, mo;


-- Q.19 Write a SQL query to find the peak hour per category (by number of orders).
SELECT category,
       EXTRACT(HOUR FROM sale_time) AS hour,
       COUNT(*) AS orders,
       RANK() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) AS rnk
FROM retail_sales
GROUP BY category, hour
ORDER BY category, rnk;


-- Q.20 Write a SQL query to identify customers who purchased from all three categories.
SELECT customer_id,
       COUNT(DISTINCT category) AS category_count,
       SUM(total_sale) AS spend
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(DISTINCT category) = 3
ORDER BY spend DESC;


-- END OF PROJECT