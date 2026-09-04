# 🛍️ Retail Sales Analysis — My First SQL Project

> **A beginner-friendly SQL data analytics project using PostgreSQL to explore retail sales, customer behaviour, product categories, profitability, and purchasing patterns.**

---

## 📌 Why I Built This

I'm **Abhijit**, and this is my very first data analytics project built from scratch.

I wanted to move beyond simply learning **SQL syntax** and start using SQL to answer questions that a real retail business might care about:

* Who is buying?
* What are they buying?
* When are they buying?
* Which categories generate the most revenue?
* Which customers are the most valuable?
* When is the store busiest?
* Which categories are the most profitable?

The dataset contains approximately **2,000 retail transactions** across three product categories — **Clothing, Beauty, and Electronics** — covering **2022–2023**.

Through this project, I practiced the complete beginner data-analytics workflow:

**Data Setup → Data Cleaning → Exploration → Business Questions → Deeper Analysis → Insights**

> **Note:** I took some structural inspiration from a public walkthrough of a similar dataset, but the framing, commentary, and questions in the **Going Further** section are my own.

---

## 📊 Project at a Glance

| Attribute        | Details                       |
| ---------------- | ----------------------------- |
| **Project**      | Retail Sales Analysis         |
| **Project Type** | SQL / Data Analytics          |
| **Dataset**      | ~2,000 transactions           |
| **Columns**      | 11                            |
| **Time Period**  | 2022–2023                     |
| **Categories**   | Clothing, Beauty, Electronics |
| **SQL Tool**     | PostgreSQL                    |
| **Database**     | `sql_project_1`               |
| **Table**        | `retail_sales`                |

---

## 🧰 Tools & Technologies

* **PostgreSQL**
* **SQL**
* **GitHub**
* **CSV Dataset**

### SQL Concepts Practiced

* `SELECT`
* `WHERE`
* `GROUP BY`
* `ORDER BY`
* Aggregate functions
* `COUNT()`
* `SUM()`
* `AVG()`
* `MIN()` / `MAX()`
* `COUNT(DISTINCT ...)`
* `CASE`
* Common Table Expressions (**CTEs**)
* Window functions
* `RANK()`
* `LAG()`
* Date & time functions
* Data cleaning
* Business-oriented analysis

---

# 🔄 Project Workflow

```text
Raw CSV Dataset
       ↓
Database & Table Setup
       ↓
Data Cleaning
       ↓
Data Exploration
       ↓
Business Questions
       ↓
Advanced Analysis
       ↓
Insights & Conclusions
```

---

# 1️⃣ Setting Up the Database

I first created the database and designed the `retail_sales` table with appropriate data types.

```sql
CREATE TABLE retail_sales (
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
```

### Dataset Structure

| Column            | Description                   |
| ----------------- | ----------------------------- |
| `transactions_id` | Unique transaction identifier |
| `sale_date`       | Date of purchase              |
| `sale_time`       | Time of purchase              |
| `customer_id`     | Customer identifier           |
| `gender`          | Customer gender               |
| `age`             | Customer age                  |
| `category`        | Product category              |
| `quantity`        | Number of units purchased     |
| `price_per_unit`  | Price per unit                |
| `cogs`            | Cost of goods sold            |
| `total_sale`      | Total transaction value       |

---

# 2️⃣ Data Cleaning

Before starting the analysis, I checked the dataset for missing values in important fields.

I removed transactions containing `NULL` values because incomplete records could distort calculations such as revenue, order counts, averages, and customer analysis.

```sql
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
```

### 💡 Key Lesson

> **NULL handling comes before analysis.**

My first attempt at the project made me realize that even a simple query can produce misleading results when the underlying data isn't cleaned properly.

---

# 3️⃣ Core Business Questions

These 10 queries form the standard analytical pass through the dataset.

They helped me practice translating simple business questions into SQL queries.

---

## Q1 — All Sales on a Specific Date

### Business Question

**Which transactions happened on November 5, 2022?**

```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

---

## Q2 — Bulk Clothing Orders in November 2022

### Business Question

**Find Clothing transactions in November 2022 where the customer purchased at least 3 units.**

```sql
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
  AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
  AND quantity >= 3;
```

---

## Q3 — Revenue and Order Count by Category

### Business Question

**Which categories generate the most revenue and the most orders?**

```sql
SELECT
    category,
    SUM(total_sale) AS net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category
ORDER BY net_sale DESC;
```

### Why This Matters

This gives a quick comparison of category performance and helps identify which products drive overall sales.

---

## Q4 — Average Age of Beauty Buyers

### Business Question

**What is the average age of customers purchasing Beauty products?**

```sql
SELECT
    ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';
```

---

## Q5 — High-Value Transactions

### Business Question

**Which transactions have a total sale value greater than ₹1,000?**

```sql
SELECT *
FROM retail_sales
WHERE total_sale > 1000;
```

These transactions can be useful when investigating premium customers, high-value purchases, or potential loyalty-program opportunities.

---

## Q6 — Gender Split by Category

### Business Question

**How are male and female customers distributed across product categories?**

```sql
SELECT
    category,
    gender,
    COUNT(*) AS total_trans
FROM retail_sales
GROUP BY category, gender
ORDER BY category;
```

---

## Q7 — Best-Selling Month of Each Year

### Business Question

**Which month had the highest average sale value in each year?**

```sql
SELECT
    year,
    month,
    avg_sale
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
) t
WHERE rnk = 1;
```

### SQL Concept Practiced

* Subqueries
* `GROUP BY`
* `AVG()`
* `RANK()`
* Window functions
* Date extraction

---

## Q8 — Top 5 Customers by Total Spend

### Business Question

**Who are the five customers who spent the most?**

```sql
SELECT
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
```

---

## Q9 — Unique Customers per Category

### Business Question

**How many unique customers purchased from each category?**

```sql
SELECT
    category,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;
```

---

## Q10 — Orders by Time of Day

I divided the day into three shifts:

* **Morning:** Before 12 PM
* **Afternoon:** 12 PM–5 PM
* **Evening:** After 5 PM

```sql
WITH hourly_sale AS (
    SELECT *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12
                THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17
                THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT
    shift,
    COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift;
```

### SQL Concept Practiced

* `CASE`
* `EXTRACT()`
* CTEs
* Aggregation

---

# 📈 Initial Findings

After running the first set of queries, several patterns stood out:

### 👕 Clothing

Clothing was the **volume leader**, generating a large number of transactions.

### 💻 Electronics

Electronics performed strongly in terms of **revenue per transaction**, suggesting higher-value purchases.

### 💄 Beauty

Beauty customers showed a slightly higher average age compared with some other categories.

### 🌆 Evening Sales

The **evening shift** accounted for a large portion of order volume, which could have implications for staffing and marketing timing.

### 👥 Customer Concentration

A relatively small group of repeat customers accounted for a noticeable share of revenue.

### 💰 High-Value Orders

Several transactions exceeded **₹1,000**, making them interesting candidates for further customer and purchasing analysis.

---

# 4️⃣ 🚀 Going Further — My Own Questions

After completing the standard analysis, I wanted to go beyond the typical beginner SQL questions.

This section contains questions that **I came up with myself** to explore profitability, customer behaviour, demographics, purchasing patterns, and time-based trends.

---

## Q11 — Gross Profit Margin by Category

### Business Question

**Which category generates the highest gross profit margin?**

```sql
SELECT
    category,
    SUM(total_sale - cogs) AS gross_profit,
    ROUND(
        (SUM(total_sale - cogs) * 100.0 / SUM(total_sale))::numeric,
        2
    ) AS margin_pct
FROM retail_sales
GROUP BY category
ORDER BY margin_pct DESC;
```

### What I Practiced

* Calculated columns
* Profit calculations
* Percentage calculations
* Aggregation

---

## Q12 — Busiest Weekday

### Business Question

**Which day of the week receives the most orders?**

```sql
SELECT
    TO_CHAR(sale_date, 'Day') AS weekday,
    COUNT(*) AS orders,
    SUM(total_sale) AS revenue
FROM retail_sales
GROUP BY weekday
ORDER BY orders DESC;
```

---

## Q13 — Average Basket Size by Category

### Business Question

**How many units does a customer typically purchase per transaction in each category?**

```sql
SELECT
    category,
    ROUND(AVG(quantity), 2) AS avg_units_per_order
FROM retail_sales
GROUP BY category;
```

---

## Q14 — Repeat vs. One-Time Customers

### Business Question

**How many customers purchased more than once, and how much revenue did repeat customers generate?**

```sql
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(*) AS n_orders,
        SUM(total_sale) AS spend
    FROM retail_sales
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN n_orders = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS num_customers,
    ROUND(SUM(spend)::numeric, 2) AS total_revenue
FROM customer_orders
GROUP BY customer_type;
```

### Why This Matters

Repeat customers can be significantly more valuable to a business than one-time customers.

This query helped me connect SQL analysis with a real business concept: **customer retention**.

---

## Q15 — Price-per-Unit Range by Category

### Business Question

**What are the minimum, maximum, and average product prices in each category?**

```sql
SELECT
    category,
    MIN(price_per_unit) AS min_price,
    MAX(price_per_unit) AS max_price,
    ROUND(AVG(price_per_unit)::numeric, 2) AS avg_price
FROM retail_sales
GROUP BY category;
```

---

## Q16 — Peak Hours of the Day

### Business Question

**Which hours receive the most orders?**

```sql
SELECT
    EXTRACT(HOUR FROM sale_time) AS hour,
    COUNT(*) AS orders
FROM retail_sales
GROUP BY hour
ORDER BY orders DESC
LIMIT 5;
```

This could potentially help a retailer understand when additional staff or marketing activity might be most useful.

---

## Q17 — Revenue by Age Band

### Business Question

**Which age group generates the most revenue?**

I created four customer age bands:

* Under 25
* 25–40
* 41–60
* 60+

```sql
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
```

---

## Q18 — Month-over-Month Revenue Growth

### Business Question

**How does revenue change from one month to the next?**

```sql
SELECT
    EXTRACT(YEAR FROM sale_date) AS yr,
    EXTRACT(MONTH FROM sale_date) AS mo,
    SUM(total_sale) AS revenue,
    ROUND(
        (
            (
                SUM(total_sale)
                - LAG(SUM(total_sale)) OVER (
                    ORDER BY
                        EXTRACT(YEAR FROM sale_date),
                        EXTRACT(MONTH FROM sale_date)
                )
            )
            * 100.0
            / NULLIF(
                LAG(SUM(total_sale)) OVER (
                    ORDER BY
                        EXTRACT(YEAR FROM sale_date),
                        EXTRACT(MONTH FROM sale_date)
                ),
                0
            )
        )::numeric,
        2
    ) AS mom_growth_pct
FROM retail_sales
GROUP BY yr, mo
ORDER BY yr, mo;
```

### SQL Concept Practiced

* `LAG()`
* Window functions
* Month-over-month analysis
* Percentage growth
* `NULLIF()`

---

## Q19 — Peak Hour by Category

### Business Question

**When does each product category receive the most orders?**

```sql
SELECT
    category,
    EXTRACT(HOUR FROM sale_time) AS hour,
    COUNT(*) AS orders,
    RANK() OVER (
        PARTITION BY category
        ORDER BY COUNT(*) DESC
    ) AS rnk
FROM retail_sales
GROUP BY category, hour
ORDER BY category, rnk;
```

This was one of the queries that helped me understand why **window functions** are so useful for analytical SQL.

---

## Q20 — Customers Who Bought From All 3 Categories

### Business Question

**Which customers purchased products from Clothing, Beauty, and Electronics?**

```sql
SELECT
    customer_id,
    COUNT(DISTINCT category) AS category_count,
    SUM(total_sale) AS spend
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(DISTINCT category) = 3
ORDER BY spend DESC;
```

This can help identify customers with broad purchasing behaviour across the entire product catalog.

---

# 🧠 What I Learned

This project taught me much more than SQL syntax.

### 1. Data Cleaning Comes First

Before writing analytical queries, I need to understand whether the data is reliable.

> **Bad inputs → bad analysis → bad decisions.**

---

### 2. SQL Can Answer Business Questions

SQL isn't just about writing commands like `SELECT` and `WHERE`.

The real skill is learning to translate:

> **Business Question → Data Requirement → SQL Query → Insight**

---

### 3. Window Functions Are Powerful

`RANK()` and `LAG()` were two of the concepts that stood out to me.

They made questions like:

* "What was the best month?"
* "What was the previous month's revenue?"
* "What is the peak hour for each category?"

much easier to solve.

---

### 4. The Same Dataset Can Tell Different Stories

The dataset doesn't change, but the questions do.

I could analyze the same transactions from the perspective of:

* Customers
* Categories
* Revenue
* Profitability
* Time
* Demographics
* Purchasing behaviour

This helped me understand that **good analytics starts with asking good questions**.

---

### 5. Asking My Own Questions Matters

The **Going Further** section is the part of this project that I consider most important.

Anyone can reproduce a standard SQL tutorial.

I wanted to demonstrate that I could take a dataset and ask:

> **"What else can I learn from this?"**

That mindset is something I want to continue developing as I move toward a career in **data and financial analytics**.

---

# 📁 Repository Structure

```text
Retail-Sales-Analysis/
│
├── retail_sales.sql
│   └── Database setup, data cleaning, and all 20 SQL queries
│
├── SQL - Retail Sales Analysis_utf.csv
│   └── Source dataset (~2,000 transactions)
│
└── README.md
    └── Project documentation
```

---

# 🎯 Skills Demonstrated

This project demonstrates my ability to:

* ✅ Work with PostgreSQL
* ✅ Create and structure SQL tables
* ✅ Clean datasets
* ✅ Handle NULL values
* ✅ Explore datasets
* ✅ Aggregate and summarize data
* ✅ Use SQL date/time functions
* ✅ Use `CASE` statements
* ✅ Write CTEs
* ✅ Use window functions
* ✅ Analyze customer behaviour
* ✅ Analyze category performance
* ✅ Calculate revenue and profitability metrics
* ✅ Perform time-based analysis
* ✅ Translate business questions into SQL queries
* ✅ Communicate analytical findings

---

# 👨‍💻 About Me

I'm **Abhijit**, and this project is my first step into data analytics.

I'm building my portfolio one project at a time, focusing on:

**SQL → Data Analytics → Financial Analytics → Business Insights**

My goal isn't just to learn tools, but to become better at using data to answer meaningful business questions.

I'm currently continuing to build my skills through SQL, statistics, financial analysis, and hands-on projects.

---

## ⭐ Feedback

This is my first SQL analytics project, so feedback is very welcome.

If you have suggestions for:

* Better SQL approaches
* Additional business questions
* Query optimization
* Data-cleaning techniques
* Improvements to the analysis

I'd love to learn from them.

**Thanks for checking out my project! 🚀**
